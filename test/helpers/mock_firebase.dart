// ignore_for_file: depend_on_referenced_packages
import 'dart:async';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebaseAppPlatform extends FirebaseAppPlatform {
  MockFirebaseAppPlatform(super.name, super.options);
}

class MockFirebasePlatform extends FirebasePlatform {
  MockFirebasePlatform() : super();

  final List<FirebaseAppPlatform> _apps = [];

  @override
  List<FirebaseAppPlatform> get apps => List.unmodifiable(_apps);

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final effectiveName = name ?? defaultFirebaseAppName;
    final app = MockFirebaseAppPlatform(
      effectiveName,
      options ??
          const FirebaseOptions(
            apiKey: 'mock_api_key',
            appId: 'mock_app_id',
            messagingSenderId: 'mock_sender_id',
            projectId: 'mock_project_id',
          ),
    );
    _apps.removeWhere((a) => a.name == effectiveName);
    _apps.add(app);
    return app;
  }

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    final existing = _apps.where((a) => a.name == name).firstOrNull;
    if (existing != null) return existing;
    final newApp = MockFirebaseAppPlatform(
      name,
      const FirebaseOptions(
        apiKey: 'mock_api_key',
        appId: 'mock_app_id',
        messagingSenderId: 'mock_sender_id',
        projectId: 'mock_project_id',
      ),
    );
    _apps.add(newApp);
    return newApp;
  }
}

class MockFirebaseAuthPlatform extends FirebaseAuthPlatform {
  MockFirebaseAuthPlatform({super.appInstance});

  @override
  FirebaseAuthPlatform delegateFor({required FirebaseApp app}) {
    return MockFirebaseAuthPlatform(appInstance: app);
  }

  @override
  FirebaseAuthPlatform setInitialValues({
    InternalUserDetails? currentUser,
    String? languageCode,
  }) {
    return this;
  }

  @override
  UserPlatform? get currentUser => null;

  @override
  Stream<UserPlatform?> authStateChanges() => Stream.value(null);

  @override
  Stream<UserPlatform?> idTokenChanges() => Stream.value(null);

  @override
  Stream<UserPlatform?> userChanges() => Stream.value(null);
}

Future<void> setupMockFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  FirebasePlatform.instance = MockFirebasePlatform();
  FirebaseAuthPlatform.instance = MockFirebaseAuthPlatform();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'mock_api_key',
      appId: 'mock_app_id',
      messagingSenderId: 'mock_sender_id',
      projectId: 'mock_project_id',
    ),
  );
}
