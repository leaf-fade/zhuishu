import 'package:cached_network_image/cached_network_image.dart';
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

  BookListTile(
      {this.icon = "",
      this.name = "",
      this.author = "",
      this.shortIntro = "",
      this.minor = "",
      this.follower = "0"});

  @override
  Widget build(BuildContext context) {
    Widget intro = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.person,
              color: Colors.grey,
              size: 13.0,
            ),
            SizedBox(
                width: 100.0,
                child: TextUtil.buildOverFlow(author, fontSize: 12.0)),
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: TextUtil.buildBorder(minor??"",
                  color: Colors.grey,
                  background: Color(0xffe7dcbe),
                  fontSize: 6.0),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
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
            color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18.0),
        SizedBox(
          height: 10.0,
        ),
        TextUtil.buildOverFlow(
          shortIntro,
          maxLines: 2,
        ),
        intro,
      ],
    );
    return Container(
      child: Row(
        children: <Widget>[
          Container(
              width: 84,
              height: 100,
              padding: EdgeInsets.only(left: 15.0),
              child: CoverImage(
                icon,
              )),
          Expanded(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
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
