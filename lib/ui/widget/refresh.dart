import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

Widget buildHeader(Key key, { String error }) {
  return ClassicsHeader(
    key: key,
    refreshText: "下拉刷新",
    refreshReadyText: "松开刷新",
    refreshingText: "正在刷新...",
    refreshedText: error ?? "刷新完成",
    bgColor: Colors.transparent,
    textColor: Colors.black,
  );
}

Widget buildFooter(Key key,{ String error }) {
  return ClassicsFooter(
    key:  key,
    loadReadyText: "松开加载",
    loadedText: error ?? "加载完成",
    noMoreText: "没有更多数据了",
    loadingText: "正在加载中...",
    loadText: "上拉加载",
    bgColor: Colors.transparent,
    textColor: Colors.black,
  );
}

