/*
* 用于直接跑测试界面
* */


import 'package:flutter/material.dart';
import 'package:zhuishu/util/file.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: TestWidget(),

    );
  }
}

class TestWidget extends StatefulWidget {
  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  void initState() {
    print("======= 文件操作 =======");
    FileUtil.createFile("abc", 2, "你好1呀1234").then((flag){
      print(flag);
      if(flag){
        FileUtil.readFile("abc", 1).then((str){
          print("======= 文件读取 =======");
          print(str);
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}





