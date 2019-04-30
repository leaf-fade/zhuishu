package com.zhuishu;

import android.content.Context;
import android.util.Log;
import android.widget.Toast;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class ToastPlugin implements MethodChannel.MethodCallHandler {
    private static Context context;
    public static void register(Context context , BinaryMessenger messenger){
        ToastPlugin.context = context;
        MethodChannel channel = new MethodChannel(messenger,"toast");
        channel.setMethodCallHandler(new ToastPlugin());
    }

    @Override
    public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        switch (methodCall.method) {
            case "show":
                String message = methodCall.argument("message");
                //Log.i("123", "onMethodCall: "+message+"context:"+context);
                Toast.makeText(context,message,Toast.LENGTH_SHORT).show();
                break;
        }
    }
}
