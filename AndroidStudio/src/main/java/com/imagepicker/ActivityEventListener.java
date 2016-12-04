package com.imagepicker;

import android.app.Activity;
import android.content.Intent;

public interface ActivityEventListener {

  /**
   * Called when host (activity/service) receives an {@link Activity#onActivityResult} call.
   */
  void onActivityResult(int requestCode, int resultCode, Intent data);
}