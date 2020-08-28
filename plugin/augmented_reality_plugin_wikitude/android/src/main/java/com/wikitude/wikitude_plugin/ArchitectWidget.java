package com.wikitude.wikitude_plugin;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.location.Location;
import android.location.LocationListener;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.view.View;
import android.webkit.WebView;

import com.google.gson.Gson;
import com.wikitude.architect.ArchitectJavaScriptInterfaceListener;
import com.wikitude.architect.ArchitectStartupConfiguration;
import com.wikitude.architect.ArchitectView;
import com.wikitude.common.camera.CameraSettings.CameraFocusMode;
import com.wikitude.common.camera.CameraSettings.CameraPosition;
import com.wikitude.common.camera.CameraSettings.CameraResolution;
import com.wikitude.common.devicesupport.Feature;
import com.wikitude.common.permission.PermissionManager;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.plugin.platform.PlatformView;

import static io.flutter.plugin.common.MethodChannel.MethodCallHandler;


public class ArchitectWidget implements PlatformView, MethodCallHandler, ArchitectView.ArchitectWorldLoadedListener, ArchitectJavaScriptInterfaceListener, LocationListener {

    private static final String TAG = ArchitectWidget.class.getSimpleName();

    private Context context;
    private Registrar registrar;
    private ArchitectView architectView;
    private MethodChannel channel;
    private Result permissionResult;

    private Gson gson;
    private boolean captureScreenMode;
    private String captureScreenName;

    private EnumSet<Feature> features;

    private ILocationProvider locationProvider;
    private boolean useCustomLocation = false;

    private final PermissionManager permissionManager = ArchitectView.getPermissionManager();

    private static final int EXTERNAL_STORAGE_PERMISSION_REQUEST_CODE = 1;

    enum State {
        CREATED, POST_CREATED, RESUMED, PAUSED, DESTROYED
    }
    State state;

    @SuppressLint("SetJavaScriptEnabled")
    ArchitectWidget(Context context, Registrar registrar, int id, Object o) {
        this.context = context;
        this.registrar = registrar;

        gson = new Gson();

        WebView.setWebContentsDebuggingEnabled(true);

        String startConfiguration = gson.toJson(o);
        try {
            JSONObject jsonObject = new JSONObject(startConfiguration);
            /*
             * The ArchitectStartupConfiguration is required to call architectView.onCreate.
             * It controls the startup of the ArchitectView which includes camera settings,
             * the required device features to run the ArchitectView and the LicenseKey which
             * has to be set to enable an AR-Experience.
             */
            final ArchitectStartupConfiguration config = new ArchitectStartupConfiguration(); // Creates a config with its default values.
            config.setLicenseKey(jsonObject.getString("license_key")); // Has to be set, to get a trial license key visit http://www.wikitude.com/developer/licenses.

            JSONArray featuresJsonArray = jsonObject.getJSONArray("features");
            List<String> featuresList = new ArrayList<>();
            for(int i = 0; i < featuresJsonArray.length(); i++){
                featuresList.add(featuresJsonArray.getString(i));
            }
            features = FeaturesHelper.convertArFeatures(featuresList);

            if(!jsonObject.isNull("camera_position")) {
                switch (jsonObject.getString("camera_position")) {
                    case "back": config.setCameraPosition(CameraPosition.BACK);
                        break;
                    case "front": config.setCameraPosition(CameraPosition.FRONT);
                        break;
                    case "default": config.setCameraPosition(CameraPosition.DEFAULT);
                        break;
                }
            }

            if(!jsonObject.isNull("camera_resolution")) {
                switch (jsonObject.getString("camera_resolution")) {
                    case "sd_640x480": config.setCameraResolution(CameraResolution.SD_640x480);
                        break;
                    case "hd_1280x720": config.setCameraResolution(CameraResolution.HD_1280x720);
                        break;
                    case "full_hd_1920x1080": config.setCameraResolution(CameraResolution.FULL_HD_1920x1080);
                        break;
                    case "auto": config.setCameraResolution(CameraResolution.AUTO);
                        break;
                }
            }

            if(!jsonObject.isNull("camera_focus_mode")) {
                switch (jsonObject.getString("camera_focus_mode")) {
                    case "once": config.setCameraFocusMode(CameraFocusMode.ONCE);
                        break;
                    case "continuous": config.setCameraFocusMode(CameraFocusMode.CONTINUOUS);
                        break;
                    case "off": config.setCameraFocusMode(CameraFocusMode.OFF);
                        break;
                }
            }

            config.setOrigin(ArchitectStartupConfiguration.ORIGIN_FLUTTER);

            architectView = new ArchitectView(context);
            architectView.onCreate(config); // create ArchitectView with configuration
            state = State.CREATED;
        } catch (Throwable t) {
            Log.e(TAG, "Malformed JSON");
        }

        channel = new MethodChannel(registrar.messenger(), "architectwidget_" + id);
        channel.setMethodCallHandler(this);
    }

