package com.nfctools

import android.app.PendingIntent
import android.content.Intent
import android.content.IntentFilter
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.os.Bundle
import android.util.Log
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdSize
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.MobileAds
import com.nfctools.databinding.ActivityMainBinding

class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private var nfcAdapter: NfcAdapter? = null
    private var pendingIntent: PendingIntent? = null
    private var intentFiltersArray: Array<IntentFilter>? = null
    private var techListsArray: Array<Array<String>>? = null
    private var currentState = NFCUtils.NFCState.STANDBY
    private var adView: AdView? = null
    private var writeText: String = ""

    companion object {
        private const val TAG = "MainActivity"
        private const val PREFS_NAME = "NFCToolsPrefs"
        private const val FIRST_LAUNCH_KEY = "firstLaunch"
        private const val AD_REMOVED_KEY = "adRemoved"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupNFC()
        setupClickListeners()
        setupAdvertisement()
        checkFirstLaunch()
    }

    private fun setupNFC() {
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)

        if (nfcAdapter == null) {
            Toast.makeText(this, LocalizationManager.getLocalizedMessage("nfc_not_supported"), Toast.LENGTH_LONG).show()
            return
        }

        pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_MUTABLE
        )

        val ndef = IntentFilter(NfcAdapter.ACTION_NDEF_DISCOVERED)
        try {
            ndef.addDataType("*/*")
        } catch (e: IntentFilter.MalformedMimeTypeException) {
            throw RuntimeException("fail", e)
        }

        intentFiltersArray = arrayOf(ndef)
        techListsArray = arrayOf(arrayOf(Ndef::class.java.name))
    }

    private fun setupClickListeners() {
        binding.btnRead.setOnClickListener {
            startNFCSession(NFCUtils.NFCState.READ)
            showNFCDialog(LocalizationManager.getLocalizedMessage("nfc_bring_closer"))
        }

        binding.btnWrite.setOnClickListener {
            showWriteDialog()
        }

        binding.btnDelete.setOnClickListener {
            startNFCSession(NFCUtils.NFCState.DELETE)
            showNFCDialog(LocalizationManager.getLocalizedMessage("nfc_bring_closer"))
        }

        binding.btnOther.setOnClickListener {
            startActivity(Intent(this, SNSWriteActivity::class.java))
        }
    }

    private fun setupAdvertisement() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        val isAdRemoved = prefs.getBoolean(AD_REMOVED_KEY, false)

        if (!isAdRemoved) {
            MobileAds.initialize(this) {}

            adView = AdView(this)
            adView?.setAdSize(AdSize.BANNER)
            adView?.adUnitId = "ca-app-pub-1187210314934709/5463627829"

            binding.adBannerContainer.addView(adView)

            val adRequest = AdRequest.Builder().build()
            adView?.loadAd(adRequest)
        }
    }

    private fun checkFirstLaunch() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        val isFirstLaunch = prefs.getBoolean(FIRST_LAUNCH_KEY, true)

        if (isFirstLaunch) {
            prefs.edit().putBoolean(FIRST_LAUNCH_KEY, false).apply()
            startActivity(Intent(this, TutorialActivity::class.java))
        }
    }

    private fun startNFCSession(state: NFCUtils.NFCState) {
        currentState = state
        if (nfcAdapter?.isEnabled != true) {
            Toast.makeText(this, LocalizationManager.getLocalizedMessage("nfc_not_supported"), Toast.LENGTH_LONG).show()
            return
        }
    }

    private fun showNFCDialog(message: String) {
        AlertDialog.Builder(this)
            .setTitle("NFC")
            .setMessage(message)
            .setNegativeButton("キャンセル") { dialog, _ ->
                currentState = NFCUtils.NFCState.STANDBY
                dialog.dismiss()
            }
            .setCancelable(false)
            .show()
    }

    override fun onResume() {
        super.onResume()
        nfcAdapter?.enableForegroundDispatch(this, pendingIntent, intentFiltersArray, techListsArray)
    }

    override fun onPause() {
        super.onPause()
        nfcAdapter?.disableForegroundDispatch(this)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (NfcAdapter.ACTION_NDEF_DISCOVERED == intent.action ||
            NfcAdapter.ACTION_TAG_DISCOVERED == intent.action) {
            val tag = intent.getParcelableExtra<Tag>(NfcAdapter.EXTRA_TAG)
            tag?.let { handleNFCTag(it) }
        }
    }

    private fun handleNFCTag(tag: Tag) {
        when (currentState) {
            NFCUtils.NFCState.READ -> {
                handleReadOperation(tag)
            }
            NFCUtils.NFCState.DELETE -> {
                handleDeleteOperation(tag)
            }
            NFCUtils.NFCState.WRITE -> {
                handleWriteOperation(tag)
            }
            NFCUtils.NFCState.STANDBY -> {
                // Do nothing
            }
        }
        currentState = NFCUtils.NFCState.STANDBY
    }

    private fun handleReadOperation(tag: Tag) {
        val message = NFCUtils.readNdefTag(tag)
        if (message != null) {
            val results = NFCUtils.parseNdefMessage(message)
            if (results.isNotEmpty()) {
                val resultText = "[${results.joinToString(", ")}]"
                runOnUiThread {
                    AlertDialog.Builder(this)
                        .setTitle("読み取り結果")
                        .setMessage(resultText)
                        .setPositiveButton("OK") { dialog, _ -> dialog.dismiss() }
                        .show()
                }
            } else {
                runOnUiThread {
                    Toast.makeText(this, LocalizationManager.getLocalizedMessage("nfc_tag_not_supported"), Toast.LENGTH_LONG).show()
                }
            }
        } else {
            runOnUiThread {
                Toast.makeText(this, LocalizationManager.getLocalizedMessage("nfc_tag_not_supported"), Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun handleDeleteOperation(tag: Tag) {
        if (!NFCUtils.isTagWritable(tag)) {
            runOnUiThread {
                Toast.makeText(this, LocalizationManager.getLocalizedMessage("nfc_read_only"), Toast.LENGTH_LONG).show()
            }
            return
        }

        // Read current content first
        val currentMessage = NFCUtils.readNdefTag(tag)
        if (currentMessage != null) {
            val results = NFCUtils.parseNdefMessage(currentMessage)
            val msg = "[${results.joinToString(", ")}]"

            runOnUiThread {
                AlertDialog.Builder(this)
                    .setTitle("削除確認")
                    .setMessage(String.format(LocalizationManager.getLocalizedMessage("nfc_remove_alert"), msg))
                    .setPositiveButton("削除") { _, _ ->
                        performDelete(tag)
                    }
                    .setNegativeButton("キャンセル") { dialog, _ ->
                        dialog.dismiss()
                    }
                    .show()
            }
        } else {
            runOnUiThread {
                Toast.makeText(this, LocalizationManager.getLocalizedMessage("nfc_tag_not_supported"), Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun performDelete(tag: Tag) {
        val emptyRecord = NFCUtils.createEmptyRecord()
        val emptyMessage = NdefMessage(arrayOf(emptyRecord))

        if (NFCUtils.writeNdefTag(tag, emptyMessage)) {
            runOnUiThread {
                Toast.makeText(this, LocalizationManager.getLocalizedMessage("nfc_deleted"), Toast.LENGTH_SHORT).show()
            }
        } else {
            runOnUiThread {
                Toast.makeText(this, LocalizationManager.getLocalizedMessage("nfc_payload_fail"), Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun showWriteDialog() {
        val builder = AlertDialog.Builder(this)
        val input = android.widget.EditText(this)
        input.hint = LocalizationManager.getLocalizedMessage("enterTextOrURL")

        builder.setTitle(LocalizationManager.getLocalizedMessage("write"))
            .setView(input)
            .setPositiveButton(LocalizationManager.getLocalizedMessage("write")) { _, _ ->
                val text = input.text.toString().trim()
                if (text.isNotEmpty()) {
                    if (isValidUrl(text)) {
                        showUrlConfirmationDialog(text)
                    } else {
                        writeText = text
                        startNFCSession(NFCUtils.NFCState.WRITE)
                        showNFCDialog(LocalizationManager.getLocalizedMessage("writePrompt"))
                    }
                } else {
                    Toast.makeText(this, LocalizationManager.getLocalizedMessage("emptyText"), Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton(LocalizationManager.getLocalizedMessage("cancel")) { dialog, _ ->
                dialog.cancel()
            }
            .show()
    }

    private fun showUrlConfirmationDialog(url: String) {
        val builder = AlertDialog.Builder(this)
        builder.setTitle(LocalizationManager.getLocalizedMessage("urlConfirmation"))
            .setMessage(String.format(LocalizationManager.getLocalizedMessage("writeURLConfirmation"), url))
            .setPositiveButton(LocalizationManager.getLocalizedMessage("writeAsURL")) { _, _ ->
                writeText = url
                startNFCSession(NFCUtils.NFCState.WRITE)
                showNFCDialog(LocalizationManager.getLocalizedMessage("writePrompt"))
            }
            .setNeutralButton(LocalizationManager.getLocalizedMessage("writeAsText")) { _, _ ->
                writeText = url
                startNFCSession(NFCUtils.NFCState.WRITE)
                showNFCDialog(LocalizationManager.getLocalizedMessage("writePrompt"))
            }
            .setNegativeButton(LocalizationManager.getLocalizedMessage("cancel")) { dialog, _ ->
                dialog.cancel()
            }
            .show()
    }

    private fun isValidUrl(text: String): Boolean {
        return text.startsWith("http://") || text.startsWith("https://")
    }

    private fun handleWriteOperation(tag: Tag) {
        if (!NFCUtils.isTagWritable(tag)) {
            runOnUiThread {
                Toast.makeText(this, LocalizationManager.getLocalizedMessage("readOnlyError"), Toast.LENGTH_LONG).show()
            }
            return
        }

        val record = if (isValidUrl(writeText)) {
            NFCUtils.createUriRecord(writeText)
        } else {
            NFCUtils.createTextRecord(writeText, "ja")
        }

        val message = NdefMessage(arrayOf(record))
        val capacity = NFCUtils.getTagCapacity(tag)

        if (message.toByteArray().size > capacity) {
            runOnUiThread {
                Toast.makeText(this,
                    String.format(LocalizationManager.getLocalizedMessage("capacityOverflow"), capacity.toString()),
                    Toast.LENGTH_LONG).show()
            }
            return
        }

        if (NFCUtils.writeNdefTag(tag, message)) {
            runOnUiThread {
                val successMessage = if (isValidUrl(writeText)) {
                    LocalizationManager.getLocalizedMessage("urlWriteSuccess")
                } else {
                    LocalizationManager.getLocalizedMessage("textWriteSuccess")
                }
                Toast.makeText(this, "$successMessage: $writeText", Toast.LENGTH_LONG).show()
            }
        } else {
            runOnUiThread {
                Toast.makeText(this, LocalizationManager.getLocalizedMessage("writeError"), Toast.LENGTH_LONG).show()
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        adView?.destroy()
    }
}