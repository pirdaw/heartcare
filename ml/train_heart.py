"""
Pelatihan & evaluasi model skrining penyakit jantung (HeartCare)
Dataset : heart_baru.xlsx / heart.csv (Cleveland, 303 baris, 13 fitur + target)
Jalankan: python train_heart.py heart_baru.xlsx
Butuh   : pandas, openpyxl, scikit-learn, matplotlib
Output  : heart_model.json (untuk aplikasi Flutter) + hasil_evaluasi.png
"""
import sys
import json
import warnings

import numpy as np
import pandas as pd
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

from sklearn.model_selection import (
    train_test_split, RepeatedStratifiedKFold, StratifiedKFold,
    GridSearchCV, cross_validate, cross_val_predict,
)
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.linear_model import LogisticRegression
from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.metrics import (
    accuracy_score, precision_score, recall_score, f1_score,
    roc_auc_score, roc_curve, confusion_matrix, ConfusionMatrixDisplay,
)

warnings.filterwarnings("ignore")
SEED = 42

# ----------------------------------------------------------------------
# 1. MUAT & BERSIHKAN DATA
# ----------------------------------------------------------------------
path = sys.argv[1] if len(sys.argv) > 1 else "heart_baru.xlsx"
df = pd.read_excel(path) if path.endswith((".xlsx", ".xls")) else pd.read_csv(path)

print(f"Data awal      : {df.shape[0]} baris, {df.shape[1]} kolom")
print(f"Baris duplikat : {df.duplicated().sum()} (dibuang)")
df = df.drop_duplicates().reset_index(drop=True)

# Nilai tidak valid di dataset ini: ca=4 (5 baris) dan thal=0 (2 baris)
# -> dianggap data kosong, nanti diisi (impute) di dalam pipeline
df.loc[df["ca"] == 4, "ca"] = np.nan
df.loc[df["thal"] == 0, "thal"] = np.nan

# PENTING: di file ini target=1 berarti TIDAK sakit (lihat penjelasan di jawaban).
# Dibalik supaya y=1 = berisiko/sakit, sesuai logika aplikasi.
y = 1 - df["target"]
X = df.drop(columns="target")
print(f"Sebaran kelas  : sakit={int(y.sum())}, tidak sakit={int((1 - y).sum())}")

NUM = ["age", "trestbps", "chol", "thalach", "oldpeak", "ca"]
BIN = ["sex", "fbs", "exang"]
CAT = ["cp", "restecg", "slope", "thal"]  # kategori nominal -> one-hot


def make_pre():
    return ColumnTransformer([
        ("num", Pipeline([("imp", SimpleImputer(strategy="median")),
                          ("sc", StandardScaler())]), NUM),
        ("bin", "passthrough", BIN),
        ("cat", Pipeline([("imp", SimpleImputer(strategy="most_frequent")),
                          ("oh", OneHotEncoder(handle_unknown="ignore"))]), CAT),
    ])


# ----------------------------------------------------------------------
# 2. KANDIDAT ALGORITMA + GRID HYPERPARAMETER
# ----------------------------------------------------------------------
MODELS = {
    "Logistic Regression": (
        LogisticRegression(max_iter=2000),
        {"clf__C": [0.01, 0.1, 1, 10]}),
    "KNN": (
        KNeighborsClassifier(),
        {"clf__n_neighbors": [5, 7, 9, 11, 15]}),
    "SVM (RBF)": (
        SVC(probability=True, random_state=SEED),
        {"clf__C": [0.1, 1, 10], "clf__gamma": ["scale", 0.01, 0.05]}),
    "Random Forest": (
        RandomForestClassifier(random_state=SEED, n_jobs=1),
        {"clf__n_estimators": [150], "clf__max_depth": [3, 5],
         "clf__min_samples_leaf": [3]}),
    "Gradient Boosting": (
        GradientBoostingClassifier(random_state=SEED),
        {"clf__n_estimators": [100], "clf__learning_rate": [0.05],
         "clf__max_depth": [2, 3]}),
}


def build(name):
    clf, grid = MODELS[name]
    pipe = Pipeline([("pre", make_pre()), ("clf", clf)])
    inner = StratifiedKFold(5, shuffle=True, random_state=SEED)
    return GridSearchCV(pipe, grid, cv=inner, scoring="roc_auc", n_jobs=1)


# ----------------------------------------------------------------------
# 3. EVALUASI JUJUR: NESTED CROSS-VALIDATION
#    (tuning hyperparameter di dalam, penilaian di luar -> tidak bocor)
# ----------------------------------------------------------------------
print("\n=== Nested CV (5-fold x 1 ulangan) ===")
outer = RepeatedStratifiedKFold(n_splits=5, n_repeats=1, random_state=SEED)
scoring = {"acc": "accuracy", "prec": "precision", "rec": "recall",
           "f1": "f1", "auc": "roc_auc"}
rows = []
for name in MODELS:
    res = cross_validate(build(name), X, y, cv=outer, scoring=scoring, n_jobs=-1)
    rows.append({
        "Model": name,
        "Akurasi": res["test_acc"].mean(), "Akurasi_sd": res["test_acc"].std(),
        "Presisi": res["test_prec"].mean(),
        "Recall": res["test_rec"].mean(),
        "F1": res["test_f1"].mean(),
        "ROC-AUC": res["test_auc"].mean(),
    })
    print(f"  {name:<20} selesai")
cv_table = pd.DataFrame(rows).sort_values("ROC-AUC", ascending=False)
print(cv_table.drop(columns="Akurasi_sd").round(3).to_string(index=False))

# ----------------------------------------------------------------------
# 4. HOLD-OUT 80/20 (untuk confusion matrix & kurva ROC)
# ----------------------------------------------------------------------
X_tr, X_te, y_tr, y_te = train_test_split(
    X, y, test_size=0.2, stratify=y, random_state=SEED)

