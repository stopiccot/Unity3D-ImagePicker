package com.imagepicker;

import android.Manifest;
import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.Intent;
import android.net.Uri;
import android.os.Debug;
import android.database.Cursor;
import android.provider.MediaStore;
import android.support.v4.app.ActivityCompat;
import android.content.pm.PackageManager;
import android.os.Environment;
import android.content.ContentUris;
import android.util.Log;
import android.support.v4.content.FileProvider;

import java.io.File;
import java.util.UUID;
import java.io.IOException;

public class ImagePickerModule implements ActivityEventListener {

    static final int REQUEST_LAUNCH_IMAGE_CAPTURE = 13001;
    static final int REQUEST_LAUNCH_IMAGE_LIBRARY = 13002;
    static final int REQUEST_LAUNCH_VIDEO_LIBRARY = 13003;
    static final int REQUEST_LAUNCH_VIDEO_CAPTURE = 13004;

    private static ImagePickerModule instance = null;

    public static ImagePickerModule getInstance() {
        if (instance == null) {
            instance = new ImagePickerModule();
            CustomUnityPlayerActivity.getInstance().addActivityEventListener(instance);
        }

        return instance;
    }

    private Activity currentActivity = null;

    public void setCurrentActivity(Activity activity) {
        currentActivity = activity;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        Log.d("ImagePickerPlugin", "onActivityResult");
        if (requestCode == REQUEST_LAUNCH_IMAGE_CAPTURE) {
            Log.d("ImagePickerPlugin", "REQUEST_LAUNCH_IMAGE_CAPTURE");

            Log.d("ImagePickerPlugin", "uri 1");
            Log.d("ImagePickerPlugin", mCameraCaptureURI.toString());
            Log.d("ImagePickerPlugin", "uri 2");
            Log.d("ImagePickerPlugin", mCameraCaptureFileURI.toString());

            launchCameraCallback.actuallyCall(mCameraCaptureFileURI.toString());
        }
    }

    public interface Callback {
        void actuallyCall(String path);
    }

    private boolean isCameraAvailable() {
        return currentActivity.getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA)
                || currentActivity.getPackageManager().hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY);
    }

    private boolean permissionsCheck(Activity activity) {
        int writePermission = ActivityCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE);
        int cameraPermission = ActivityCompat.checkSelfPermission(activity, Manifest.permission.CAMERA);
        if (writePermission != PackageManager.PERMISSION_GRANTED || cameraPermission != PackageManager.PERMISSION_GRANTED) {
            String[] PERMISSIONS = {
                    Manifest.permission.WRITE_EXTERNAL_STORAGE,
                    Manifest.permission.CAMERA
            };
            ActivityCompat.requestPermissions(activity, PERMISSIONS, 1);
            return false;
        }
        return true;
    }

    private Uri mCameraCaptureURI;
    private Uri mCameraCaptureFileURI;
    protected Callback launchCameraCallback;

    public void launchCamera(Callback callback) {
        Log.d("ImagePickerPlugin", "launchCamera - 1");
        launchCameraCallback = callback;

        if (!isCameraAvailable()) {
            Log.d("ImagePickerPlugin", "cameraIsNotAvailable");
            return;
        }

        Log.d("ImagePickerPlugin", "launchCamera - 2");

        if (currentActivity == null) {
            Log.d("ImagePickerPlugin", "activity is null");
            return;
        }

        Log.d("ImagePickerPlugin", currentActivity.toString());

        Log.d("ImagePickerPlugin", "launchCamera - 3");

        if (!permissionsCheck(currentActivity)) {
            Log.d("ImagePickerPlugin", "no permissions");
            return;
        }

        Log.d("ImagePickerPlugin", "launchCamera - 4");

        int requestCode;
        Intent cameraIntent;
        boolean pickVideo = false;
        if (pickVideo) {
            requestCode = REQUEST_LAUNCH_VIDEO_CAPTURE;
            cameraIntent = new Intent(MediaStore.ACTION_VIDEO_CAPTURE);
//            cameraIntent.putExtra(MediaStore.EXTRA_VIDEO_QUALITY, videoQuality);
//            if (videoDurationLimit > 0) {
//                cameraIntent.putExtra(MediaStore.EXTRA_DURATION_LIMIT, videoDurationLimit);
//            }
        } else {
            requestCode = REQUEST_LAUNCH_IMAGE_CAPTURE;
            cameraIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);

            // we create a tmp file to save the result
            File imageFile = null;
            try {
                imageFile = createNewFile();
            } catch (IOException ex) {
                Log.d("ImagePickerPlugin", "failed to create temp file");
            }

            mCameraCaptureFileURI = Uri.fromFile(imageFile);
            mCameraCaptureURI = FileProvider.getUriForFile(currentActivity,
                    "com.example.android.fileprovider",
                    imageFile);
            cameraIntent.putExtra(MediaStore.EXTRA_OUTPUT, mCameraCaptureURI);
        }

        Log.d("ImagePickerPlugin", "launchCamera - 5");

        if (cameraIntent.resolveActivity(currentActivity.getPackageManager()) == null) {
            Log.d("ImagePickerPlugin", "failed to resolve activity");
            return;
        }

        Log.d("ImagePickerPlugin", "launchCamera - 6");

        try {
            currentActivity.startActivityForResult(cameraIntent, requestCode);
        } catch (ActivityNotFoundException e) {
            e.printStackTrace();
        }

        Log.d("ImagePickerPlugin", "launchCamera - 7");
    }

    private File createNewFile() throws IOException  {
        String filename = "image-" + UUID.randomUUID().toString();

        File storageDir = currentActivity.getExternalFilesDir(Environment.DIRECTORY_PICTURES);

        File image = File.createTempFile(
                filename,  /* prefix */
                ".jpg",         /* suffix */
                storageDir      /* directory */
        );

        return image;
    }
}
