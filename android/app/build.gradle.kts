import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "ar.maillet.correlativas_historia"
    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }

    defaultConfig {
        applicationId = "ar.maillet.correlativas_historia"

        // ✅ fijalo explícito para que no te cambie solo
        minSdk = 24

        // ✅ requerido por Play
        targetSdk = 35

        // ✅ CLAVE: mayor que 413
        versionCode = 414

        // ✅ lo que ve el usuario
        versionName = "1.2.26"
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"]?.toString()
                keyPassword = keystoreProperties["keyPassword"]?.toString()
                storeFile = keystoreProperties["storeFile"]?.toString()?.let { file(it) }
                storePassword = keystoreProperties["storePassword"]?.toString()
            }
        }
    }

    buildTypes {
        getByName("release") {
            if (keystorePropertiesFile.exists()) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }

    splits {
        abi {
            isEnable = false
            reset()
            isUniversalApk = false
        }
    }
}