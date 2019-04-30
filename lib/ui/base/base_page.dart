import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/util/toast.dart';
import 'package:connectivity/connectivity.dart';

/*
* 基础网络加载页面
* 加载中显示转圈，加载数据
* 加载成功后显示界面
* 加载失败后显示失败界面
* */
enum PageState {
  Init,
  Success,
  Fail,
}

enum NetWorkState {
  Wifi,
  Mobile,
  None,
  Unknown,
}

abstract class BasePageState<T extends StatefulWidget> extends State<T> {
  PageState pageState;
  NetWorkState netWorkState = NetWorkState.Unknown;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  void loadData();

  Widget buildBody();

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      checkNetWorkResult(result);
      setState(() {});
    });
    pageState = PageState.Init;
    loadData();
  }

  void checkNetWorkResult(ConnectivityResult result) {
    if (result == ConnectivityResult.mobile) {
      netWorkState = NetWorkState.Mobile;
    } else if (result == ConnectivityResult.wifi) {
      netWorkState = NetWorkState.Wifi;
    } else if (result == ConnectivityResult.none) {
      netWorkState = NetWorkState.None;
    } else {
      netWorkState = NetWorkState.Unknown;
    }
  }

  @override
  void setState(fn) {
    if(mounted){
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<Null> initConnectivity() async {
    //平台消息可能会失败，因此我们使用Try/Catch PlatformException。
    try {
      var result = await _connectivity.checkConnectivity();
      checkNetWorkResult(result);
    } catch (e) {
      netWorkState = NetWorkState.Unknown;
    }

    if (!mounted) return;
    setState(() {});
  }

  void initLoadingState() {
    pageState = PageState.Init;
    setState(() {});
  }

  void loadFailState() {
    pageState = PageState.Fail;
    setState(() {});
  }

  void loadSuccessState() {
    pageState = PageState.Success;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (pageState == PageState.Init) {
      return buildLoading();
    }
    if (netWorkState == NetWorkState.None) {
      return buildNoNetWork();
    }
    if (pageState == PageState.Fail) {
      return buildLoadFail();
    }
    return buildBody();
  }

  buildLoading() {
    return Center(
        child: CupertinoActivityIndicator(
      radius: 15.0,
    ));
  }

  buildLoadFail() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("images/icon_cartoon.png"),
          SizedBox(
            height: 30,
          ),
          RaisedButton(
            color: Colors.red,
            onPressed: () {
              initLoadingState();
              loadData();
            },
            child: TextUtil.build("刷新", fontWeight: FontWeight.w500, fontSize: 16,color: Colors.white),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
          ),
        ],
      ),
    );
  }

  Future netConnect(String url, void Function(dynamic) callback,
      {VoidCallback initCheckState, bool Function() checkOk}) async {
    await HttpUtil.getJson(url).then((data) {
      callback(data);
      bool isOk = checkOk == null ? true : checkOk();
      if (isOk) {
        if (initCheckState != null) initCheckState();
        loadSuccessState();
      }
    }).catchError((error) {
      print(error.toString());
      if (pageState != PageState.Fail) {
        Toast.show(error is Error ? error.msg : "网络请求失败");
        loadFailState();
      }
    });
  }

  Widget buildNoNetWork() {
    return Center(
      child: Container(
        height: 235,
        child: Stack(
          children: <Widget>[
            Image.asset(
              "images/ic_net_error.png",
              color: Colors.grey[300],
              fit: BoxFit.fill,
            ),
            Positioned(
              bottom: 30.0,
              left: 100,
              child: TextUtil.build("见鬼了，怎么没网！",
                  color: Colors.grey[400],
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
