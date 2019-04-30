import 'package:flutter/services.dart';
/*
* 调用原生控件Toast
* invokeMethod会回调android sdk中注册的MethodChannel，MethodChannel在回调MethodCallHandler接口
* ToastPlugin
* */
class Toast {
  static const _platform = const MethodChannel("toast"); //调用原生控件的关键

  static void show(String message) =>
      _platform.invokeMethod("show", {"message": message});   //invokeMethod会回调android sdk中注册的MethodChannel，MethodChannel在回调MethodCallHandler接口

}