    @Override
    public View getView() {
        return architectView;
    }

    @Override
    public void dispose() {

    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        switch (call.method) {
            case "load":
                if (state == State.CREATED) {
                    architectView.onPostCreate();
                    state = State.POST_CREATED;
                }
                String url = call.arguments.toString();
                if(!url.contains("https://") && !url.contains("http://") && !url.startsWith("file://")
                        && !url.startsWith(context.getFilesDir().getAbsolutePath())) {
                    url = registrar.lookupKeyForAsset(url);
                } else if (url.startsWith(context.getFilesDir().getAbsolutePath())) {
                    url = "file://" + url;
                }

                architectView.registerWorldLoadedListener(this);

                try {
                    architectView.load(url);
                } catch (IOException e) {
                    Log.e(TAG, "Load failed");
                }
                break;
            case "onResume":
                if (state == State.POST_CREATED || state == State.PAUSED) {
                    architectView.onResume();
                    state = State.RESUMED;

                    if(features.contains(Feature.GEO)) {
                        if(this.locationProvider == null) {
                            this.locationProvider = new LocationProvider(context, this);
                        }
                        this.locationProvider.onResume();
                    }
                } else {
                    Log.e(TAG, "Resume failed. Please, make sure everything is initialized properly.");
                }
                break;
            case "onPause":
                if (state == State.RESUMED) {
                    if(locationProvider != null) {
                        locationProvider.onPause();
                    }
                    architectView.onPause();
                    state = State.PAUSED;
                } else {
                    Log.e(TAG, "Resume needs to be called before pause is called in the appropriate lifecycle method.");
                }
                break;
            case "onDestroy":
                if (state == State.PAUSED) {
                    architectView.clearCache();
                    architectView.onDestroy();
                    state = State.DESTROYED;
                } else {
                    Log.e(TAG, "Pause needs to be called before destroy is called in the appropriate lifecycle method.");
                }
                break;
            case "setLocation":
                useCustomLocation = true;
                String startConfiguration = gson.toJson(call.arguments);
                try {
                    JSONObject jsonObject = new JSONObject(startConfiguration);
                    double lat = jsonObject.getDouble("lat");
                    double lon = jsonObject.getDouble("lon");
                    double alt = jsonObject.getDouble("alt");
                    double accuracy = jsonObject.getDouble("accuracy");
                    if(alt <= 0) {
                        architectView.setLocation(lat, lon, accuracy);
                    } else {
                        architectView.setLocation(lat, lon, alt, (float)accuracy);
                    }
                } catch (Throwable t) {
                    Log.e(TAG, "Malformed JSON");
                }
                break;
            case "callJavascript":
                architectView.callJavascript(call.arguments.toString());
                break;
            case "addArchitectJavaScriptInterfaceListener":
                architectView.addArchitectJavaScriptInterfaceListener(this);
                break;
            case "captureScreen":
                permissionResult = result;
                String captureScreenOptions = gson.toJson(call.arguments);
                try {
                    JSONObject jsonObject = new JSONObject(captureScreenOptions);
                    boolean mode = jsonObject.getBoolean("mode");
                    String name = jsonObject.getString("name");
                    permissionRequest(new String[] {Manifest.permission.WRITE_EXTERNAL_STORAGE}, EXTERNAL_STORAGE_PERMISSION_REQUEST_CODE, mode, name);
                } catch (Throwable t) {
                    Log.e(TAG, "Malformed JSON");
                }
                break;
            default:
                result.notImplemented();
        }
    }

