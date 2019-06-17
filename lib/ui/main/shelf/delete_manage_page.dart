import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/ui/widget/check_box.dart';
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/util/event_bus.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';

class DeleteManagePage extends StatefulWidget {
  final List<BookData> books;

  @override
  _DeleteManagePageState createState() => _DeleteManagePageState();

  DeleteManagePage(this.books);
}

class _DeleteManagePageState extends State<DeleteManagePage> {
  List<bool> checkItems;

  bool get isCheckAll {
    for (bool check in checkItems) {
      if (!check) return false;
    }
    return true;
  }

  @override
  void initState() {
    checkItems = List.generate(widget.books.length, (index) => false);
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    //转换
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: Container(),
        title: Text("删除管理"),
        elevation: 0.0,
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("取消"),
          ),
        ],
      ),
      body: buildMain(),
    );
  }

  Widget buildMain() {
    return GestureDetector(
      onPanUpdate: (DragUpdateDetails details){
        if(details.delta.dx < 30){
          Navigator.pop(context);
          print("=================");
        }
      },
      child: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              itemCount: widget.books.length,
              itemBuilder: (context, index) => buildItem(context, index),
              separatorBuilder: (context, index) => Divider(
                    height: 1,
                  ),
            ),
          ),
          Divider(
            height: 1.0,
          ),
          Container(
            height: 60,
            child: Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: buildButton(
                      onPressed: () {
                        setState(() {
                          setCheckAll(!isCheckAll);
                        });
                      },
                      textColor: Colors.red,
                      background: Color(0xffe7dcbe),
                      text: isCheckAll ? "取消全选" : "全选",
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                    child: buildButton(
                      onPressed: dealDelete,
                      text:
                          "删除${getCheckCount() > 0 ? "(${getCheckCount()})" : ""}",
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void dealDelete() {
    if (checkItems.isEmpty) return;
    List<BookData> removeDatas = [];
    for (int i = 0; i < checkItems.length; i++) {
      if (checkItems[i]) {
        removeDatas.add(widget.books[i]);
      }
    }
    removeDatas.forEach((BookData data) {
      SpHelper.clearBookInShelf(data);
      widget.books.remove(data);
    });
    //通知刷新
    eventBus.fire(AddShelfEvent(false));
    if (widget.books.length == 0) {
      Navigator.of(context).pop();
      return;
    }
    checkItems.removeWhere((bool check) => check);
    setState(() {});
  }

  Widget buildButton(
      {VoidCallback onPressed,
      String text,
      Color background = Colors.red,
      Color textColor = Colors.white}) {
    return RawMaterialButton(
      fillColor: background,
      onPressed: onPressed,
      child: TextUtil.build(text,
          fontWeight: FontWeight.w500, fontSize: 16, color: textColor),
      constraints: BoxConstraints.expand(),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
    );
  }

  int getCheckCount() {
    int count = 0;
    for (bool check in checkItems) {
      if (check) count++;
    }
    return count;
  }

  void setCheckAll(bool check) {
    for (int i = 0; i < checkItems.length; i++) {
      checkItems[i] = check;
    }
  }

  Widget buildItem(BuildContext context, int index) {
    return buildItemBody(context, index, widget.books[index]);
  }

  Widget buildItemBody(BuildContext context, int index, BookData bookData) {
    return ListTile(
      leading: CoverImage(
        bookData.coverUrl,
        width: 48,
        height: 70,
      ),
      title: TextUtil.build(bookData.bookName,
          fontSize: 16, fontWeight: FontWeight.w500),
      subtitle: TextUtil.buildOverFlow(
          "${StringAmend.getTimeDuration(bookData.lastUpdate)}   ${bookData.lastChapterInfo}",
          maxLines: 1),
      trailing: RoundCheckbox(
        value: checkItems[index],
        onChanged: (check) {
          setState(() {
            checkItems[index] = check;
          });
        },
      ),
      onTap: () {
        setState(() {
          checkItems[index] = !checkItems[index];
        });
      },
    );
  }
}
