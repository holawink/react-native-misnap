
package com.omni.misnap;

import android.app.Activity;
import android.content.Intent;
import android.util.Base64;

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


import com.miteksystems.facialcapture.science.api.params.FacialCaptureApi;
import com.miteksystems.facialcapture.workflow.FacialCaptureWorkflowActivity;
import com.miteksystems.facialcapture.workflow.params.FacialCaptureWorkflowParameters;
import com.miteksystems.misnap.params.CameraApi;
import com.miteksystems.misnap.params.MiSnapApi;
import com.miteksystems.misnap.utils.Utils;


import com.miteksystems.misnap.misnapworkflow_UX2.MiSnapWorkflowActivity_UX2;
import com.miteksystems.misnap.misnapworkflow_UX2.params.WorkflowApi;
import com.miteksystems.misnap.params.CameraApi;
import com.miteksystems.misnap.params.MiSnapApi;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;
import java.util.HashMap;


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
    promise.resolve("HELLO FROM ANDROID NATIVE CODE");
  }

  @ReactMethod
  public void capture(ReadableMap config, Promise promise) {
     Activity currentActivity = getCurrentActivity();
    currentPromise = promise;

    String captureType = config.hasKey("captureType") ?
        config.getString("captureType") : "idFront";

    String licenseKey = config.hasKey("livenessLicenseKey") ? config.getString("livenessLicenseKey") : "";

    if (captureType.equals("idFront") || captureType.equals("idBack")) {

      JSONObject misnapParams = new JSONObject();
      
      try {
        misnapParams.put(MiSnapApi.MiSnapDocumentType, (captureType.equals("idFront")) ? MiSnapApi.PARAMETER_DOCTYPE_ID_CARD_FRONT : MiSnapApi.PARAMETER_DOCTYPE_ID_CARD_BACK);
        misnapParams.put(CameraApi.MiSnapAllowScreenshots, 1);
        misnapParams.put(WorkflowApi.MiSnapTrackGlare, WorkflowApi.TRACK_GLARE_ENABLED);
        misnapParams.put(CameraApi.MiSnapFocusMode, CameraApi.PARAMETER_FOCUS_MODE_HYBRID);
        misnapParams.put(MiSnapApi.MiSnapOrientation, 1);
      } catch (JSONException exception) {
        exception.printStackTrace();
      }

      Intent intentMiSnap;
      intentMiSnap = new Intent(currentActivity, MiSnapWorkflowActivity_UX2.class);
      intentMiSnap.putExtra(MiSnapApi.JOB_SETTINGS, misnapParams.toString());

      if(intentMiSnap != null ){
          currentActivity.startActivityForResult(intentMiSnap, MiSnapApi.RESULT_PICTURE_CODE);
      }

      // HashMap<String, String> hm = new HashMap<>();
      // hm.put("base64encodedImage", "Hello From Native");
      // WritableMap map = new WritableNativeMap();
      // for (Map.Entry<String, String> entry : hm.entrySet()) {
      //     map.putString(entry.getKey(), entry.getValue());
      // }
      // promise.resolve(map);

    } else if (captureType.equals("face")) {
      JSONObject faceCaptureParams = new JSONObject();
      try {
        faceCaptureParams.put(FacialCaptureApi.FacialCaptureLicenseKey, licenseKey);
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
        byte[] image = intent.getByteArrayExtra(MiSnapApi.RESULT_PICTURE_DATA);
        String encoded = Base64.encodeToString(image, Base64.DEFAULT);

        HashMap<String, String> hm = new HashMap<>();
        hm.put("base64encodedImage", encoded);
        WritableMap map = new WritableNativeMap();
        for (Map.Entry<String, String> entry : hm.entrySet()) {
            map.putString(entry.getKey(), entry.getValue());
        }
        currentPromise.resolve(map);
      }
    }
  }

  @ReactMethod
  public void getResults(Promise promise) {
    currentPromise = promise;
  }
}