package com.example.youtube_downloader

import android.app.Activity
import com.yausername.ffmpeg.FFmpeg
import com.yausername.youtubedl_android.YoutubeDL
import com.yausername.youtubedl_android.YoutubeDLRequest
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.util.concurrent.Executors

/**
 * Exposes yt-dlp (youtubedl-android) to Flutter.
 *
 * yt-dlp reads YouTube, Shorts, Facebook, Instagram, TikTok, X and ~1000 other sites.
 */
class YtDlpBridge(private val activity: Activity, messenger: BinaryMessenger) {

    private val channel = MethodChannel(messenger, CHANNEL)
    private val executor = Executors.newCachedThreadPool()
    private val noProgress: (Float, Long, String) -> Unit = { _, _, _ -> }
    private var initialized = false

    init {
        channel.setMethodCallHandler { call, result -> onCall(call, result) }
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> runAsync(result) { initEngine(); null }

            "getInfo" -> {
                val url = call.argument<String>("url")
                if (url == null) {
                    result.error("bad_args", "Missing url", null)
                    return
                }
                runAsync(result) { getInfo(url) }
            }

            "download" -> {
                val taskId = call.argument<String>("taskId")
                val url = call.argument<String>("url")
                val format = call.argument<String>("format")
                val audioOnly = call.argument<Boolean>("audioOnly") ?: false
                if (taskId == null || url == null || format == null) {
                    result.error("bad_args", "Missing arguments", null)
                    return
                }
                runAsync(result) { download(taskId, url, format, audioOnly) }
            }

            "cancel" -> {
                val taskId = call.argument<String>("taskId")
                runAsync(result) { taskId != null && YoutubeDL.getInstance().destroyProcessById(taskId) }
            }

            // Sites change often; this pulls the newest yt-dlp.
            // If this line fails to compile after a library upgrade, delete this branch.
            "update" -> runAsync(result) {
                initEngine()
                YoutubeDL.getInstance()
                    .updateYoutubeDL(activity.application, YoutubeDL.UpdateChannel.STABLE)
                    ?.toString() ?: "UNKNOWN"
            }

            else -> result.notImplemented()
        }
    }

    @Synchronized
    private fun initEngine() {
        if (initialized) return
        YoutubeDL.getInstance().init(activity.application)
        FFmpeg.getInstance().init(activity.application)
        initialized = true
    }

    private fun getInfo(url: String): String {
        initEngine()
        val request = YoutubeDLRequest(url).apply {
            addOption("--dump-single-json")
            addOption("--no-playlist")
            addOption("--no-warnings")
            addOption("--socket-timeout", "20")
        }
        val response = YoutubeDL.getInstance()
            .execute(request, "info-${System.nanoTime()}", noProgress)
        return response.out.lineSequence().lastOrNull { it.trimStart().startsWith("{") }
            ?: throw IllegalStateException("No information was returned for this link")
    }

    private fun download(
        taskId: String,
        url: String,
        format: String,
        audioOnly: Boolean,
    ): Map<String, String> {
        initEngine()
        val dir = File(activity.cacheDir, "ytdl").apply { mkdirs() }

        val request = YoutubeDLRequest(url).apply {
            addOption("--no-playlist")
            addOption("--no-mtime")
            addOption("--no-warnings")
            addOption("--concurrent-fragments", "4")
            addOption("-f", format)
            addOption("-o", File(dir, "$taskId.%(ext)s").absolutePath)
            if (audioOnly) {
                addOption("-x")
                addOption("--audio-format", "m4a")
            } else {
                addOption("--merge-output-format", "mp4")
            }
        }

        val onProgress: (Float, Long, String) -> Unit = { percent, eta, _ ->
            activity.runOnUiThread {
                channel.invokeMethod(
                    "progress",
                    mapOf("taskId" to taskId, "percent" to percent.toDouble(), "eta" to eta),
                )
            }
        }

        try {
            YoutubeDL.getInstance().execute(request, taskId, onProgress)
            val output = dir.listFiles()
                ?.filter {
                    it.name.startsWith("$taskId.") &&
                        !it.name.endsWith(".part") &&
                        !it.name.endsWith(".ytdl")
                }
                ?.maxByOrNull { it.length() }
                ?: throw IllegalStateException("The download finished but no file was created")
            return mapOf("path" to output.absolutePath, "extension" to output.extension)
        } catch (e: Exception) {
            dir.listFiles()?.filter { it.name.startsWith("$taskId.") }?.forEach { it.delete() }
            throw e
        }
    }

    private fun runAsync(result: MethodChannel.Result, work: () -> Any?) {
        executor.execute {
            try {
                val value = work()
                activity.runOnUiThread { result.success(value) }
            } catch (e: Exception) {
                activity.runOnUiThread { result.error("ytdlp_error", cleanMessage(e), null) }
            }
        }
    }

    /** yt-dlp prints long logs; keep only the useful "ERROR: ..." line. */
    private fun cleanMessage(e: Exception): String {
        val text = e.message ?: return "Unknown error"
        return text.lines().lastOrNull { it.contains("ERROR:") }
            ?.substringAfter("ERROR:")?.trim()
            ?: text.take(300)
    }

    companion object {
        private const val CHANNEL = "com.example.youtube_downloader/ytdlp"
    }
}
