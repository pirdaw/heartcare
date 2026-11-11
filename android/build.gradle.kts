allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.extra.apply {
    set("compileSdkVersion", 36)
    set("minSdkVersion", 24)
    set("targetSdkVersion", 35)
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    if (project.name != "app") {
        val configureAction: Project.() -> Unit = {
            plugins.withId("com.android.library") {
                extensions.configure<com.android.build.gradle.LibraryExtension> {
                    compileSdk = 36
                    defaultConfig {
                        minSdk = 24
                    }
                }
            }
        }
        if (state.executed) {
            configureAction()
        } else {
            afterEvaluate {
                configureAction()
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
