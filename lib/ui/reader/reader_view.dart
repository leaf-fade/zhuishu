import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/ui/widget/battery_view.dart';
import 'package:zhuishu/util/screen.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';

/*
* 字符串文本切割
* */
const double paddingStart = 20.0;
const double paddingTop = 10.0;
const double top = 24.0;
const double bottom = 20.0;

class ReaderView extends StatelessWidget {
  //字体大小
  final double fontSize;

  //行间距
  final double space;
  final String widget;
  final String title;
  final String index;
  final double _size = 12.0;
  final Color bookColor;
  final int state;
  final VoidCallback onTap;

  ReaderView(this.title, this.fontSize, this.space, this.widget, this.index,
      {this.bookColor, this.state = 0,this.onTap});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: paddingTop, horizontal: paddingStart),
        child: state == 0 ? buildSuccess() : (state == 1 ? buildLoading(): buildLoadFail()),
      ),
    );
  }

  buildSuccess() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: top,
          child: TextUtil.build(title, fontSize: _size),
        ),
        Expanded(
          child: buildContainer(widget,
              fontSize: fontSize, space: space, color: bookColor),
        ),
        buildBottom(),
      ],
    );
  }

  buildLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          height: top,
          child: TextUtil.build(title, fontSize: _size),
        ),
        Expanded(
          child: Center(
            child: CupertinoActivityIndicator(
              radius: 15.0,
            ),
          ),
        ),
      ],
    );
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
            onPressed: this.onTap,
            child: TextUtil.build("刷新",
                fontWeight: FontWeight.w500, fontSize: 16, color: Colors.white),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
          ),
        ],
      ),
    );
  }

  /*
  * 显示文本
  * */
  Widget buildContainer(String str,
      {double fontSize = 16.0,
      double space = 1.5,
      Color color = Colors.black}) {
    return Container(
      alignment: Alignment.topLeft,
      child: TextUtil.build(str,
          fontSize: fontSize,
          color: color ?? Colors.black,
          textAlign: TextAlign.justify,
          height: space),
    );
  }

  /*
  * 显示电量，时间，页数
  * */
  Widget buildBottom() {
    return Container(
      height: bottom,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              BatteryView(),
              SizedBox(
                width: 10.0,
              ),
              TextUtil.build(StringAmend.getNowNormalTime(), fontSize: _size),
            ],
          ),
          TextUtil.build("第 $index 页", fontSize: _size),
        ],
      ),
    );
  }
}

//进行分离
List<ReaderView> getReaderViews(List<String> datas,
        {double fontSize = 16.0,
        double space = 1.5,
        String title,
        Color textColor}) =>
    List.generate(
        datas.length,
        (index) => ReaderView(title, fontSize, space, datas[index],
            "${index + 1}/${datas.length}"));

//修正文本
String dealData(String str) {
  if(str == null) return null;
  List<String> list;
  //转化为列表
  if (str.contains("\r\n")) {
    list = str.split("\r\n");
  } else if (str.contains("\n")) {
    list = str.split("\n");
  } else {
    list = [str];
  }
  //去除多余的换行和缩进修正
  StringBuffer buffer = StringBuffer();
  for (String str in list) {
    if (str.isEmpty) {
      continue;
    }
    //首行未缩进的则添加首行缩进，否则不加
    if (!str.startsWith("\u3000\u3000")) {
      buffer.write("\u3000\u3000");
    }
    buffer.write(str);
    buffer.write("\n");
  }
  return buffer.toString();
}

//页面划分
List<String> getReaderViewData(String content,
    {double fontSize = 16.0, double space = 1.5}) {
  if (content == null || content.isEmpty) return [];
  String tempStr = content;
  List<String> readerViews = [];
  double width = Screen.width - 2 * paddingStart;
  double height = Screen.height - 2 * paddingTop - 50.0 - top - bottom;
  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  while (tempStr.length > 0) {
    textPainter.text = TextSpan(
        text: tempStr, style: TextStyle(fontSize: fontSize, height: space));
    textPainter.layout(maxWidth: width);
    //获取占满这个区域的String的最后一个字符的index(第几个就返回几)
    int end = textPainter.getPositionForOffset(Offset(width, height)).offset;
    //截取的时候可能上一页正好结束，但下一页开头就是换行符，所以不要
    String page = tempStr.startsWith("\n")
        ? tempStr.substring(1, end)
        : tempStr.substring(0, end);
    readerViews.add(page);
    tempStr = tempStr.substring(end, tempStr.length);
  }
  return readerViews;
}

