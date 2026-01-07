package com.uteshpa.nuyna.nuyna

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val MEDIAPIPE_CHANNEL = "com.nuyna.mediapipe/hands"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, MEDIAPIPE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "detectHandLandmarks" -> {
                    handleDetectHandLandmarks(call, result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    /**
     * Handle detectHandLandmarks method call
     * Returns dummy landmark data for testing purposes
     */
    private fun handleDetectHandLandmarks(call: io.flutter.plugin.common.MethodCall, result: MethodChannel.Result) {
        // In production, this would integrate with the actual MediaPipe SDK
        // For now, return dummy landmarks for testing the Platform Channel integration
        
        // 21 hand landmarks with dummy normalized coordinates (0.0-1.0)
        val dummyLandmarks = listOf(
            listOf(0.5, 0.8),    // 0: WRIST
            listOf(0.45, 0.75), // 1: THUMB_CMC
            listOf(0.40, 0.70), // 2: THUMB_MCP
            listOf(0.35, 0.65), // 3: THUMB_IP
            listOf(0.30, 0.60), // 4: THUMB_TIP
            listOf(0.45, 0.55), // 5: INDEX_FINGER_MCP
            listOf(0.45, 0.45), // 6: INDEX_FINGER_PIP
            listOf(0.45, 0.35), // 7: INDEX_FINGER_DIP
            listOf(0.45, 0.25), // 8: INDEX_FINGER_TIP
            listOf(0.50, 0.55), // 9: MIDDLE_FINGER_MCP
            listOf(0.50, 0.43), // 10: MIDDLE_FINGER_PIP
            listOf(0.50, 0.33), // 11: MIDDLE_FINGER_DIP
            listOf(0.50, 0.23), // 12: MIDDLE_FINGER_TIP
            listOf(0.55, 0.57), // 13: RING_FINGER_MCP
            listOf(0.55, 0.47), // 14: RING_FINGER_PIP
            listOf(0.55, 0.37), // 15: RING_FINGER_DIP
            listOf(0.55, 0.27), // 16: RING_FINGER_TIP
            listOf(0.60, 0.60), // 17: PINKY_MCP
            listOf(0.60, 0.52), // 18: PINKY_PIP
            listOf(0.60, 0.44), // 19: PINKY_DIP
            listOf(0.60, 0.36)  // 20: PINKY_TIP
        )

        // Return as array of hand results (single hand for demo)
        val handResult = mapOf(
            "landmarks" to dummyLandmarks,
            "handSize" to 0.15,
            "confidence" to 0.95
        )

        // Return list of hands (could be multiple)
        result.success(listOf(handResult))
    }
}
