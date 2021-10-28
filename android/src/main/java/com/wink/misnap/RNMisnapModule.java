
package com.wink.misnap;

import android.app.Activity;
import android.content.Intent;
import android.util.Base64;
import android.util.Log;
import android.os.Bundle;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.WritableNativeMap;
import com.facebook.react.bridge.WritableMap;

import static android.app.Activity.RESULT_OK;

import com.miteksystems.facialcapture.workflow.FacialCaptureWorkflowActivity;

import com.miteksystems.misnap.params.ScienceApi;
import com.miteksystems.misnap.utils.Utils;


import com.miteksystems.misnap.misnapworkflow_UX2.MiSnapWorkflowActivity_UX2;
import com.miteksystems.misnap.misnapworkflow_UX2.params.WorkflowApi;
import com.miteksystems.misnap.params.CameraApi;
import com.miteksystems.misnap.params.MiSnapApi;

// Facial resources
import com.miteksystems.facialcapture.workflow.params.FacialCaptureWorkflowApi;
import com.miteksystems.facialcapture.workflow.api.FacialCaptureResult;
// ... ///

import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Map;
import java.util.HashMap;
import java.util.UUID;


public class RNMisnapModule extends ReactContextBaseJavaModule implements ActivityEventListener {

  private final ReactApplicationContext reactContext;
  private Promise currentPromise;

  public RNMisnapModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    this.reactContext.addActivityEventListener(this);
  }

  @Override
  public String getName() {
    return "RNMisnap";
  }

  @ReactMethod
  public void greet(Promise promise) {
    promise.resolve("HELLO FROM ANDROID NATIVE CODE (3.0.0)");
  }

  @ReactMethod
  public void capture(ReadableMap config, Promise promise) {
    Activity currentActivity = getCurrentActivity();
    currentPromise = promise;

    String captureType = config.hasKey("captureType") 
      ? config.getString("captureType") 
      : "idFront";

    // Config parameters
    String licenseKey = config.hasKey("livenessLicenseKey") ? config.getString("livenessLicenseKey") : "";
    int glare = config.hasKey("glare") ? config.getInt("glare") : 670;
    int contrast = config.hasKey("contrast") ? config.getInt("contrast") : 550;
    int imageQuality = config.hasKey("imageQuality") ? config.getInt("imageQuality") : 65;

    // Log external parameters
    Log.d("RNMisnapModule", "Glare: " + glare);
    Log.d("RNMisnapModule", "Contrast: " + contrast);
    Log.d("RNMisnapModule", "ImageQuality: " + imageQuality);

    if (captureType.equals("idFront") || captureType.equals("idBack")) {

      JSONObject misnapParams = new JSONObject();
      
      try {
        misnapParams.put(MiSnapApi.MiSnapDocumentType, (captureType.equals("idFront")) ? MiSnapApi.PARAMETER_DOCTYPE_ID_CARD_FRONT : MiSnapApi.PARAMETER_DOCTYPE_ID_CARD_BACK);
        // External parameters
        misnapParams.put(ScienceApi.MiSnapNoGlare, glare );
        misnapParams.put(ScienceApi.MiSnapContrast, contrast );
        misnapParams.put(MiSnapApi.MiSnapImageQuality, imageQuality );

        // Other Parameters
        misnapParams.put(CameraApi.MiSnapAllowScreenshots, 1);
        misnapParams.put(CameraApi.MiSnapFocusMode, CameraApi.PARAMETER_FOCUS_MODE_HYBRID);
        misnapParams.put(MiSnapApi.MiSnapOrientation, 2);
      } catch (JSONException exception) {
        exception.printStackTrace();
      }

      Intent intentMiSnap;
      intentMiSnap = new Intent(currentActivity, MiSnapWorkflowActivity_UX2.class);
      intentMiSnap.putExtra(MiSnapApi.JOB_SETTINGS, misnapParams.toString());

      if(intentMiSnap != null ){
        currentActivity.startActivityForResult(intentMiSnap, MiSnapApi.RESULT_PICTURE_CODE);
      }

    } else if (captureType.equals("face")) {
      JSONObject faceCaptureParams = new JSONObject();
      try {
        // Comment line, was deprecated on version 3.* of misnap sdk
        // faceCaptureParams.put(FacialCaptureApi.FacialCaptureLicenseKey, licenseKey);
        faceCaptureParams.put(CameraApi.MiSnapAllowScreenshots, 1);
      } catch (JSONException e) {
        e.printStackTrace();
      }
      Intent intentFacialCapture = new Intent(currentActivity, FacialCaptureWorkflowActivity.class);
      intentFacialCapture.putExtra(MiSnapApi.JOB_SETTINGS, faceCaptureParams.toString());
      currentActivity.startActivityForResult(intentFacialCapture, MiSnapApi.RESULT_PICTURE_CODE);
    }
  }

  @Override
  public void onNewIntent(Intent intent) {}

  @Override
  public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent intent) {
    if (MiSnapApi.RESULT_PICTURE_CODE == requestCode) {
      if (RESULT_OK == resultCode) {
        FacialCaptureResult result = this.getResultFacialCapture(intent);

        byte[] image = result instanceof FacialCaptureResult.Success 
        ? this.getFacialImage(result)
        : intent.getByteArrayExtra(MiSnapApi.RESULT_PICTURE_DATA);

        String encoded = Base64.encodeToString(image, Base64.DEFAULT);
        String mibiData = intent.getStringExtra(MiSnapApi.RESULT_MIBI_DATA);

        HashMap<String, String> hm = new HashMap<>();
        hm.put("base64encodedImage", encoded);
        hm.put("metadata", mibiData);
        WritableMap map = new WritableNativeMap();
        for (Map.Entry<String, String> entry : hm.entrySet()) {
          map.putString(entry.getKey(), entry.getValue());
        }
        currentPromise.resolve(map);
      }
    }
  }

  // Get facial capture result
  // This will be handle what type of validation could be make
  protected FacialCaptureResult getResultFacialCapture (Intent intent) {
    Bundle extras = intent.getExtras();
    FacialCaptureResult result = extras.getParcelable(FacialCaptureWorkflowApi.FACIAL_CAPTURE_RESULT);
    return result;
  }

  // Method to get image face captured for FacilCpatureWorkflowApi
  // Create since android sdk 3.0
  protected byte[] getFacialImage(FacialCaptureResult result) {
    byte[] image = null;

    if (result instanceof FacialCaptureResult.Success) {
      image = ((FacialCaptureResult.Success) result).getImage(); 
    }
    return image;
  }

  @ReactMethod
  public void getResults(Promise promise) {
    currentPromise = promise;
  }

  public void storeImageToDocumentsDirectory(String image) throws IOException {
    Activity currentActivity = getCurrentActivity();
    File path = currentActivity.getFilesDir();
    File file = new File(path, UUID.randomUUID().toString());
    FileOutputStream stream = new FileOutputStream(file);
    try {
      stream.write(image.getBytes());
    } finally {
      stream.close();
    }
  }
}