/*
*/ /*List<List<String>> getReaderViewData(List<String> strList,
    {double fontSize = 16.0, double space = 1.5}) {
  if (strList == null) return [];
  print(" $fontSize ======== $space");

  List<List<String>> readerViews = [];
  List<String> viewList = [];

  double width = Screen.width - 2 * paddingStart;
  double height = Screen.height - 2 * paddingTop - 30.0 - top - bottom;
  //计算每行最大字数
  int maxRowNum = width ~/ (fontSize*1.1);
  //计算最大行数
  int maxColNum = height ~/ (fontSize * space);
  print("====一行最多字数====" + maxRowNum.toString());
  print("====最大行数====" + maxColNum.toString());
  //原本的字符串列表总个数
  int length = strList.length;
  //用于累加各行字符串的长度
  int colNum = 0;
  for (int i = 0; i < length; i++) {
    String str = strList[i];
    //去除未删除掉的换行
    if(str==""){
      continue;
    }
    //首行未缩进的则添加首行缩进，否则不加
    if(!str.startsWith("\u3000\u3000")){
      str = "\u3000\u3000" + str;
    }
    int strLength = str.length;
    int startIndex = 0;
    int useLength = 0;
    while (strLength > 0) {
      String newStr;
      //如果包含英文或数字
      if (RegExp("[a-zA-Z0-9.]").hasMatch(str)) {
        int newIndex = getSubIndex(str, startIndex, maxRowNum);
        newStr = str.substring(startIndex, startIndex + newIndex);

        useLength = newIndex;
      } else {
        newStr = str.substring(
            startIndex, startIndex + getMin(strLength, maxRowNum));
        useLength = maxRowNum;
      }
      if(startIndex < 30){
        print(newStr);
      }

      //创建新的文本控件
      viewList.add(newStr);
      strLength -= useLength;
      startIndex += useLength;
      colNum++;
      //达到一页条件
      if (colNum == maxColNum) {
        //进行拷贝，同时清空原数组
        List<String> newList = [];
        newList.addAll(viewList);
        viewList.clear();
        //加入列表
        readerViews.add(newList);
        colNum = 0;
      }
    }
    //添加最后一个
    if (i == length - 1) {
      //进行拷贝，同时清空原数组
      List<String> newList = [];
      newList.addAll(viewList);
      viewList.clear();
      //加入列表
      readerViews.add(newList);
    }
  }
  return readerViews;
}*/ /*

int getMin(int a, int b) => a < b ? a : b;

*/ /*
* 特殊处理
* */ /*
int getSubIndex(String str, int startIndex, int maxNum) {
  if (str.length < maxNum) {
    return str.length;
  }

  int index = 0;
  int count = 0;
  for (int i = startIndex; i < str.length; i++) {
    int c = str.codeUnitAt(i);
    //省略号 3个小点占一格
    if (c == 46 &&
        i < str.length - 2 &&
        str.codeUnitAt(i + 1) == 46 &&
        str.codeUnitAt(i + 2) == 46) {
      count++;
      index += 3;
      i += 2; //结束时会加一
      if (count == maxNum) {
        return index;
      }
      continue;
    }
    //2个字符占一格
    if (isAscii(c) && i < str.length - 1 && isAscii(str.codeUnitAt(i + 1))) {
      count++;
      index += 2;
      i++;
    } else {
      count++;
      index++;
    }
    if (count == maxNum) {
      return index;
    }
  }
  return index;
}

//可显示字符范围,且小字符
bool isAscii(int c) => c >= 91 && c <= 126;*/
