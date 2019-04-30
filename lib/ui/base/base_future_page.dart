import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/util/text.dart';

abstract class BaseFuturePage extends StatelessWidget {
  @protected
  final String title = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: buildAppBarAction(context),
      ),
      body: FutureBuilder(
          future: loadCacheData(),
          builder: (context, AsyncSnapshot snapShot) {
            if (snapShot.connectionState == ConnectionState.done) {
              if (snapShot.hasError) return buildFail(context,snapShot.error);
              if (snapShot.data == null || snapShot.data.isEmpty) {
                return buildEmpty(context);
              }
              return buildSuccess(context,snapShot.data);
            }
            return buildLoading(context);
          }),
    );
  }

  loadCacheData();

  @protected
  buildEmpty(BuildContext context) {
    return Center(child: TextUtil.build("无数据", color: Colors.black87));
  }

  buildLoading(BuildContext context) {
    return Center(
        child: CupertinoActivityIndicator(
          radius: 15.0,
        ));
  }

  Widget buildSuccess(BuildContext context, data);

  Widget buildFail(BuildContext context, error){
    return Center(
      child: Text("加载资源失败 $error"),
    );
  }

  List<Widget> buildAppBarAction(BuildContext context){
    return null;
  }
}
