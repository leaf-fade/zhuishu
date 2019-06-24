import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showProgressDialog(BuildContext context) {
  showCupertinoDialog(
    context: context,
    builder: (_) => CupertinoAlertDialog(
      title: Text("下载"),
      content: DownloadProgress(),
      actions: <Widget>[
        FlatButton(
          child: Text("确认"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text("取消"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

class DownloadProgress extends StatefulWidget {
  @override
  _DownloadProgressState createState() => _DownloadProgressState();
}

class _DownloadProgressState extends State<DownloadProgress> {
  double progress = 0;
  @override
  Widget build(BuildContext context) {
    return DownloadProgressContent(progress);
  }

  @override
  void initState() {
    download();
    super.initState();
  }

  void download() async{
    for(int i =1 ; i <= 100; i++){
      await Future.delayed(Duration(seconds: 1));
      if(mounted)
      setState(() {
        progress = i/100;
      });
    }
  }
}


class DownloadProgressContent extends StatelessWidget {
  final double progress;

  @override
  Widget build(BuildContext context) {
    return  Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15.0, vertical: 6.0),
                child: Text("下载进度  $progress"),
              ),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.black87,
                valueColor: AlwaysStoppedAnimation(Colors.red),
              ),
            ],
          ),
    );
  }

  DownloadProgressContent(this.progress);
}