    private void permissionRequest(String[] permissions, int requestCode, boolean mode, String name) {
        captureScreenMode = mode;
        captureScreenName = name;
        permissionManager.checkPermissions((Activity)context, permissions, requestCode, new PermissionManager.PermissionManagerCallback() {
            @Override
            public void permissionsGranted(int i) {
                captureScreen();
            }

            @Override
            public void permissionsDenied(String[] strings) {
                Response response = new Response(false, PermissionUtil.getPermissionErrorText(strings).toString());
                permissionResult.success(gson.toJson(response));
            }

            @Override
            public void showPermissionRationale(int i, String[] strings) {
                Response response = new Response(false, PermissionUtil.getPermissionErrorText(strings).toString());
                permissionResult.success(gson.toJson(response));
            }
        });
    }

    void captureScreen() {
        int captureMode = ArchitectView.CaptureScreenCallback.CAPTURE_MODE_CAM_AND_WEBVIEW;
        if(!captureScreenMode) {
            captureMode = ArchitectView.CaptureScreenCallback.CAPTURE_MODE_CAM;
        }
        architectView.captureScreen(captureMode, new ArchitectView.CaptureScreenCallback() {
            @Override
            public void onScreenCaptured(Bitmap bitmap) {
                try {
                    String imageName = System.currentTimeMillis() + ".jpg";
                    if (!captureScreenName.isEmpty()) {
                        if (captureScreenName.contains(".")) {
                            imageName = captureScreenName;
                        } else {
                            imageName = captureScreenName + ".jpg";
                        }
                    }

                    File externalPicturesDirectory = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES);
                    File captureScreenImage = new File(externalPicturesDirectory, imageName);
                    if (captureScreenImage.exists()) {
                        captureScreenImage.delete();
                    }
                    captureScreenImage.createNewFile();

                    final FileOutputStream out = new FileOutputStream(captureScreenImage);
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 90, out);
                    out.close();

                    Response response = new Response(true, captureScreenImage.getAbsolutePath());
                    permissionResult.success(gson.toJson(response));
                } catch (Exception e) {
                    Response response = new Response(false, e.getMessage());
                    permissionResult.success(gson.toJson(response));
                }
            }
        });
    }

    void captureScreenError(String error) {
        Response response = new Response(false, error);
        permissionResult.success(gson.toJson(response));
    }

    int getExternalStoragePermissionRequestCode() {
        return EXTERNAL_STORAGE_PERMISSION_REQUEST_CODE;
    }

    // ArchitectJavaScriptInterfaceListener
    @Override
    public void onJSONObjectReceived(final JSONObject jsonObject) {
        new Handler(Looper.getMainLooper()).post(new Runnable() {
            public void run() {
                channel.invokeMethod("jsonObjectReceived", jsonObject.toString());
            }
        });
    }
    // end ArchitectJavaScriptInterfaceListener

    // LocationListener
    @Override
    public void onLocationChanged(Location location) {
        if (location != null && !useCustomLocation) {
            if(architectView != null) {
                if (location.hasAltitude()) {
                    architectView.setLocation(location.getLatitude(), location.getLongitude(), location.getAltitude(), location.getAccuracy());
                } else {
                    architectView.setLocation(location.getLatitude(), location.getLongitude(), location.getAccuracy());
                }
            }
        }
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {
    }
    @Override
    public void onProviderEnabled(String provider) {
    }
    @Override
    public void onProviderDisabled(String provider) {
    }
    // end LocationListener

    // ArchitectWorldLoadedListener
    @Override
    public void worldWasLoaded(String s) {
        channel.invokeMethod("onWorldLoaded", "");
    }

    @Override
    public void worldLoadFailed(int i, String s, String s1) {
        channel.invokeMethod("onWorldLoadFailed", s);
    }
    // end ArchitectWorldLoadedListener
}