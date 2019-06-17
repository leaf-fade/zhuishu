import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/model/book_info.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/model/reviews.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/widget/book_menu_bar.dart';
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/ui/widget/rating_bar.dart';
import 'package:zhuishu/ui/widget/refresh.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';
import 'package:zhuishu/util/toast.dart';

/*
* 书评--更多界面
* */
const List<String> tabStr = ["论坛", "长评", "短评"];

@ARoute(url: PageUrl.BOOKS_COMMENT_PAGE)
class BookCommentPage extends StatelessWidget {
  final dynamic params;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("书评"),
        elevation: 0.0,
      ),
      body: BookCommentWidget(params.params["type"], params.params["book"],
          params.params["bookData"]),
    );
  }

  BookCommentPage(this.params);
}

class BookCommentWidget extends StatefulWidget {
  final int type;
  final BookInfo bookInfo;
  final BookData bookData;

  @override
  _BookCommentWidgetState createState() => _BookCommentWidgetState();

  BookCommentWidget(this.type, this.bookInfo, this.bookData);
}

class _BookCommentWidgetState extends State<BookCommentWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: widget.type,
      child: Column(
        children: <Widget>[
          Container(
            height: 100,
            child: Card(
              child: ListTile(
                leading: CoverImage(
                  StringAmend.imgUriAmend(widget.bookInfo.cover),
                  height: 60,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                title: Text(widget.bookInfo.title),
                subtitle: TextUtil.build(
                    "${widget.bookInfo.author}  |  ${widget.bookInfo.postCount}人气",
                    fontSize: 12),
                trailing: SaveButton(widget.bookData),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.red,
              unselectedLabelColor: Colors.blueGrey,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: tabStr.map((String name) => Tab(text: name)).toList(),
            ),
          ),
          Expanded(
            child: buildTabBarView(),
          ),
        ],
      ),
    );
  }

  buildTabBarView() {
    return TabBarView(children: [
      ListCommentCell(0, widget.bookInfo.id),
      ListCommentCell(1, widget.bookInfo.id),
      ListCommentCell(2, widget.bookInfo.id),
    ]);
  }
}

class ListCommentCell extends StatefulWidget {
  final int type;
  final String bookId;

  @override
  _ListCommentCellState createState() => _ListCommentCellState();

  ListCommentCell(this.type, this.bookId);
}

class _ListCommentCellState extends BasePageState<ListCommentCell> {
  int start = 0;
  int limit = 20;
  int total = 0;
  String error;
  List<Review> reviews = [];

  int check = 1;
  final List<String> types = ["最新", "最热"];
  final List<String> sortType = ["created", "comment-count"];
  final List<String> sortType2 = ["newest", "hottest"];
  final List<String> msg = ["讨论", "长评", "短评"];

