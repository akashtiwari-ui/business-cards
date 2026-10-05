package com.bcard.b_card

import android.app.StatusBarManager
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.nfc.NfcAdapter
import android.nfc.cardemulation.CardEmulation
import android.graphics.drawable.Icon
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.bcard/system").setMethodCallHandler { call, result ->
            if (call.method == "openAppSettings") {
                startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null)))
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.bcard/nfc").setMethodCallHandler { call, result ->
            when (call.method) {
                "supportsCardEmulation" ->
                    result.success(packageManager.hasSystemFeature(PackageManager.FEATURE_NFC_HOST_CARD_EMULATION))
                "startCardEmulation" -> {
                    NdefCardService.ndefMessage = call.argument<ByteArray>("ndef")
                    setPreferred(true)
                    result.success(null)
                }
                "stopCardEmulation" -> {
                    NdefCardService.ndefMessage = null
                    setPreferred(false)
                    result.success(null)
                }
                "saveShareLink" -> {
                    NfcShareStore.setNdef(this, call.argument<ByteArray>("ndef"))
                    result.success(null)
                }
                "isAlwaysOn" -> result.success(NfcShareStore.isAlwaysOn(this))
                "setAlwaysOn" -> result.success(NfcShareStore.setAlwaysOn(this, call.argument<Boolean>("on") == true))
                "canAddTile" -> result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU)
                "addTile" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        getSystemService(StatusBarManager::class.java).requestAddTileService(
                            ComponentName(this, NfcShareTileService::class.java),
                            getString(R.string.nfc_tile_label),
                            Icon.createWithResource(this, R.drawable.ic_tile_nfc),
                            mainExecutor,
                        ) { code -> result.success(code) }
                    } else {
                        result.success(-1)
                    }
                }
                "openNfcSettings" -> {
                    startActivity(Intent(Settings.ACTION_NFC_SETTINGS))
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    /** Wins over other apps registered for the same NFC AID while we are in front. */
    private fun setPreferred(on: Boolean) {
        val adapter = NfcAdapter.getDefaultAdapter(this) ?: return
        val emulation = runCatching { CardEmulation.getInstance(adapter) }.getOrNull() ?: return
        runCatching {
            if (on) emulation.setPreferredService(this, ComponentName(this, NdefCardService::class.java))
            else emulation.unsetPreferredService(this)
        }
    }

    // Preferred-service status is dropped when the activity pauses.
    override fun onResume() {
        super.onResume()
        if (NdefCardService.ndefMessage != null) setPreferred(true)
    }

    override fun onDestroy() {
        if (isFinishing) NdefCardService.ndefMessage = null
        super.onDestroy()
    }
}
