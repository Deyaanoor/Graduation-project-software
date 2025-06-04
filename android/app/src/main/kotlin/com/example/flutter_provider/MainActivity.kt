package com.example.flutter_provider

import io.flutter.embedding.android.FlutterFragmentActivity
import androidx.core.view.WindowCompat
import android.os.Bundle

class MainActivity: FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        WindowCompat.setDecorFitsSystemWindows(window, false)
    }
}