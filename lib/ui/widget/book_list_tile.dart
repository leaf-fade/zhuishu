
import 'package:flutter/material.dart';
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/util/text.dart';

/*
* 列表 - 书籍简介 - item
* */
class BookListTile extends StatelessWidget {
  final String icon;
  final String name;
  final String author;
  final String shortIntro;
  final String minor;
  final String follower; //人气
  final double height;
  final double defaultHeight = 100.0;

  BookListTile(
      {this.icon = "",
      this.name = "",
      this.author = "",
      this.shortIntro = "",
      this.minor = "",
      this.follower = "0",
      this.height = 100.0,
      });

  @override
  Widget build(BuildContext context) {
    double ratio = height/defaultHeight;
    Widget intro = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            ratio < 1? Container() : Icon(
              Icons.person,
              color: Colors.grey,
              size: 13.0,
            ),
            SizedBox(
                width: 100.0*ratio,
                child: TextUtil.buildOverFlow(author, fontSize: ratio < 1 ? 11.0 : 12.0)),
          ],
        ),
        Row(
          children: <Widget>[
            minor.isEmpty? SizedBox():Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0*ratio, horizontal: 5.0*ratio),
              child: TextUtil.buildBorder(minor,
                  color: Colors.grey,
                  background: Color(0xffe7dcbe),
                  fontSize: 6.0),
            ),
            follower.isEmpty? SizedBox():Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0*ratio, horizontal: 5.0*ratio),
              child: TextUtil.buildBorder("$follower人气",
                  color: Colors.white,
                  background: Color(0xffeae0e0),
                  fontSize: 6.0),
            ),
          ],
        ),
      ],
    );

    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextUtil.build(name,
            color: Colors.black87, fontWeight: FontWeight.w600, fontSize: ratio < 1 ? 14.0 : 18.0),
        SizedBox(
          height: 10.0*ratio,
        ),
        TextUtil.buildOverFlow(
          shortIntro,
          maxLines: 2,
          fontSize: ratio < 1 ? 13.0 : 14.0,
        ),
        intro,
      ],
    );
    return Container(
      child: Row(
        children: <Widget>[
          Container(
              width: 84*ratio,
              height: 100*ratio,
              padding: EdgeInsets.only(left: 15.0*ratio),
              child: CoverImage(
                icon,
              )),
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0*ratio, vertical: 5.0),
            child: body,
          )),
        ],
      ),
    );
  }
}

/*
*  常见列表      即左控件列表 + 右控件列表
* */
class NormalListTile extends StatelessWidget {
  final List<Widget> left;
  final List<Widget> right;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];
    if (left != null)
      list.add(Row(
        children: left,
      ));
    if (right != null)
      list.add(Row(
        children: right,
      ));
    return InkWell(
      child: Container(
        height: height,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, children: list),
      ),
      onTap: onTap,
    );
  }

  NormalListTile({this.left, this.right, this.height = 50.0, this.onTap});
}


/*
* 单选按钮组
* */
class HeadCellItemGroup extends StatelessWidget {
  final List<String> texts;
  final ValueChanged<String> onCheck;
  final String checkText;

  HeadCellItemGroup({this.texts, this.onCheck, this.checkText});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: texts.map((String text) {
        return buildItem(
          text: text,
          initValue: text == checkText,
          onPressed: () {
            onCheck(text);
          },
        );
      }).toList(),
    );
  }

  Widget buildItem({bool initValue, VoidCallback onPressed, String text}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child:
        TextUtil.build(text, color: initValue ? Colors.red : Colors.grey),
      ),
    );
  }
}
