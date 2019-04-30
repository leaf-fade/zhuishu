import 'package:flutter/material.dart';
import 'package:zhuishu/router/route.dart';

class RouteUtil {
  static push(BuildContext context, String pageUrl,
      {Map<String, dynamic> params}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return AppRoute.getPage(pageUrl, params);
    }));
  }
}
