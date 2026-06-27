package com.example.modern_upi_plugin

import android.app.Activity
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** ModernUpiPlugin */
class ModernUpiPlugin : FlutterPlugin, MethodCallHandler, ActivityAware, PluginRegistry.ActivityResultListener {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null
    private val UPI_REQUEST_CODE = 89012

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "modern_upi_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "startTransaction") {
            val app = call.argument<String>("app")
            val receiverUpiId = call.argument<String>("receiverUpiId")
            val receiverName = call.argument<String>("receiverName")
            val transactionRefId = call.argument<String>("transactionRefId")
            val transactionNote = call.argument<String>("transactionNote")
            val amount = call.argument<String>("amount")

            if (receiverUpiId == null || receiverName == null || amount == null) {
                result.error("INVALID_ARGS", "Missing required parameters", null)
                return
            }

            var uriString = "upi://pay?pa=$receiverUpiId&pn=${Uri.encode(receiverName)}&am=${Uri.encode(amount)}&cu=INR"
            if (transactionNote != null) uriString += "&tn=${Uri.encode(transactionNote)}"
            if (transactionRefId != null) uriString += "&tr=${Uri.encode(transactionRefId)}"
            
            val uri = Uri.parse(uriString)
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = uri
            
            if (app != null) {
                intent.setPackage(app)
            }

            if (activity != null) {
                pendingResult = result
                try {
                    activity!!.startActivityForResult(intent, UPI_REQUEST_CODE)
                } catch (e: android.content.ActivityNotFoundException) {
                    result.error("APP_NOT_FOUND", "No UPI app found", null)
                    pendingResult = null
                }
            } else {
                result.error("NO_ACTIVITY", "Activity is not available", null)
            }
        } else {
            result.notImplemented()
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == UPI_REQUEST_CODE) {
            val result = pendingResult
            pendingResult = null

            if (result != null) {
                if (data != null) {
                    val response = data.getStringExtra("response")
                    if (response != null) {
                        result.success(response)
                    } else {
                        result.error("NULL_RESPONSE", "No response from UPI app", null)
                    }
                } else {
                    result.error("USER_CANCELED", "User canceled the transaction", null)
                }
            }
            return true
        }
        return false
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