print("\n=== Hold-out test (20% data, belum pernah dilihat model) ===")
fitted, proba = {}, {}
hold = []
for name in MODELS:
    gs = build(name).fit(X_tr, y_tr)
    p = gs.predict_proba(X_te)[:, 1]
    pred = (p >= 0.5).astype(int)
    fitted[name], proba[name] = gs, p
    hold.append({
        "Model": name, "Akurasi": accuracy_score(y_te, pred),
        "Presisi": precision_score(y_te, pred), "Recall": recall_score(y_te, pred),
        "F1": f1_score(y_te, pred), "ROC-AUC": roc_auc_score(y_te, p),
        "Param terbaik": gs.best_params_,
    })
hold_table = pd.DataFrame(hold)
print(hold_table.drop(columns="Param terbaik").round(3).to_string(index=False))

# ----------------------------------------------------------------------
# 5. PILIH MODEL UNTUK APLIKASI: Logistic Regression
#    (akurasi setara model lain, tapi bisa diekspor ke JSON & mudah dijelaskan)
# ----------------------------------------------------------------------
final_name = "Logistic Regression"
gs_full = build(final_name).fit(X, y)
best_C = gs_full.best_params_["clf__C"]
print(f"\nModel final: {final_name}, C terbaik = {best_C}")

# Ambang batas risiko: probabilitas out-of-fold dari model final
oof = cross_val_predict(
    Pipeline([("pre", make_pre()), ("clf", LogisticRegression(C=best_C, max_iter=2000))]),
    X, y, cv=StratifiedKFold(5, shuffle=True, random_state=SEED),
    method="predict_proba")[:, 1]
print("\nPilihan ambang batas (probabilitas out-of-fold):")
print(f"{'ambang':>7} {'sensitivitas':>13} {'spesifisitas':>13} {'presisi':>8}")
for t in [0.3, 0.4, 0.5, 0.6, 0.7]:
    pr = (oof >= t).astype(int)
    tn, fp, fn, tp = confusion_matrix(y, pr).ravel()
    print(f"{t:>7.1f} {tp/(tp+fn):>13.2f} {tn/(tn+fp):>13.2f} {tp/(tp+fp):>8.2f}")

# ----------------------------------------------------------------------
# 6. EKSPOR KE JSON UNTUK FLUTTER
# ----------------------------------------------------------------------
final = Pipeline([("pre", make_pre()),
                  ("clf", LogisticRegression(C=best_C, max_iter=2000))]).fit(X, y)
pre, clf = final.named_steps["pre"], final.named_steps["clf"]

scaler = pre.named_transformers_["num"].named_steps["sc"]
ohe = pre.named_transformers_["cat"].named_steps["oh"]

names, mean, scale = [], [], []
for c, m, s in zip(NUM, scaler.mean_, scaler.scale_):
    names.append(c); mean.append(float(m)); scale.append(float(s))
for c in BIN:
    names.append(c); mean.append(0.0); scale.append(1.0)
for c, cats in zip(CAT, ohe.categories_):
    for v in cats:
        names.append(f"{c}_{int(v)}"); mean.append(0.0); scale.append(1.0)

assert len(names) == clf.coef_.shape[1]
model_json = {
    "note": "y=1 berarti berisiko penyakit jantung. Nama fitur one-hot: <kolom>_<kode dataset>",
    "features": names,
    "mean": mean,
    "scale": scale,
    "coef": [float(c) for c in clf.coef_[0]],
    "intercept": float(clf.intercept_[0]),
}
with open("heart_model.json", "w") as f:
    json.dump(model_json, f, indent=2)
print("\nTersimpan: heart_model.json")

# Fitur paling berpengaruh
imp = pd.Series(clf.coef_[0], index=names).sort_values()
print("\nKoefisien terbesar (naik = menaikkan risiko):")
print(imp.tail(6).round(2).to_string())
print("Koefisien terkecil (turun = menurunkan risiko):")
print(imp.head(6).round(2).to_string())

# ----------------------------------------------------------------------
# 7. GRAFIK UNTUK LAPORAN
# ----------------------------------------------------------------------
fig, ax = plt.subplots(1, 3, figsize=(16, 4.6))

order = cv_table.sort_values("Akurasi")
ax[0].barh(order["Model"], order["Akurasi"], xerr=order["Akurasi_sd"], color="#0D9488")
ax[0].set_xlim(0.6, 1.0)
ax[0].set_title("Akurasi nested CV (rata-rata ± SD)")
for i, v in enumerate(order["Akurasi"]):
    ax[0].text(0.61, i, f"{v:.3f}", va="center", fontsize=10, color="white", fontweight="bold")

for name in MODELS:
    fpr, tpr, _ = roc_curve(y_te, proba[name])
    ax[1].plot(fpr, tpr, label=f"{name} ({roc_auc_score(y_te, proba[name]):.2f})")
ax[1].plot([0, 1], [0, 1], "k--", lw=0.8)
ax[1].set_title("Kurva ROC (hold-out test)")
ax[1].set_xlabel("False positive rate"); ax[1].set_ylabel("True positive rate")
ax[1].legend(fontsize=8, loc="lower right")

cm = confusion_matrix(y_te, (proba[final_name] >= 0.5).astype(int))
ConfusionMatrixDisplay(cm, display_labels=["Tidak sakit", "Sakit"]).plot(
    ax=ax[2], cmap="Blues", colorbar=False)
ax[2].set_title(f"Confusion matrix – {final_name}")

plt.tight_layout()
plt.savefig("hasil_evaluasi.png", dpi=150)
print("Tersimpan: hasil_evaluasi.png")
