package com.alburhan.mamulat

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import android.os.Build
import android.view.WindowManager
import androidx.core.view.WindowCompat

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Remove splash screen immediately for Android 12+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView ->
                // Remove splash screen view immediately
                splashScreenView.remove()
            }
        }
        
        // Set window to edge-to-edge
        WindowCompat.setDecorFitsSystemWindows(window, false)
        
        // Make status bar transparent
        window.statusBarColor = android.graphics.Color.TRANSPARENT
        window.navigationBarColor = android.graphics.Color.TRANSPARENT
    }
}
