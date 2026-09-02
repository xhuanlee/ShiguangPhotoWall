plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.sgphotowall"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    buildFeatures {
        resValues = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.example.sgphotowall"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "app"
    productFlavors {
        create("mobile") {
            dimension = "app"
            applicationId = "com.example.sgphotowall"
            resValue("string", "app_name", "拾光影像墙")
            isDefault = true
        }
        create("tv") {
            dimension = "app"
            applicationId = "com.example.sgphotowall.tv"
            resValue("string", "app_name", "拾光影像墙 TV")
            minSdk = 26
        }
    }

    signingConfigs {
        create("release") {
            // CI 注入签名密钥；本地未配置时回退 debug 签名
            val ksPath = System.getenv("SGPW_KEYSTORE_PATH")
            val ksPassword = System.getenv("SGPW_KEYSTORE_PASSWORD") ?: ""
            val ksAlias = System.getenv("SGPW_KEY_ALIAS") ?: ""
            val ksKeyPassword = System.getenv("SGPW_KEY_PASSWORD") ?: ""
            if (ksPath != null && ksPassword.isNotEmpty() && ksAlias.isNotEmpty()) {
                storeFile = file(ksPath)
                storePassword = ksPassword
                keyAlias = ksAlias
                keyPassword = if (ksKeyPassword.isNotEmpty()) ksKeyPassword else ksPassword
            }
        }
    }

    buildTypes {
        release {
            val ksPath = System.getenv("SGPW_KEYSTORE_PATH")
            if (ksPath != null && file(ksPath).exists()) {
                signingConfig = signingConfigs.getByName("release")
            } else {
                // 本地开发回退 debug 签名；生产发布必须在 CI 注入正式 keystore
                signingConfig = signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    sourceSets {
        getByName("mobile") {
            manifest.srcFile("src/mobile/AndroidManifest.xml")
        }
        getByName("tv") {
            manifest.srcFile("src/tv/AndroidManifest.xml")
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
