package com.imagepicker;

import java.util.concurrent.CopyOnWriteArraySet;
import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
import android.util.Log;

import com.unity3d.player.UnityPlayerActivity;

public class CustomUnityPlayerActivity extends UnityPlayerActivity
{
    private static CustomUnityPlayerActivity instance = null;
    public static CustomUnityPlayerActivity getInstance() {
        return instance;
    }

    @Override protected void onCreate(Bundle savedInstanceState) {
        Log.d("CustomActivity", "onCreate");
        instance = this;
        super.onCreate(savedInstanceState);
    }

    private final CopyOnWriteArraySet<ActivityEventListener> mActivityEventListeners = new CopyOnWriteArraySet<>();

    public void addActivityEventListener(ActivityEventListener listener) {
        Log.d("CustomActivity", "addActivityEventListener");
        mActivityEventListeners.add(listener);
    }

    public void removeActivityEventListener(ActivityEventListener listener) {
        Log.d("CustomActivity", "removeActivityEventListener");
        mActivityEventListeners.remove(listener);
    }

    @Override protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d("CustomActivity", "onActivityResult");
        Log.d("CustomActivity", "Number of listeners: " + mActivityEventListeners.size());

        for (ActivityEventListener listener : mActivityEventListeners) {
            Log.d("CustomActivity", "sending onActivityResult callback");
            listener.onActivityResult(requestCode, resultCode, data);
        }
    }
}