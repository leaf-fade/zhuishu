import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/model/booklists.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';

/*
* 书单列表信息
* */
@ARoute(url: PageUrl.BOOKS_LIST_COLLECT_PAGE)
class BooksListCollectPage extends StatelessWidget {
  final dynamic params;

  BooksListCollectPage(this.params);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("推荐书单"),
        elevation: 0.0,
      ),
      body: BodyCell(params.params["id"]),
    );
  }
}

class BodyCell extends StatefulWidget {
  final String bookId;

  BodyCell(this.bookId);

  @override
  _BodyCellState createState() => _BodyCellState();
}

class _BodyCellState extends BasePageState<BodyCell> {
  List<BookLists> bookLists = [];
  int total;
  int curIndex = 0;
  String error;
  ScrollController controller;

  get empty => bookLists.isEmpty || total == 0;
  bool loadMoreState = false;

  @override
  void initState() {
    controller = ScrollController();
    controller.addListener(() {
      if (controller.offset >
          controller.position.maxScrollExtent - 100) {
        loadMore();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget buildBody() {
    return empty
        ? buildEmpty()
        : ListView.builder(
      controller: controller,
      itemCount: bookLists.length + 1,
      itemBuilder: (context, index) {
        if (index == bookLists.length) return buildListBottom();
        return buildListItem(index);
      },
    );
  }

  void loadMore() {
    if (curIndex + 20 < total && !loadMoreState) {
      setState(() {
        loadMoreState = true;
      });
      curIndex += 20;
      loadData();
    }
  }

  Widget buildListBottom() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Divider(
          height: 1,
        ),
        Container(
          alignment: Alignment.center,
          height: 40,
          child: loadMoreState
              ? CupertinoActivityIndicator(
            radius: 15.0,
          )
              : TextUtil.build(error != null ? error : "--没有更多--"),
        )
      ],
    );
  }

  Widget buildListItem(index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        title: TextUtil.buildOverFlow(bookLists[index].title,
            fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w700),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextUtil.buildOverFlow(bookLists[index].desc, maxLines: 2),
            SizedBox(height: 5.0,),
            TextUtil.build(
                "${bookLists[index].bookCount}本 | ${bookLists[index].collectorCount}收藏",
                fontSize: 12),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          RouteUtil.push(context, PageUrl.BOOKS_LIST_DETAIL_PAGE,params: {"id":bookLists[index].id});
        },
        leading: CoverImage(
          StringAmend.imgUriAmend(bookLists[index].cover),
          width: 48,
        ),
      ),
    );
  }


  @override
  void loadData() {
    String url =
        "/book-list/${widget.bookId}/recommend?limit=20&start=$curIndex";
    HttpUtil.getJson(url).then((data) {
      bookLists.addAll(BookLists.getBookLists(data["booklists"]));
      total = data["total"];
      loadMoreState = false;
      this.error = null;
      loadSuccessState();
    }).catchError((error) {
      print(error.toString());
      loadMoreState = false;
      this.error = error.toString();
    });
  }

  buildEmpty() {
    return Center(child: TextUtil.build("空空如野", color: Colors.black87));
  }
}