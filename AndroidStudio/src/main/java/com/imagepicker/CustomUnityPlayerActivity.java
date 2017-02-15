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
        instance = this;
        super.onCreate(savedInstanceState);
    }

    private final CopyOnWriteArraySet<ActivityResultListener> mActivityResultListeners = new CopyOnWriteArraySet<>();

    public void addActivityResultListener(ActivityResultListener listener) {
        mActivityResultListeners.add(listener);
    }

    public void removeActivityResultListener(ActivityResultListener listener) {
        mActivityResultListeners.remove(listener);
    }

    @Override protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        for (ActivityResultListener listener : mActivityResultListeners) {
            listener.onActivityResult(requestCode, resultCode, data);
        }
    }
}