package com.example.youtube_downloader

import android.content.ActivityNotFoundException
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException

class MainActivity : FlutterActivity() {

    private var ytDlpBridge: YtDlpBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ytDlpBridge = YtDlpBridge(this, flutterEngine.dartExecutor.binaryMessenger)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "saveToDownloads" -> saveToDownloads(call, result)
                    "openUri" -> openUri(call, result)
                    else -> result.notImplemented()
                }
            }
    }

    /** Copies a temp file into Downloads/YouTube Downloader using MediaStore. */
    private fun saveToDownloads(call: MethodCall, result: MethodChannel.Result) {
        val sourcePath = call.argument<String>("sourcePath")
        val fileName = call.argument<String>("fileName")
        val mimeType = call.argument<String>("mimeType")
        if (sourcePath == null || fileName == null || mimeType == null) {
            result.error("bad_args", "Missing arguments", null)
            return
        }

        // Copying can be large, so keep it off the main thread.
        Thread {
            try {
                val uri = copyToMediaStore(File(sourcePath), fileName, mimeType)
                runOnUiThread { result.success(uri.toString()) }
            } catch (e: Exception) {
                runOnUiThread { result.error("save_failed", e.message ?: "Could not save the file", null) }
            }
        }.start()
    }

    private fun copyToMediaStore(source: File, fileName: String, mimeType: String): Uri {
        val resolver = contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, fileName)
            put(MediaStore.Downloads.MIME_TYPE, mimeType)
            put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS + "/YouTube Downloader")
            put(MediaStore.Downloads.IS_PENDING, 1)
        }
        val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
            ?: throw IOException("Could not create the file in Downloads")

        try {
            val output = resolver.openOutputStream(uri)
                ?: throw IOException("Could not open the output file")
            output.use { out -> source.inputStream().use { it.copyTo(out) } }

            values.clear()
            values.put(MediaStore.Downloads.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
            return uri
        } catch (e: Exception) {
            resolver.delete(uri, null, null)
            throw e
        }
    }

    private fun openUri(call: MethodCall, result: MethodChannel.Result) {
        val uri = call.argument<String>("uri")
        val mimeType = call.argument<String>("mimeType")
        if (uri == null || mimeType == null) {
            result.error("bad_args", "Missing arguments", null)
            return
        }
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(Uri.parse(uri), mimeType)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        try {
            startActivity(intent)
            result.success(true)
        } catch (e: ActivityNotFoundException) {
            result.success(false)
        } catch (e: SecurityException) {
            result.success(false)
        }
    }

    companion object {
        private const val CHANNEL = "com.example.youtube_downloader/storage"
    }
}
