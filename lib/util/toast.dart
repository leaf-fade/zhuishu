import 'package:fluttertoast/fluttertoast.dart';
/*
* 调用原生控件Toast
* */
class Toast {
  static void show(String message) => Fluttertoast.showToast(msg: message,);
}