import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/router/route.dart';
import 'package:zhuishu/router/route_util.dart';
import 'package:zhuishu/router/router_const.dart';
import 'package:zhuishu/ui/base/base_future_page.dart';
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/util/toast.dart';

class HistoryPage extends BaseFuturePage {
  final String title = "阅读历史";

  loadCacheData() async {
    return await SpUtil.getStringList(READ_HISTORY);
  }

  buildEmpty(context) {
    return buildHistoryEmpty(context);
  }

  @override
  Widget buildSuccess(context, data) {
    List<BookData> books = [];
    for (String item in data ?? []) {
      books.add(BookData.fromString(item));
    }
    return HistoryListWidget(books);
  }
}

Widget buildHistoryEmpty(BuildContext context){
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
  List<BookData> books ;
  @override
  void initState() {
    books = widget.books.reversed.toList();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    //转换
    return books.isEmpty? buildHistoryEmpty(context) : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10.0),
        itemCount: books.length,
        itemBuilder: (context, index) => buildItem(context, index));
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
        SpUtil.set(READ_HISTORY, books.map((bookData)=>bookData.toString()).toList());
        Toast.show("删除${bookData.bookName}");
      },
      child: InkWell(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(
            leading: CoverImage(
              bookData.coverUrl,
              width: 45,
              height: 70,
            ),
            title: TextUtil.build(bookData.bookName,
                fontSize: 16, fontWeight: FontWeight.w500),
            subtitle: TextUtil.buildOverFlow(
                "${StringAmend.getTimeDurationWithDate(DateTime.fromMillisecondsSinceEpoch(bookData.lastReadDate))}阅读"),
            trailing: TextUtil.build("阅读至第${bookData.chapterId + 1}章"),
          ),
        ),
        onTap: (){
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
      ),
    );
  }
}