  get empty => reviews == null || total == 0;
  final double heightPadding = 10.0;
  GlobalKey<RefreshHeaderState> _headerKey = GlobalKey<RefreshHeaderState>();
  GlobalKey<RefreshFooterState> _footerKey = GlobalKey<RefreshFooterState>();
  GlobalKey<EasyRefreshState> _easyRefreshKey =
      new GlobalKey<EasyRefreshState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildBody() {
    return empty
        ? buildEmpty()
        : EasyRefresh(
            key: _easyRefreshKey,
            behavior: ScrollOverBehavior(),
            refreshHeader: buildHeader(_headerKey, error: error),
            refreshFooter: buildFooter(_footerKey, error: error),
            onRefresh: onRefresh,
            loadMore: loadMore,
            autoLoad: true,
            child: ListView.separated(
              itemCount: reviews.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return buildTitle();
                return buildCommentItem(context, reviews[index - 1]);
              },
              separatorBuilder: (context, index) => Divider(
                    height: 1.0,
                  ),
            ));
  }

  buildTitle() {
    return ListTile(
      leading: Row(
        children: <Widget>[
          Icon(
            Icons.message,
            size: 16,
            color: Colors.grey,
          ),
          SizedBox(
            width: 5.0,
          ),
          TextUtil.build("$total条${msg[widget.type]}")
        ],
      ),
      trailing: RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          children: [
            TextSpan(
              text: types[0],
              style: check == 0
                  ? TextStyle(color: Colors.red, fontSize: 16)
                  : null,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (check == 0) return;
                  setState(() {
                    check = 0;
                  });
                  _easyRefreshKey.currentState.callRefresh();
                },
            ),
            TextSpan(
              text: " | ",
            ),
            TextSpan(
              text: types[1],
              style: check == 1
                  ? TextStyle(color: Colors.red, fontSize: 16)
                  : null,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  if (check == 1) return;
                  setState(() {
                    check = 1;
                  });
                  _easyRefreshKey.currentState.callRefresh();
                },
            )
          ],
        ),
      ),
    );
  }

  buildEmpty() {
    return Center(child: TextUtil.build("空空如野", color: Colors.black87));
  }

  //讨论
  Widget buildDiscussItem(Review comment) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundImage: CachedNetworkImageProvider(
              "http://statics.zhuishushenqi.com${comment.author.avatar}"),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextUtil.build("${comment.author.nickname} lv.${comment.author.lv}",
                fontSize: 12, color: Color(0xffe7dcbe)),
            TextUtil.build(
              StringAmend.getTimeDuration(comment.created),
              fontSize: 12,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 5.0,
            ),
            TextUtil.buildOverFlow(comment.title,
                maxLines: 2,
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
            SizedBox(
              height: 5.0,
            ),
            Row(
              children: <Widget>[
                Icon(MyIcon.message,size: 13,color: Colors.grey,),
                SizedBox(width: 5.0,),
                TextUtil.build(comment.commentCount.toString(), fontSize: 12),
                SizedBox(width: 10.0,),
                Icon(MyIcon.love,size: 13,color: Colors.grey,),
                SizedBox(width: 5.0,),
                TextUtil.build(comment.likeCount.toString(), fontSize: 12),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        onTap: (){
          RouteUtil.push(context, PageUrl.BOOKS_COMMENT_DETAIL_PAGE,
              params: {"review": comment,"type": 0});
        },
      ),
    );
  }

  //评论
  Widget buildCommentItem(BuildContext context, Review review) {
    if (widget.type == 0) return buildDiscussItem(review);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      child: InkWell(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              buildAvatar(review.author),
              buildRate(review.rating),
              buildComment(review.content, title: review.title),
              buildBottom(review.updated, review.likeCount),
            ],
          ),
        ),
        onTap: review.title == null
            ? null
            : () {
                RouteUtil.push(context, PageUrl.BOOKS_COMMENT_DETAIL_PAGE,
                    params: {"review": review,"type":1});
              },
      ),
    );
  }

  //评论者信息
  Widget buildAvatar(User user) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: heightPadding),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              radius: 13,
              backgroundImage: CachedNetworkImageProvider(
                  "http://statics.zhuishushenqi.com${user.avatar}"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              child: TextUtil.build(user.nickname),
            ),
            TextUtil.buildBorder("Lv${user.lv}",
                vertical: 1.0, horizontal: 5.0),
          ],
        ));
  }

  //评分
  Widget buildRate(int rating) {
    return Row(
      children: <Widget>[
        RatingBar(
          size: 12.0,
          rate: rating.toDouble(),
        ),
        SizedBox(
          width: 5.0,
        ),
        TextUtil.build(RatingBar.ratingText[rating - 1],
            fontSize: 10, color: Colors.grey[400]),
      ],
    );
  }

  //评论内容
  Widget buildComment(String content, {String title}) {
    List<Widget> commentList = [];
    if (title != null) {
      commentList.add(TextUtil.buildOverFlow(title,
          fontSize: 14.0, fontWeight: FontWeight.w500, color: Colors.black));
      commentList.add(
        SizedBox(
          height: heightPadding,
        ),
      );
      commentList.add(
        TextUtil.buildOverFlow(
          content.replaceAll("\n", ""),
          maxLines: 3,
        ),
      );
    } else {
      commentList.add(
        TextUtil.build(
          content.replaceAll("\n", ""),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: heightPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: commentList,
      ),
    );
  }

  //评论底部(时间 + 留言)
  Widget buildBottom(String updated, int likeCount) {
    return Padding(
      padding: EdgeInsets.only(bottom: heightPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextUtil.build(StringAmend.getTimeDuration(updated)),
          Row(
            children: <Widget>[
              Icon(
                Icons.thumb_up,
                color: Colors.grey,
                size: 16.0,
              ),
              SizedBox(
                width: 5.0,
              ),
              TextUtil.build(likeCount.toString())
            ],
          ),
        ],
      ),
    );
  }

  @override
  void loadData() {
    onNetConnect(init: true, clear: true);
  }

  Future<void> onNetConnect({bool init = false, bool clear = false}) async {
    String url;
    if (widget.type == 0) {
      url =
          "/post/by-book?book=${widget.bookId}&sort=${sortType[check]}&type=normal,vote&start=$start&limit=$limit";
    } else if (widget.type == 1) {
      url =
          "/post/review/by-book?book=${widget.bookId}&start=$start&limit=$limit&sortType=${sortType2[check]}";
    } else if (widget.type == 2) {
      url =
          "/post/short-review?book=${widget.bookId}&start=$start&limit=$limit&sortType=${sortType2[check]}&total=true";
    }
    await HttpUtil.getJson(url).then((data) {
      if (init) reviews.clear();
      if (widget.type == 0) {
        reviews.addAll(Review.getReviews(data["posts"]));
        total = data["total"];
      } else if (widget.type == 1) {
        var comment = Reviews.fromJson(data);
        reviews.addAll(comment.reviews);
        total = comment.total;
      } else if (widget.type == 2) {
        var comment = ShortReviews.fromJson(data);
        reviews.addAll(comment.reviews);
        total = comment.total;
      }
      error = null;
      loadSuccessState();
    }).catchError((error) {
      print(error.toString());
      Toast.show(error is Error ? error.msg : "网络请求失败");
      init ? loadFailState() : error = error.toString();
    });
  }

  Future<void> onRefresh() async {
    start = 0;
    await onNetConnect(clear: true);
  }

  Future<void> loadMore() async {
    if (start + limit >= total) return null;
    start += limit;
    await onNetConnect();
  }
}
