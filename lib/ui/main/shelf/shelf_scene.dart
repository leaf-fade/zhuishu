import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/model/book_info.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/router/route_util.dart';
import 'package:zhuishu/router/router_const.dart';
import 'package:zhuishu/ui/main/shelf/history_page.dart';
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/util/event_bus.dart';
import 'package:zhuishu/util/icon.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/util/toast.dart';

class ShelfScene extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("书架"),
          actions: <Widget>[
            buildIcon(
              icon: Icons.search,
              onTap: () {
                RouteUtil.push(context, PageUrl.SEARCH_PAGE);
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: buildIcon(
                icon: Icons.history,
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => HistoryPage()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: buildIcon(
                icon: Icons.more_horiz,
                onTap: () {
                  SpHelper.getTheme().then((index) {
                    showMenuDialog(context, index == 1);
                  });
                },
              ),
            ),
          ],
        ),
        body: FutureBuilder(
            future: loadCacheData(),
            builder: (context, AsyncSnapshot snapShot) {
              if (snapShot.connectionState == ConnectionState.done) {
                if (snapShot.hasError) return Text("加载资源失败 ${snapShot.error}");
                if (snapShot.data == null || snapShot.data.isEmpty) {
                  return buildEmpty();
                }
                //转换
                return ShelfListWidget(snapShot.data);
              }
              return buildLoading();
            }));
  }

  showMenuDialog(BuildContext context, bool isMoon) async {
    final result = await showMenu(
        context: context,
        //超过了屏幕宽度或者高度，这个属性就不起决定作用
        position: RelativeRect.fromLTRB(1000, 100, 15, 1000),
        items: <PopupMenuItem<int>>[
          PopupMenuItem<int>(
            value: 0,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.insert_drive_file,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 10,
                ),
                Text("本地书籍"),
              ],
            ),
          ),
          PopupMenuItem<int>(
            value: 1,
            child: Row(
              children: <Widget>[
                isMoon
                    ? Icon(
                        MyIcon.sun,
                        color: Colors.grey,
                      )
                    : Icon(
                        MyIcon.moon,
                        color: Colors.grey,
                      ),
                SizedBox(
                  width: 10,
                ),
                Text(isMoon ? "日间模式" : "夜间模式"),
              ],
            ),
          ),
        ]);
    switch (result) {
      case 0:
        break;
      case 1:
        var click = !isMoon;
        eventBus.fire(ThemeEvent(click ? 1 : 0));
        SpHelper.saveTheme(click ? 1 : 0);
        break;
    }
  }

  loadCacheData() async {
    return await SpHelper.getBookShelfDatas();
  }

  buildEmpty() {
    return Center(child: TextUtil.build("空空如野", color: Colors.black87));
  }

  buildLoading() {
    return Center(
        child: CupertinoActivityIndicator(
      radius: 15.0,
    ));
  }
}

class ShelfListWidget extends StatefulWidget {
  final List<BookData> bookDatas;

  @override
  _ShelfListWidgetState createState() => _ShelfListWidgetState();

  ShelfListWidget(this.bookDatas);
}

//删除书籍需要 eventBus.fire(AddShelfEvent(false));
class _ShelfListWidgetState extends State<ShelfListWidget> {
  GlobalKey<RefreshHeaderState> _headerKey = GlobalKey<RefreshHeaderState>();
  String error;

  @override
  void initState() {
    if (widget.bookDatas.length > 1) {
      widget.bookDatas.sort(
          (left, right) => right.lastReadDate.compareTo(left.lastReadDate));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return buildList();
  }

  Future<void> refreshData() async {
    error = null;
    StringBuffer buffer = StringBuffer();
    for (BookData bookData in widget.bookDatas) {
      buffer.write(bookData.bookId);
      buffer.write(",");
    }
    String ids = buffer.toString().substring(0, buffer.length - 1);
    print(ids);
    String url = "/book?view=updated&id=$ids";
    await HttpUtil.getJson(url).then((data) {
      List<BookInfo> bookInfos = [];
      for (var item in data ?? []) {
        bookInfos.add(BookInfo.fromJson(item));
      }
      print(" ======修改数据===== ");
      for (int i = 0; i < widget.bookDatas.length; i++) {
        BookData bookData = widget.bookDatas[i];
        BookInfo bookInfo = bookInfos[i];
        if (bookData.bookId == bookInfo.id &&
            bookData.lastChapterInfo != bookInfo.lastChapter) {
          bookData.lastChapterInfo = bookInfo.lastChapter;
          bookData.lastUpdate = bookInfo.updated;
          bookData.isUpdate = true;
          SpHelper.saveBookIntoShelf(bookData);
        }
      }
      setState(() {});
    }).catchError((err) {
      if (err is Error) {
        error = err.msg;
        setState(() {});
        Toast.show(err.msg);
      }
    });
  }

  Widget buildList() {
    return EasyRefresh(
      behavior: ScrollOverBehavior(),
      refreshHeader: buildHeader(),
      child: ListView.builder(
        itemCount: widget.bookDatas.length,
        itemExtent: 75,
        itemBuilder: (context, index) {
          return buildItem(index, widget.bookDatas[index]);
        },
      ),
      onRefresh: refreshData,
      //loadMore: (){},
    );
  }

  Widget buildItem(int index, BookData bookData) {
    return InkWell(
      onTap: () {
        bookData.isUpdate = false;
        //阅读
        RouteUtil.push(context, PageUrl.READER_SCENE, params: {
          "bookId": bookData.bookId,
          "chapterId": bookData.chapterId ?? 0,
          "bookName": bookData.bookName,
          "coverUrl": bookData.coverUrl,
        });
        bookData.lastReadDate = DateTime.now().millisecondsSinceEpoch;
        widget.bookDatas.sort(
            (left, right) => right.lastReadDate.compareTo(left.lastReadDate));
        setState(() {});
        SpHelper.saveShelfBookUpdate(bookData);
      },
      onLongPress: () {},
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
              "${StringAmend.getTimeDuration(bookData.lastUpdate)}   ${bookData.lastChapterInfo}",
              maxLines: 1),
          trailing: bookData.isUpdate
              ? TextUtil.buildBorder("new",
                  color: Colors.white,
                  background: Colors.red[300],
                  fontSize: 6.0)
              : Container(
                  width: 10,
                ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return ClassicsHeader(
      key: _headerKey,
      refreshText: "下拉刷新",
      refreshReadyText: "松开刷新",
      refreshingText: "正在刷新...",
      refreshedText: error ?? "刷新完成",
      bgColor: Colors.transparent,
      textColor: Colors.black,
    );
  }
}
