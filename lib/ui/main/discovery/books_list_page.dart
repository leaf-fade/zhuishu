import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/model/booklists.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/base/const.dart';
import 'package:zhuishu/ui/widget/book_list_tile.dart' show HeadCellItemGroup;
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/ui/widget/tags_popup_menu.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/util/toast.dart';

const double ITEM_HEIGHT = 50.0;
const int ITEM_LINE = 2;
const double TOTAL_HEIGHT = ITEM_HEIGHT * ITEM_LINE;

/*
* 书单
* */
@ARoute(url: PageUrl.BOOKS_LIST_PAGE)
class BooksListPage extends StatelessWidget {
  final dynamic params;

  BooksListPage(this.params);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("书单"),
        elevation: 0.0,
      ),
      body: BooksListWidget(),
    );
  }
}

class BooksListWidget extends StatefulWidget {
  @override
  _BooksListWidgetState createState() => _BooksListWidgetState();
}

class _BooksListWidgetState extends State<BooksListWidget> {
  ScrollController controller;
  double height = TOTAL_HEIGHT;
  String checkUrl;
  double oldOffset = 0;
  String firstLine;
  String secondLine = "";
  String tag = "";
  bool close = false;

  @override
  void initState() {
    firstLine = "${map1.keys.toList()[0]}";
    checkUrl = firstLine;
    controller = ScrollController();
    controller.addListener(() {
      double dy = controller.offset - oldOffset;
      oldOffset = controller.offset;
      if (dy < 0) {
        if (height == TOTAL_HEIGHT) return;
        setState(() {
          height -= dy;
          if(height > TOTAL_HEIGHT) height = TOTAL_HEIGHT;
          close = false;
        });
      } else {
        if (height == ITEM_HEIGHT) return;
        setState(() {
          height -= dy;
          if(height < ITEM_HEIGHT) height = ITEM_HEIGHT;
          close = height == ITEM_HEIGHT;
        });
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
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        AnimatedContainer(
          duration: Duration(milliseconds: 200),
          height: height,
          child: HeadCell(
            close: close,
            onCheck: (String first, String second, String tag) {
              setState(() {
                firstLine = first;
                secondLine = second;
                this.tag = tag;
                checkUrl = appendString(first, second, tag, "&");
              });
            },
            tag: tag,
          ),
        ),
        Divider(
          height: 0.0,
        ),
        Expanded(
          child: Stack(
            children: <Widget>[
              BodyCell(controller, checkUrl),
              TagsPopupMenu(
                showed: tagsMenuOpen,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                    itemCount: 4,
                    itemBuilder: buildTagsItem,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String appendString(String one, String two, String three, String mark) {
    StringBuffer buffer = StringBuffer();
    if (one.isNotEmpty) buffer.write("$one$mark");
    if (two.isNotEmpty) buffer.write("gender=$two$mark");
    if (three.isNotEmpty) buffer.write("tag=$three$mark");
    String str = buffer.toString();
    if (str.isNotEmpty) str = str.substring(0, str.length - 1);
    return str;
  }

  Widget buildTagsItem(context, index) {
    List<String> tagList = tags[index];
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: TextUtil.build(tagList[0]),
          ),
          Wrap(
            spacing: 10.0,
            children: List.generate(
                tagList.length - 1, (index) => buildChip(tagList[index + 1])),
          ),
        ],
      ),
    );
  }

  Widget buildChip(String title) {
    return Container(
      width: 75,
      child: OutlineButton(
        child: TextUtil.build(title, fontSize: 12),
        onPressed: () {
          tagsMenuOpen = false;
          checkUrl = appendString(firstLine, secondLine, title, "&");
          setState(() {
            tag = title;
          });
        },
      ),
    );
  }
}

//头部
class HeadCell extends StatefulWidget {
  final bool close;
  final void Function(String first, String second, String tag) onCheck;
  final String tag;

  @override
  _HeadCellState createState() => _HeadCellState();

  HeadCell({this.close, this.onCheck, this.tag});
}

bool tagsMenuOpen = false;

class _HeadCellState extends State<HeadCell> {
  String firstLine;
  String secondLine;
  String firstValue;
  String secondValue;
  double oldOffset = 0.0;

  @override
  void initState() {
    firstLine = map1.keys.toList()[0];
    secondLine = map2.keys.toList()[0];
    firstValue = map1.values.toList()[0];
    secondValue = map2.values.toList()[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: TOTAL_HEIGHT,
      child: ListView(
        physics: NeverScrollableScrollPhysics(),
        children: <Widget>[
          widget.close ? buildLineClose() : buildLineOne(),
          Divider(
            height: 0.0,
          ),
          buildLineTwo(),
        ],
      ),
    );
  }

  Widget buildLineOne() {
    return SizedBox(
      height: ITEM_HEIGHT,
      child: HeadCellItemGroup(
        texts: map1.values.toList(),
        onCheck: (String value) {
          if(firstValue == value) return;
          tagsMenuOpen = false;
          firstValue = value;
          firstLine = getFirstMapKey(map1, value);
          widget.onCheck(firstLine, secondLine, widget.tag);
        },
        checkText: firstValue,
      ),
    );
  }

  Widget buildLineTwo() {
    return SizedBox(
      height: ITEM_HEIGHT,
      child: Row(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: HeadCellItemGroup(
                texts: map2.values.toList(),
                onCheck: (String value) {
                  if(secondValue == value) return;
                  tagsMenuOpen = false;
                  secondValue = value;
                  secondLine = getFirstMapKey(map2, value);
                  widget.onCheck(firstLine, secondLine, widget.tag);
                },
                checkText: secondValue,
              ),
            ),
          ),
          buildDropDownButton(),
        ],
      ),
    );
  }

  buildDropDownButton() {
    return Row(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: TextUtil.build(widget.tag, color: Colors.red),
        ),
        TagsButton(
          text: "筛选",
          rotated: tagsMenuOpen,
          onPressed: () {
            tagsMenuOpen = !tagsMenuOpen;
            widget.onCheck(firstLine, secondLine, widget.tag);
          },
        ),
      ],
    );
  }


  String getFirstMapKey(Map<String, String> map, String value) {
    for (String key in map.keys) {
      if (map[key] == value) return key;
    }
    return "";
  }

  String appendString(String one, String two, String three, String mark) {
    StringBuffer buffer = StringBuffer();
    if (one.isNotEmpty) buffer.write("$one$mark");
    if (two.isNotEmpty) buffer.write("$two$mark");
    if (three.isNotEmpty) buffer.write("$three$mark");
    String str = buffer.toString();
    if (str.isNotEmpty) str = str.substring(0, str.length - 1);
    return str;
  }

  Widget buildLineClose() {
    return Container(
      alignment: Alignment.center,
      height: ITEM_HEIGHT,
      child: TextUtil.build(
          appendString(firstValue, secondValue, widget.tag, "-")),
    );
  }
}



