package com.nfctools

import android.app.PendingIntent
import android.content.Intent
import android.content.IntentFilter
import android.nfc.NdefMessage
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.Ndef
import android.os.Bundle
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import com.google.android.gms.ads.AdRequest
import com.google.android.gms.ads.AdView
import com.google.android.gms.ads.MobileAds
import com.nfctools.databinding.ActivitySnsWriteBinding

class SNSWriteActivity : AppCompatActivity() {

    private lateinit var binding: ActivitySnsWriteBinding
    private var nfcAdapter: NfcAdapter? = null
    private var pendingIntent: PendingIntent? = null
    private var intentFiltersArray: Array<IntentFilter>? = null
    private var techListsArray: Array<Array<String>>? = null
    private var currentState = NFCUtils.NFCState.STANDBY
    private var writeText: String = ""
    private var adView: AdView? = null

    companion object {
        private const val TAG = "SNSWriteActivity"
        private const val PREFS_NAME = "NFCToolsPrefs"
        private const val AD_REMOVED_KEY = "adRemoved"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivitySnsWriteBinding.inflate(layoutInflater)
        setContentView(binding.root)

        setupNFC()
        setupClickListeners()
        setupAdvertisement()
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
        binding.btnInstagram.setOnClickListener {
            showUsernameDialog("Instagram", "https://www.instagram.com/")
        }

        binding.btnTwitter.setOnClickListener {
            showUsernameDialog("X (Twitter)", "https://twitter.com/")
        }

        binding.btnYoutube.setOnClickListener {
            showUsernameDialog("YouTube", "https://www.youtube.com/@", requiresHandle = true)
        }

        binding.btnFacebook.setOnClickListener {
            showUsernameDialog("Facebook", "https://www.facebook.com/")
        }

        binding.btnCustomText.setOnClickListener {
            showCustomTextDialog()
        }

        binding.btnBack.setOnClickListener {
            finish()
        }
    }

    private fun setupAdvertisement() {
        val prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        val isAdRemoved = prefs.getBoolean(AD_REMOVED_KEY, false)

        if (!isAdRemoved) {
            MobileAds.initialize(this) {}

            adView = AdView(this)
            adView?.setAdSize(com.google.android.gms.ads.AdSize.BANNER)
            adView?.adUnitId = "ca-app-pub-1187210314934709/5463627829"

            binding.adBannerContainer.addView(adView)

            val adRequest = AdRequest.Builder().build()
            adView?.loadAd(adRequest)
        }
    }

    private fun showUsernameDialog(platform: String, baseUrl: String, requiresHandle: Boolean = false) {
        val builder = AlertDialog.Builder(this)
        val input = android.widget.EditText(this)
        input.hint = "ユーザー名を入力"

        builder.setTitle("$platform ユーザー名")
            .setView(input)
            .setPositiveButton(LocalizationManager.getLocalizedMessage("write")) { _, _ ->
                val username = input.text.toString().trim()
                if (username.isNotEmpty()) {
                    val completeUrl = if (requiresHandle) {
                        "$baseUrl$username"
                    } else {
                        "$baseUrl$username"
                    }

                    writeText = completeUrl
                    currentState = NFCUtils.NFCState.WRITE
                    showNFCDialog("$platform URLを書き込みます\nNFCタグを近づけてください")
                } else {
                    Toast.makeText(this, "ユーザー名を入力してください", Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton(LocalizationManager.getLocalizedMessage("cancel")) { dialog, _ ->
                dialog.cancel()
            }
            .show()
    }

    private fun showCustomTextDialog() {
        val builder = AlertDialog.Builder(this)
        val input = android.widget.EditText(this)
        input.hint = LocalizationManager.getLocalizedMessage("enterTextOrURL")

        builder.setTitle(LocalizationManager.getLocalizedMessage("write"))
            .setView(input)
            .setPositiveButton(LocalizationManager.getLocalizedMessage("write")) { _, _ ->
                val text = input.text.toString().trim()
                if (text.isNotEmpty()) {
                    writeText = text
                    currentState = NFCUtils.NFCState.WRITE
                    showNFCDialog(LocalizationManager.getLocalizedMessage("writePrompt"))
                } else {
                    Toast.makeText(this, LocalizationManager.getLocalizedMessage("emptyText"), Toast.LENGTH_SHORT).show()
                }
            }
            .setNegativeButton(LocalizationManager.getLocalizedMessage("cancel")) { dialog, _ ->
                dialog.cancel()
            }
            .show()
    }

    private fun showNFCDialog(message: String) {
        AlertDialog.Builder(this)
            .setTitle("NFC書き込み")
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
        if (currentState == NFCUtils.NFCState.WRITE) {
            handleWriteOperation(tag)
        }
        currentState = NFCUtils.NFCState.STANDBY
    }

    private fun handleWriteOperation(tag: Tag) {
        if (!NFCUtils.isTagWritable(tag)) {
            runOnUiThread {
                Toast.makeText(this, LocalizationManager.getLocalizedMessage("readOnlyError"), Toast.LENGTH_LONG).show()
            }
            return
        }

        val record = NFCUtils.createUriRecord(writeText)
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
                Toast.makeText(this, "${LocalizationManager.getLocalizedMessage("urlWriteSuccess")}: $writeText",
                    Toast.LENGTH_LONG).show()
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