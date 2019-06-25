import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/model/reviews.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/base/my_color.dart';
import 'package:zhuishu/ui/widget/rating_bar.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';

@ARoute(url: PageUrl.BOOKS_COMMENT_DETAIL_PAGE)
class BookCommentDetailPage extends StatelessWidget {
  final dynamic params;

  @override
  Widget build(BuildContext context) {
    int type = params.params["type"] ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: Text(type == 0 ? "讨论详情" : "书评详情"),
        elevation: 0.0,
      ),
      backgroundColor: Colors.white,
      body: BookCommentDetailWidget(type, params.params["review"]),
    );
  }

  BookCommentDetailPage(this.params);
}

class BookCommentDetailWidget extends StatefulWidget {
  final Review review;
  final int type;

  @override
  _BookCommentDetailWidgetState createState() =>
      _BookCommentDetailWidgetState();

  BookCommentDetailWidget(this.type, this.review);
}

class _BookCommentDetailWidgetState
    extends BasePageState<BookCommentDetailWidget> {
  List<ReviewComment> _commentList;
  List<ReviewComment> _bestCommentList;
  ScrollController controller;
  bool loadMoreState = false;
  int curIndex = 0;
  int total;
  String error;

  @override
  void initState() {
    controller = ScrollController()
      ..addListener(() {
        if (controller.offset > controller.position.maxScrollExtent - 100) {
          print("============滚动=============");
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

  Widget buildHeader(Review review) {
    print("============头部============");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: buildAvatar(review.author, review.created),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: TextUtil.build(review.title,
              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.black87),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: TextUtil.buildAll(review.content,
              color: Colors.blueGrey, onValue: (type, value) {
                switch(type){
                  case "url":
                    String id = value.split(":")[1];
                    RouteUtil.push(context, PageUrl.BOOKS_COMMENT_DETAIL_PAGE,
                        params: {"review": Review(id),"type": 0});
                    break;
                  case "tag":
                    RouteUtil.push(context, PageUrl.AUTHOR_BOOKS_PAGE,
                        params: {"title": value, "type": type});
                    break;
                }
              }),
        ),
        buildCommentHelpful(),
      ],
    );
  }

  //书评评价
  buildCommentHelpful() {
    return widget.review.helpful == null
        ? SizedBox.shrink()
        : Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Icon(
                          Icons.thumb_up,
                          size: 16,
                          color: Colors.grey,
                        ),
                        Icon(
                          Icons.thumb_down,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        TextUtil.build("${widget.review.helpful.yes}"),
                        TextUtil.build("${widget.review.helpful.no}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  //分区块
  Widget buildPageDivider() {
    return Container(
      height: 10.0,
      color: MyColor.divider,
    );
  }

  //评论者信息
  Widget buildAvatar(User author, String updated) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 18,
          backgroundImage: CachedNetworkImageProvider(
              "http://statics.zhuishushenqi.com${author.avatar}"),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child:
                      TextUtil.build(author.nickname, color: Color(0xffe7dcbe)),
                ),
                TextUtil.buildBorder(
                  "Lv${author.lv}",
                  vertical: 1.0,
                  horizontal: 5.0,
                  color: Color(0xffe7dcbe),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  widget.review.rating == null
                      ? SizedBox()
                      : RatingBar(
                          size: 12.0,
                          rate: widget.review.rating.toDouble(),
                        ),
                  SizedBox(
                    width: 5.0,
                  ),
                  TextUtil.build(StringAmend.getTimeDuration(updated),
                      fontSize: 10),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget buildBody() {
    return CustomScrollView(
      controller: controller,
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: buildHeader(widget.review),
        ),
        SliverToBoxAdapter(
          child: buildPageDivider(),
        ),
        buildList("仰望神评论", 0, _bestCommentList),
        buildList("评论", 1, _commentList),
        SliverToBoxAdapter(
          child: buildListBottom(),
        ),
      ],
    );
  }

  void loadMore() {
    print(total);
    if (curIndex + 30 < total && !loadMoreState) {
      setState(() {
        loadMoreState = true;
      });
      curIndex += 30;
      loadCommentData();
    }
  }

  void loadCommentData() {
    String url;
    if (widget.type == 0) {
      url = "/post/${widget.review.id}/comment?start=$curIndex&limit=30";
    } else if (widget.type == 1) {
      url = "/post/review/${widget.review.id}/comment?start=$curIndex&limit=30";
    }
    HttpUtil.getJson(url).then((data) {
      _commentList.addAll(ReviewComment.getReviewComments(data["comments"]));
      loadMoreState = false;
      this.error = null;
      loadSuccessState();
    }).catchError((error) {
      print(error.toString());
      loadMoreState = false;
      this.error = error.toString();
    });
  }

  @override
  void loadData() {
    print("========初始化==========");
    String url;
    if (widget.type == 0) {
      url = "/post/${widget.review.id}?keepImage=1";
      netConnect(url, (data) {
        widget.review.copy(Review.fromJson(data["post"]));
      }, checkOk: checkOk);
      url = "/post/${widget.review.id}/comment?start=0&limit=30";
    } else if (widget.type == 1) {
      url = "/post/review/${widget.review.id}/comment?start=0&limit=30";
    }
    netConnect(url, (data) {
      _commentList = ReviewComment.getReviewComments(data["comments"]);
      if (_commentList.isNotEmpty) {
        total = _commentList[0].floor;
      }
    }, checkOk: checkOk);

    url = "/post/${widget.review.id}/comment/best";
    netConnect(url, (data) {
      _bestCommentList = ReviewComment.getReviewComments(data["comments"]);
    }, checkOk: checkOk);
  }

  bool checkOk() =>
      _bestCommentList != null &&
      _commentList != null &&
      widget.review.content != null;

  Widget buildList(String title, int type, List<ReviewComment> list) {
    print("$title    $list");
    int count = (list.length == 0 ? 1 : list.length) + 2;
    return list.isEmpty && type == 0
        ? SliverToBoxAdapter(
            child: SizedBox.shrink(),
          )
        : SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (index == 0)
                return Container(
                  height: 50.0,
                  alignment: Alignment(-1, 0),
                  padding: EdgeInsets.symmetric(horizontal: 15.0),
                  child: TextUtil.build(title,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                      fontSize: 16),
                );
              if (index == count - 1) return buildPageDivider();
              if (list.isNotEmpty) {
                return buildItem(index - 1, list);
              } else {
                return buildCommentEmpty();
              }
            }, childCount: count),
          );
  }

  Widget buildItem(int index, List<ReviewComment> list) {
    ReviewComment comment = list[index];
    return ListTile(
      leading: CircleAvatar(
        radius: 18,
        backgroundImage: CachedNetworkImageProvider(
            "http://statics.zhuishushenqi.com${comment.author.avatar}"),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextUtil.build(
              "${comment.floor}楼 ${comment.author.nickname} lv.${comment.author.lv}",
              fontSize: 12,
              color: Color(0xffe7dcbe)),
          Row(
            children: <Widget>[
              Icon(
                MyIcon.love,
                size: 13,
                color: Colors.blueGrey,
              ),
              SizedBox(
                width: 5.0,
              ),
              TextUtil.build(comment.likeCount.toString(), fontSize: 12),
            ],
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 5.0,
          ),
          TextUtil.buildClick(comment.content, color: Colors.blueGrey,
              onValue: (type, value) {
            RouteUtil.push(context, PageUrl.AUTHOR_BOOKS_PAGE, params: {
              "title": value,
              "type": "tag",
            });
          }),
          SizedBox(
            height: 5.0,
          ),
          Row(
            children: <Widget>[
              TextUtil.build(StringAmend.getTimeDuration(comment.created),
                  fontSize: 10),
              comment.replyAuthor == null
                  ? SizedBox.shrink()
                  : TextUtil.buildOverFlow(
                      "回复 ${comment.replyTo}楼 ${comment.replyAuthor}",
                      fontSize: 10),
            ],
          ),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget buildCommentEmpty() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Divider(
          height: 1,
        ),
        Container(
          alignment: Alignment.center,
          height: 100,
          child: TextUtil.build("无评论"),
        )
      ],
    );
  }
}
