import 'dart:io';
import 'package:dio/dio.dart';
import 'dart:async';

import 'package:zhuishu/model/url.dart';

/*
* 网络工具
* https://www.ctolib.com/mip/xiadd-zhuishushenqi.html
*
*
* */

class HttpUtil {
  static final debug = true;
  static final baseUrl = BASE_URL;

  static final Dio _dio = Dio(new Options(
      method: "get",
      baseUrl: baseUrl,
      connectTimeout: 5000,
      receiveTimeout: 5000,
      followRedirects: true));

  static final Error unknownError = Error(-1, "未知异常");

  static Future<dynamic> getJson<T>(String uri,
          {Map<String, dynamic> paras}) =>
      _httpJson("get", uri, data: paras).then(logicalErrorTransform).catchError(onError);

  static Future<dynamic> postJson(
          String uri, Map<String, dynamic> body) =>
      _httpJson("post", uri, data: body).then(logicalErrorTransform).catchError(onError);

  static onError(error){
    print(error);
    Error errorInfo;
    if(error is DioError){
      switch(error.type){
        case DioErrorType.CONNECT_TIMEOUT:
          errorInfo = Error(0, "网络请求超时！");
          break;
        case DioErrorType.RECEIVE_TIMEOUT:
          errorInfo = Error(1, "服务器响应超时！");
          break;
        case DioErrorType.RESPONSE:
          errorInfo = Error(2, "服务器响应失败！");
          break;
        case DioErrorType.CANCEL:
          errorInfo = Error(3, "请求取消");
          break;
        case DioErrorType.DEFAULT:
          errorInfo = Error(4, "无网络");
          break;
      }
      return Future.error(errorInfo);
    }
    return Future.error(Error(-1,error));
  }

  static Future<Response<dynamic>> _httpJson(
      String method, String uri,
      {Map<String, dynamic> data, bool dataIsJson = true}) {
    /// 如果为 get方法，则进行参数拼接
    if (method == "get") {
      dataIsJson = false;
      if (data == null) {
        data = Map<String, dynamic>();
      }
    }

    if (debug) {
      print('<net url>------$uri');
      print('<net params>------$data');
    }

    /// 根据当前 请求的类型来设置 如果是请求体形式则使用json格式
    /// 否则则是表单形式的（拼接在url上）
    Options op;
    if (dataIsJson) {
      op = new Options(contentType: ContentType.parse("application/json"));
    } else {
      op = new Options(
          contentType: ContentType.parse("application/x-www-form-urlencoded"));
    }

    op.method = method;

    return _dio.request<dynamic>(uri, data: data, options: op);
  }

  /// 对请求返回的数据进行统一的处理
  static Future<T> logicalErrorTransform<T>(
      Response<dynamic> resp) {
    Error error;
    if (resp.data != null) {
      //对获取到的数据进行处理
      if (debug) {
        print('<net data>------$resp.data');
      }
      T data = resp.data as T;
      return Future.value(data);
    } else {
      error = unknownError;
    }
    return Future.error(error);
  }
}

/// 统一异常类
class Error {
  int errorCode;
  String msg;

  Error(errorCode, msg) {
    this.errorCode = errorCode;
    this.msg = msg;
  }
}
