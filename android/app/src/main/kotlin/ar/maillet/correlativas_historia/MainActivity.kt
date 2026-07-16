package ar.maillet.correlativas_historia

import android.provider.Settings
import android.os.Bundle
import android.os.Build
import androidx.activity.enableEdgeToEdge
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader

class MainActivity : FlutterFragmentActivity() {
    private val deviceIdentityChannel =
        "ar.maillet.correlativas_historia/device_identity"

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            deviceIdentityChannel,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidDeviceId" -> {
                    val avdName = readSystemProperty("ro.boot.qemu.avd_name")
                        ?.trim()
                        ?.takeIf { it.isNotEmpty() }
                    if (avdName != null) {
                        result.success("emu_$avdName")
                        return@setMethodCallHandler
                    }

                    val androidId = Settings.Secure.getString(
                        contentResolver,
                        Settings.Secure.ANDROID_ID,
                    )
                    result.success(androidId)
                }

                "getAndroidDeviceLabel" -> {
                    val avdName = readSystemProperty("ro.boot.qemu.avd_name")
                        ?.trim()
                        ?.takeIf { it.isNotEmpty() }
                    if (avdName != null) {
                        result.success("Android Emulator ${friendlyAvdName(avdName)}")
                        return@setMethodCallHandler
                    }

                    result.success(buildDeviceLabel())
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun buildDeviceLabel(): String {
        val manufacturer = Build.MANUFACTURER?.trim().orEmpty()
        val model = Build.MODEL?.trim().orEmpty()
        if (manufacturer.equals("samsung", ignoreCase = true) &&
            model.startsWith("SM-A35", ignoreCase = true)
        ) {
            return "Samsung A35"
        }

        val prettyManufacturer = manufacturer
            .replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
        return when {
            model.isEmpty() && prettyManufacturer.isEmpty() -> "Dispositivo Android"
            prettyManufacturer.isEmpty() -> model
            model.isEmpty() -> prettyManufacturer
            model.startsWith(prettyManufacturer, ignoreCase = true) -> model
            else -> "$prettyManufacturer $model"
        }
    }

    private fun friendlyAvdName(raw: String): String {
        return raw.replace('_', ' ').trim()
    }

    private fun readSystemProperty(key: String): String? {
        return try {
            val process = ProcessBuilder("getprop", key).start()
            BufferedReader(InputStreamReader(process.inputStream)).use { reader ->
                reader.readLine()
            }
        } catch (_: Exception) {
            null
        }
    }
}
