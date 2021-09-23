package com.example.chatapp

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MyRadarReceiver: BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        println("works! Something was received")
    }
}