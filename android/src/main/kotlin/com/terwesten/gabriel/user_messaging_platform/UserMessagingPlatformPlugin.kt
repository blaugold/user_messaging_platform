package com.terwesten.gabriel.user_messaging_platform

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import com.google.android.ump.ConsentInformation
import com.google.android.ump.ConsentRequestParameters
import com.google.android.ump.FormError
import com.google.android.ump.UserMessagingPlatform

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** UserMessagingPlatformPlugin */
class UserMessagingPlatformPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.terwesten.gabriel/user_messaging_platform")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "getConsentInfo" -> sendConsentInfo(result)
            "requestConsentInfoUpdate" -> requestConsentInfoUpdate(result)
            "showConsentForm" -> showConsentForm(result)
            "resetConsentInfo" -> resetConsentInfo(result)
            else -> result.notImplemented()
        }
    }

    private val consentInformation
        get() = UserMessagingPlatform.getConsentInformation(context)!!

    private fun requestConsentInfoUpdate(result: Result) {
        val params = ConsentRequestParameters.Builder().build()

        consentInformation.requestConsentInfoUpdate(
                activity,
                params,
                { sendConsentInfo(result) },
                { handleFormError(result, it) }
        )
    }

    private fun showConsentForm(result: Result) {
        UserMessagingPlatform.loadConsentForm(
                context,
                { form ->
                    form.show(activity) {
                        when (it) {
                            null -> sendConsentInfo(result)
                            else -> handleFormError(result, it)
                        }
                    }
                },
                { handleFormError(result, it) }
        )
    }

    private fun resetConsentInfo(result: Result) {
        consentInformation.reset()
        result.success(null)
    }

    private fun sendConsentInfo(result: Result) {
        result.success(serializeContentInfo(consentInformation))
    }

    private fun handleFormError(result: Result, it: FormError) {
        result.error(serializeFormErrorCode(it.errorCode), it.message, null)
    }
}

private fun serializeContentInfo(consentInformation: ConsentInformation): Map<String, String> =
        mapOf(
                "consentStatus" to serializeConsentStatus(consentInformation.consentStatus),
                "consentType" to serializeConsentType(consentInformation.consentType),
                "formStatus" to serializeFormStatus(consentInformation)
        )

private fun serializeConsentStatus(consentStatus: Int): String = when (consentStatus) {
    ConsentInformation.ConsentStatus.UNKNOWN -> "unknown"
    ConsentInformation.ConsentStatus.NOT_REQUIRED -> "notRequired"
    ConsentInformation.ConsentStatus.REQUIRED -> "required"
    ConsentInformation.ConsentStatus.OBTAINED -> "obtained"
    else -> throw IllegalArgumentException("Unknown ConsentStatus: $consentStatus")
}

private fun serializeConsentType(consentType: Int): String = when (consentType) {
    ConsentInformation.ConsentType.UNKNOWN -> "unknown"
    ConsentInformation.ConsentType.PERSONALIZED -> "personalized"
    ConsentInformation.ConsentType.NON_PERSONALIZED -> "nonPersonalized"
    else -> throw IllegalArgumentException("Unknown ConsentType: $consentType")
}


fun serializeFormStatus(consentInformation: ConsentInformation): String = when {
    consentInformation.isConsentFormAvailable -> "available"
    else -> "unavailable"
}

fun serializeFormErrorCode(errorCode: Int): String = when (errorCode) {
    FormError.ErrorCode.INTERNAL_ERROR -> "internal"
    FormError.ErrorCode.INTERNET_ERROR -> "network"
    FormError.ErrorCode.INVALID_OPERATION -> "invalidOperation"
    FormError.ErrorCode.TIME_OUT -> "timeout"
    else -> throw IllegalArgumentException("Unknown FormErrorCode: $errorCode")
}