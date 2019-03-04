package com.ar.techno_buzz;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "Share";
  String file,stings;
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                // TODO
                if (call.method.equals("getShare")) {
                  file = call.argument("file");
                  stings=call.argument("strings");
                  Uri uri = Uri.parse(file);


                  int batteryLevel = ShareFunction(uri,stings);
                  if (batteryLevel != -1) {
                    result.success(batteryLevel);
                  } else {
                    result.error("UNAVAILABLE", "setwallpaper", null);
                  }
                } else {
                  result.notImplemented();
                }
              }
            });


  }
  int ShareFunction(Uri file,String title){
    Intent shareIntent = new Intent();
    shareIntent.setAction(Intent.ACTION_SEND);
    shareIntent.putExtra(Intent.EXTRA_TEXT, title+"\n"+"Stay Updated With Latest & Upcoming Gadget Launches Download The App Now"+"\n"+"https://play.google.com/store/apps/details?id=com.ar.techno_buzz");
    shareIntent.putExtra(Intent.EXTRA_STREAM,file );
    shareIntent.setType("image/*");

    // Launch sharing dialog for image
    startActivity(Intent.createChooser(shareIntent, "Share Image"));
    return -1;
  }

}