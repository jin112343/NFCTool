package com.nfctools

import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.util.Log
import java.io.IOException
import java.nio.charset.Charset

object NFCUtils {
    private const val TAG = "NFCUtils"

    enum class NFCState {
        STANDBY,
        READ,
        WRITE,
        DELETE
    }

    fun readNdefTag(tag: Tag): NdefMessage? {
        val ndef = Ndef.get(tag) ?: return null
        try {
            ndef.connect()
            val ndefMessage = ndef.ndefMessage
            ndef.close()
            return ndefMessage
        } catch (e: IOException) {
            Log.e(TAG, "Error reading NFC tag", e)
            return null
        }
    }

    fun writeNdefTag(tag: Tag, message: NdefMessage): Boolean {
        val ndef = Ndef.get(tag) ?: return false
        try {
            ndef.connect()
            if (!ndef.isWritable) {
                Log.e(TAG, "Tag is not writable")
                return false
            }
            if (ndef.maxSize < message.toByteArray().size) {
                Log.e(TAG, "Tag size is too small")
                return false
            }
            ndef.writeNdefMessage(message)
            ndef.close()
            return true
        } catch (e: IOException) {
            Log.e(TAG, "Error writing to NFC tag", e)
            return false
        }
    }

    fun createTextRecord(text: String, locale: String = "en"): NdefRecord {
        val langBytes = locale.toByteArray(Charset.forName("US-ASCII"))
        val textBytes = text.toByteArray(Charset.forName("UTF-8"))
        val utfBit = 0
        val status = (utfBit + langBytes.size).toByte()
        val data = ByteArray(1 + langBytes.size + textBytes.size)
        data[0] = status
        System.arraycopy(langBytes, 0, data, 1, langBytes.size)
        System.arraycopy(textBytes, 0, data, 1 + langBytes.size, textBytes.size)

        return NdefRecord(NdefRecord.TNF_WELL_KNOWN, NdefRecord.RTD_TEXT, ByteArray(0), data)
    }

    fun createUriRecord(uri: String): NdefRecord {
        return NdefRecord.createUri(uri)
    }

    fun createEmptyRecord(): NdefRecord {
        return NdefRecord(NdefRecord.TNF_EMPTY, ByteArray(0), ByteArray(0), ByteArray(0))
    }

    fun parseNdefMessage(message: NdefMessage): List<String> {
        val results = mutableListOf<String>()

        for (record in message.records) {
            when {
                record.tnf == NdefRecord.TNF_WELL_KNOWN -> {
                    when {
                        record.type.contentEquals(NdefRecord.RTD_TEXT) -> {
                            val text = parseTextRecord(record)
                            if (text.isNotEmpty()) {
                                results.add("text: $text")
                            }
                        }
                        record.type.contentEquals(NdefRecord.RTD_URI) -> {
                            val uri = parseUriRecord(record)
                            if (uri.isNotEmpty()) {
                                results.add("url: $uri")
                            }
                        }
                    }
                }
            }
        }

        return results
    }

    private fun parseTextRecord(record: NdefRecord): String {
        return try {
            val payload = record.payload
            if (payload.isEmpty()) return ""

            val languageCodeLength = payload[0].toInt() and 0x3F
            val textData = ByteArray(payload.size - languageCodeLength - 1)
            System.arraycopy(payload, languageCodeLength + 1, textData, 0, textData.size)

            String(textData, Charset.forName("UTF-8"))
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing text record", e)
            ""
        }
    }

    private fun parseUriRecord(record: NdefRecord): String {
        return try {
            val payload = record.payload
            if (payload.isEmpty()) return ""

            val prefixCode = payload[0].toInt() and 0xFF
            val uriData = ByteArray(payload.size - 1)
            System.arraycopy(payload, 1, uriData, 0, uriData.size)

            val prefix = getUriPrefix(prefixCode)
            prefix + String(uriData, Charset.forName("UTF-8"))
        } catch (e: Exception) {
            Log.e(TAG, "Error parsing URI record", e)
            ""
        }
    }

    private fun getUriPrefix(prefixCode: Int): String {
        return when (prefixCode) {
            0x01 -> "http://www."
            0x02 -> "https://www."
            0x03 -> "http://"
            0x04 -> "https://"
            0x05 -> "tel:"
            0x06 -> "mailto:"
            else -> ""
        }
    }

    fun getTagCapacity(tag: Tag): Int {
        val ndef = Ndef.get(tag)
        return ndef?.maxSize ?: 0
    }

    fun isTagWritable(tag: Tag): Boolean {
        val ndef = Ndef.get(tag)
        return ndef?.isWritable ?: false
    }
}