package com.bcard.b_card

import android.app.PendingIntent
import android.content.Intent
import android.nfc.NfcAdapter
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService

/**
 * Quick Settings tile: switch "tap to share" on or off without opening B Card.
 * Unavailable until the app has saved a public profile link.
 */
class NfcShareTileService : TileService() {

    override fun onStartListening() {
        super.onStartListening()
        render()
    }

    override fun onClick() {
        super.onClick()
        val hasLink = NfcShareStore.ndef(this) != null
        val nfcOn = NfcAdapter.getDefaultAdapter(this)?.isEnabled == true
        if (!hasLink || !nfcOn) {
            openApp()
            return
        }
        NfcShareStore.setAlwaysOn(this, !NfcShareStore.isAlwaysOn(this))
        render()
    }

    private fun render() {
        val tile = qsTile ?: return
        val hasLink = NfcShareStore.ndef(this) != null
        val on = hasLink && NfcShareStore.isAlwaysOn(this)
        tile.label = getString(R.string.nfc_tile_label)
        tile.state = when {
            !hasLink -> Tile.STATE_UNAVAILABLE
            on -> Tile.STATE_ACTIVE
            else -> Tile.STATE_INACTIVE
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            tile.subtitle = getString(
                when {
                    !hasLink -> R.string.nfc_tile_setup
                    on -> R.string.nfc_tile_on
                    else -> R.string.nfc_tile_off
                },
            )
        }
        tile.updateTile()
    }

    private fun openApp() {
        val intent = Intent(this, MainActivity::class.java).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startActivityAndCollapse(
                PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT),
            )
        } else {
            @Suppress("DEPRECATION")
            startActivityAndCollapse(intent)
        }
    }
}
