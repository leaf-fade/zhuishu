import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_future_page.dart';
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/util/toast.dart';


class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String title = "阅读历史";
  final List<BookData> books = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          FlatButton(
            onPressed: () {
              if(books.isEmpty) return;
              books.clear();
              SpUtil.setStringListNull(READ_HISTORY);
              setState(() {});
            },
            child: Text("清除"),
          ),
        ],
      ),
      body: BaseFutureWidget(
        future: loadCacheData(),
        buildSuccess: buildSuccess,
        buildEmpty: buildHistoryEmpty,
      ),
    );
  }

  loadCacheData() async {
    return await SpUtil.getStringList(READ_HISTORY);
  }

  Widget buildSuccess(context, data) {
    books.clear();
    for (String item in data ?? []) {
      books.add(BookData.fromString(item));
    }
    return HistoryListWidget(books.reversed.toList());
  }
}

Widget buildHistoryEmpty(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Image.asset("images/icon_cartoon.png"),
        SizedBox(
          height: 30,
        ),
        TextUtil.build("记录竟然是空的",
            fontWeight: FontWeight.w500, fontSize: 18, color: Colors.grey),
      ],
    ),
  );
}

class HistoryListWidget extends StatefulWidget {
  final List<BookData> books;

  @override
  _HistoryListWidgetState createState() => _HistoryListWidgetState();

  HistoryListWidget(this.books);
}

class _HistoryListWidgetState extends State<HistoryListWidget> {
  List<BookData> books;
  List<bool> checkItems;

  @override
  void initState() {
    books = widget.books;
    checkItems = List.generate(books.length, (index) => false);
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    //转换
    return books.isEmpty ? buildHistoryEmpty(context) : buildMain();
  }

  Widget buildMain() {
    return ListView.separated(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      itemCount: books.length,
      itemBuilder: (context, index) => buildItem(context, index),
      separatorBuilder: (context, index) => Divider(
            height: 1,
          ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    BookData bookData = books[index];
    return Dismissible(
      key: Key(bookData.bookId),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment(1, 0),
        child: Text("左滑删除"),
      ),
      onDismissed: (direction) {
        setState(() {
          books.removeAt(index);
        });
        if(books.isEmpty){
          SpUtil.setStringListNull(READ_HISTORY);
        }else{
          SpUtil.set(READ_HISTORY,
              books.map((bookData) => bookData.toString()).toList());
        }
        Toast.show("删除${bookData.bookName}");
      },
      child: buildItemBody(context, index, bookData),
    );
  }

  Widget buildItemBody(BuildContext context, int index, BookData bookData) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5.0),
        child: ListTile(
          leading: CoverImage(
            bookData.coverUrl,
            width: 48,
            height: 70,
          ),
          title: TextUtil.build(bookData.bookName,
              fontSize: 16, fontWeight: FontWeight.w500),
          subtitle: TextUtil.buildOverFlow(
              "${StringAmend.getTimeDurationWithDate(DateTime.fromMillisecondsSinceEpoch(bookData.lastReadDate))}阅读"),
          trailing: TextUtil.build("阅读至第${bookData.chapterId + 1}章"),
        ),
      ),
      onTap: () {
        bookData.isUpdate = false;
        SpHelper.saveShelfBookUpdate(bookData);
        //阅读
        RouteUtil.push(context, PageUrl.READER_SCENE, params: {
          "bookId": bookData.bookId,
          "chapterId": bookData.chapterId ?? 0,
          "bookName": bookData.bookName,
          "coverUrl": bookData.coverUrl,
        });
      },
      onLongPress: () {
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
                title: Text("删除${bookData.bookName}"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("确认"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {
                        books.removeAt(index);
                      });
                      SpUtil.set(
                          READ_HISTORY,
                          books
                              .map((bookData) => bookData.toString())
                              .toList());
                      Toast.show("删除${bookData.bookName}");
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
      },
    );
  }
}
