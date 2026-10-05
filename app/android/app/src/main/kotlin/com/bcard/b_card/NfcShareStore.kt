package com.bcard.b_card

import android.content.ComponentName
import android.content.Context
import android.service.quicksettings.TileService
import android.util.Base64

/**
 * What tap-to-share serves when B Card is not open: the saved profile link
 * (as an NDEF message) and whether "Always on" is switched on.
 *
 * The link is written by the app whenever it knows the user's public card,
 * and cleared when the card is hidden or the user signs out.
 */
object NfcShareStore {
    private const val PREFS = "bcard_nfc_share"
    private const val KEY_NDEF = "ndef"
    private const val KEY_ALWAYS_ON = "always_on"

    private fun prefs(context: Context) = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    fun ndef(context: Context): ByteArray? =
        prefs(context).getString(KEY_NDEF, null)?.let { Base64.decode(it, Base64.NO_WRAP) }

    fun setNdef(context: Context, ndef: ByteArray?) {
        prefs(context).edit().apply {
            if (ndef == null) {
                remove(KEY_NDEF)
                putBoolean(KEY_ALWAYS_ON, false) // nothing left to share
            } else {
                putString(KEY_NDEF, Base64.encodeToString(ndef, Base64.NO_WRAP))
            }
        }.apply()
        refreshTile(context)
    }

    fun isAlwaysOn(context: Context): Boolean = prefs(context).getBoolean(KEY_ALWAYS_ON, false)

    /** Returns the resulting state: it cannot turn on without a saved link. */
    fun setAlwaysOn(context: Context, on: Boolean): Boolean {
        val enabled = on && ndef(context) != null
        prefs(context).edit().putBoolean(KEY_ALWAYS_ON, enabled).apply()
        refreshTile(context)
        return enabled
    }

    /** The message to serve right now, or null to stay silent. */
    fun messageToServe(context: Context): ByteArray? =
        NdefCardService.ndefMessage ?: if (isAlwaysOn(context)) ndef(context) else null

    private fun refreshTile(context: Context) {
        runCatching {
            TileService.requestListeningState(context, ComponentName(context, NfcShareTileService::class.java))
        }
    }
}
