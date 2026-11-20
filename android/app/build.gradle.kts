plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "bd.howlader.staff_app"
    // flutter_local_notifications and androidx.core 1.19 need API 37 to compile
    // against; targetSdk (runtime behaviour) stays on the Flutter default.
    compileSdk = 37
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true // flutter_local_notifications
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "bd.howlader.staff_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Release signing comes ONLY from CI secrets / local env (never the repo):
    // STAFF_KEYSTORE_PATH, STAFF_KEYSTORE_PASSWORD, STAFF_KEY_ALIAS, STAFF_KEY_PASSWORD.
    val ks = System.getenv("STAFF_KEYSTORE_PATH")
    signingConfigs {
        if (ks != null) {
            create("release") {
                storeFile = file(ks)
                storePassword = System.getenv("STAFF_KEYSTORE_PASSWORD")
                keyAlias = System.getenv("STAFF_KEY_ALIAS")
                keyPassword = System.getenv("STAFF_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        release {
            // Without the env vars a release build is debug-signed (installable for
            // testing, not for Play upload).
            signingConfig = if (ks != null) signingConfigs.getByName("release") else signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.squareup.okhttp3:okhttp:4.12.0")
}
