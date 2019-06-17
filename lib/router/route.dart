import 'package:annotation_route/route.dart';
import './route.internal.dart';
import 'package:flutter/material.dart';

/*
* 阿里路由框架
*
* 一旦建立了新的路由，就需要执行2个脚本
* 自动生成route.internal.dart文件脚本： flutter packages pub run build_runner build --delete-conflicting-outputs
*
* 清除之前生成的文件脚本： flutter packages pub run build_runner clean
* */
@ARouteRoot()
class RouteOption {
  String url;
  Map<String, dynamic> params;
  RouteOption(this.url, this.params );
}


class AppRoute {
  static Widget getPage(String url, Map<String, dynamic> params) {
    ARouterInternalImpl internal = ARouterInternalImpl();
    ARouterResult routeResult = internal.findPage(
        ARouteOption(url, params), RouteOption(url, params));
    if (routeResult.state == ARouterResultState.FOUND) {
      return routeResult.widget;
    }
    return Scaffold( // 这里只是例子，返回的是未匹配路径的控件
      appBar: AppBar(),
      body: Center(
        child: Text('迷路了'),
      ),
    );
  }
}