//列表部分
class BodyCell extends StatefulWidget {
  final ScrollController controller;
  final String checkUrl;

  BodyCell(this.controller, this.checkUrl);

  @override
  _BodyCellState createState() => _BodyCellState();
}

class _BodyCellState extends BasePageState<BodyCell> {
  List<BookLists> bookLists = [];
  int total;
  int curIndex = 0;
  String error;

  get empty => bookLists.isEmpty || total == 0;
  bool loadMoreState = false;
  bool firstInit = true;

  @override
  void initState() {
    widget.controller.addListener(() {
      if (widget.controller.offset >
          widget.controller.position.maxScrollExtent - 100) {
        loadMore();
      }
    });
    super.initState();
  }

  @override
  Widget buildBody() {
    return empty
        ? buildEmpty()
        : ListView.builder(
            controller: widget.controller,
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
  void didUpdateWidget(BodyCell oldWidget) {
    if (oldWidget.checkUrl == widget.checkUrl) return;
    curIndex = 0;
    bookLists?.clear();
    initLoadingState();
    loadData();
    super.didUpdateWidget(oldWidget);
  }

  @override
  void loadData() {
    String url =
        "/book-list?${widget.checkUrl}&start=$curIndex";
    HttpUtil.getJson(url).then((data) {
      bookLists.addAll(BookLists.getBookLists(data["bookLists"]));
      total = data["total"];
      loadMoreState = false;
      this.error = null;
      loadSuccessState();
    }).catchError((error) {
      print(error.toString());
      if(firstInit){
        Toast.show(error is Error ? error.msg : "网络请求失败");
        loadFailState();
        firstInit = false;
      }else{
        loadMoreState = false;
        this.error = error.toString();
      }
    });
  }

  buildEmpty() {
    return Center(child: TextUtil.build("空空如野", color: Colors.black87));
  }
}
