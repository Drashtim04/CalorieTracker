plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter plugin (must stay last)
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.boomit.calorie_tracker"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // ✅ REQUIRED for flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true

        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.boomit.calorie_tracker"

        // ✅ Ensure this is at least 21
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // For now using debug signing
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // ✅ THIS FIXES YOUR ERROR
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}