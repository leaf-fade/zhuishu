import 'package:flutter/material.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/router/route_util.dart';
import 'package:zhuishu/router/router_const.dart';
import 'package:zhuishu/ui/base/my_color.dart';
import 'package:zhuishu/util/event_bus.dart';
import 'package:zhuishu/util/screen.dart';
import 'package:zhuishu/util/sp.dart';

class BookMenuBar extends StatelessWidget {
  final BookData bookData;
  final bool isAdd;

  BookMenuBar(this.bookData, this.isAdd);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: Screen.bottomSafeHeight),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Color(0x22000000), blurRadius: 8)]),
      height: 50 + Screen.bottomSafeHeight,
      child: Row(children: <Widget>[
        Expanded(
          child: ChangeText(
              activeText: "加入书架",
              inactiveText: "不追了",
              activeStyle: TextStyle(fontSize: 16, color: MyColor.primary),
              inactiveStyle: TextStyle(fontSize: 16, color: MyColor.divider),
              initActive: !isAdd,
              onTap: (active) {
                eventBus.fire(AddShelfEvent(active));
                if (active) {
                  bookData.lastReadDate = DateTime.now().millisecondsSinceEpoch;
                  //加入书架
                  SpHelper.saveBookIntoShelf(bookData);
                } else {
                  SpHelper.clearBookInShelf(bookData);
                }
              }),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              //阅读
              RouteUtil.push(context, PageUrl.READER_SCENE, params: {
                "bookId": bookData.bookId,
                "chapterId": 0,
                "bookName": bookData.bookName,
                "coverUrl": bookData.coverUrl,
              });
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                  color: MyColor.primary,
                  borderRadius: BorderRadius.circular(5)),
              child: Center(
                child: Text(
                  '开始阅读',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              '下载',
              style: TextStyle(fontSize: 16, color: MyColor.primary),
            ),
          ),
        ),
      ]),
    );
  }
}

/*
* 收藏按钮
* */
class SaveButton extends StatefulWidget {
  final BookData bookData;
  @override
  _SaveButtonState createState() => _SaveButtonState();

  SaveButton(this.bookData);
}

class _SaveButtonState extends State<SaveButton> {
  //按键的状态和真实状态是相反的
  bool add = false;

  @override
  void initState() {
    eventBus.on<AddShelfEvent>().listen((data) {
      add = data.isAdd;
      if(mounted) setState(() {});
    });
    SpHelper.isAddToShelf(widget.bookData.bookId).then((isAdd) {
      add = isAdd;
      if(mounted) setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        add = !add;
        eventBus.fire(AddShelfEvent(add));
        if (add) {
          //加入书架
          SpHelper.saveBookIntoShelf(widget.bookData);
        } else {
          SpHelper.clearBookInShelf(widget.bookData);
        }
      },
      child: Text(!add ? "收藏" : "不追了"),
    );
  }
}

/*
* 点击后会变化的text
* */
class ChangeText extends StatefulWidget {
  final Key key;
  final void Function(bool active) onTap;
  final String activeText;
  final String inactiveText;
  final TextStyle activeStyle;
  final TextStyle inactiveStyle;
  final bool initActive;

  @override
  _ChangeTextState createState() => _ChangeTextState();

  ChangeText(
      {this.key,
      this.onTap,
      this.activeText,
      this.inactiveText,
      this.activeStyle,
      this.inactiveStyle,
      this.initActive = true})
      : super(key: key);
}

class _ChangeTextState extends State<ChangeText> {
  bool active;

  @override
  void initState() {
    active = widget.initActive;
    eventBus.on<AddShelfEvent>().listen((data) {
      setState(() {
        active = !data.isAdd;
      });
    });
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Center(
        child: Text(
          active ? widget.activeText : widget.inactiveText,
          style: active ? widget.activeStyle : widget.inactiveStyle,
        ),
      ),
      onTap: () {
        if (widget.onTap != null) widget.onTap(active);
      },
    );
  }
}
