package com.bcard.b_card

import android.nfc.cardemulation.HostApduService
import android.os.Bundle

/**
 * Makes the phone look like an NFC Forum Type 4 tag holding the profile link,
 * so another phone that taps it opens the profile with no app installed.
 *
 * Only answers while the Share screen's NFC tab is open ([ndefMessage] set);
 * otherwise it reports "file not found" and the reader moves on.
 */
class NdefCardService : HostApduService() {

    companion object {
        /** Raw NDEF message (no length prefix), set from Flutter. */
        @Volatile
        var ndefMessage: ByteArray? = null

        private val NDEF_APP_AID = hex("D2760000850101")
        private val CC_FILE_ID = hex("E103")
        private val NDEF_FILE_ID = hex("E104")

        private val OK = hex("9000")
        private val NOT_FOUND = hex("6A82")
        private val WRONG_PARAMS = hex("6B00")
        private val WRONG_LENGTH = hex("6700")
        private val INS_NOT_SUPPORTED = hex("6D00")

        private const val INS_SELECT = 0xA4
        private const val INS_READ_BINARY = 0xB0
        private const val MAX_READ = 0x3B // 59 bytes per READ BINARY, a safe size for all readers

        private fun hex(s: String) = ByteArray(s.length / 2) { s.substring(it * 2, it * 2 + 2).toInt(16).toByte() }
    }

    private enum class File { NONE, CC, NDEF }

    private var selected = File.NONE

    override fun processCommandApdu(apdu: ByteArray, extras: Bundle?): ByteArray {
        val message = ndefMessage ?: return NOT_FOUND
        if (apdu.size < 4) return WRONG_LENGTH

        return when (apdu[1].toInt() and 0xFF) {
            INS_SELECT -> select(apdu)
            INS_READ_BINARY -> readBinary(apdu, message)
            else -> INS_NOT_SUPPORTED
        }
    }

    private fun select(apdu: ByteArray): ByteArray {
        if (apdu.size < 5) return WRONG_LENGTH
        val lc = apdu[4].toInt() and 0xFF
        if (apdu.size < 5 + lc) return WRONG_LENGTH
        val data = apdu.copyOfRange(5, 5 + lc)
        val byName = (apdu[2].toInt() and 0xFF) == 0x04

        return when {
            byName && data.contentEquals(NDEF_APP_AID) -> { selected = File.NONE; OK }
            !byName && data.contentEquals(CC_FILE_ID) -> { selected = File.CC; OK }
            !byName && data.contentEquals(NDEF_FILE_ID) -> { selected = File.NDEF; OK }
            else -> NOT_FOUND
        }
    }

    private fun readBinary(apdu: ByteArray, message: ByteArray): ByteArray {
        val file = when (selected) {
            File.CC -> capabilityContainer(message.size + 2)
            File.NDEF -> byteArrayOf((message.size shr 8).toByte(), message.size.toByte()) + message
            File.NONE -> return NOT_FOUND
        }
        val offset = ((apdu[2].toInt() and 0xFF) shl 8) or (apdu[3].toInt() and 0xFF)
        val requested = if (apdu.size > 4) (apdu[4].toInt() and 0xFF).let { if (it == 0) 256 else it } else 256
        if (offset > file.size) return WRONG_PARAMS
        val end = minOf(file.size, offset + requested)
        return file.copyOfRange(offset, end) + OK
    }

    /** Capability Container (NFC Forum T4T 2.0): read-only NDEF file E104. */
    private fun capabilityContainer(ndefFileSize: Int) = byteArrayOf(
        0x00, 0x0F,                                   // CC length
        0x20,                                         // mapping version 2.0
        0x00, MAX_READ.toByte(),                      // MLe: max bytes per READ BINARY
        0x00, 0x34,                                   // MLc: max bytes per UPDATE BINARY
        0x04, 0x06,                                   // NDEF File Control TLV
        0xE1.toByte(), 0x04,                          // NDEF file id
        (ndefFileSize shr 8).toByte(), ndefFileSize.toByte(),
        0x00,                                         // read access: open
        0xFF.toByte(),                                // write access: none
    )

    override fun onDeactivated(reason: Int) {
        selected = File.NONE
    }
}
