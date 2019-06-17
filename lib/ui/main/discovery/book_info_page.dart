import 'package:flutter/material.dart';
import 'package:my_icon/my_icon.dart';
import 'package:zhuishu/model/book_info.dart';
import 'package:zhuishu/model/book_shelf_data.dart';
import 'package:zhuishu/model/booklists.dart';
import 'package:zhuishu/model/categories_info.dart';
import 'package:zhuishu/model/reviews.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/base/my_color.dart';
import 'package:zhuishu/ui/reader/catalogue_list_page.dart';
import 'package:zhuishu/ui/widget/book_list_tile.dart';
import 'package:zhuishu/ui/widget/book_menu_bar.dart';
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/ui/widget/fold_text.dart';
import 'package:zhuishu/ui/widget/rating_bar.dart';
import 'package:zhuishu/util/icon.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';
import 'package:cached_network_image/cached_network_image.dart';

/*
* 主界面：发现 - 分类 - 玄幻 - 圣墟（书籍）
* */
@ARoute(url: PageUrl.BOOK_INFO_PAGE)
class BookInfoPage extends StatelessWidget {
  final dynamic option;

  BookInfoPage(this.option);

  @override
  Widget build(BuildContext context) {
    String bookId = option.params["id"];
    return Scaffold(
      body: BookInfoWidget(
        bookId: bookId,
      ),
    );
  }
}

class BookInfoWidget extends StatefulWidget {
  final String bookId;

  @override
  _BookInfoWidgetState createState() => _BookInfoWidgetState();

  BookInfoWidget({
    this.bookId,
  });
}

class _BookInfoWidgetState extends BasePageState<BookInfoWidget> {
  ScrollController _scrollController;
  Color _color;
  final startColor = MyColor.orange;
  final endColor = Colors.white;
  bool isColorChange = false;
  double headHeight = 150.0;
  BookInfo _bookInfo;
  BookData bookData;
  ShortReviews _shortReviews;
  Reviews _reviews;
  BookIntroList _recommendList;
  List<BookLists> bookLists;
  int bookListsTotal;
  bool isAddToShelf = false;

  @override
  void initState() {
    _color = startColor;
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels > headHeight && !isColorChange) {
          setState(() {
            _color = endColor;
            isColorChange = true;
          });
        }

        if (_scrollController.position.pixels <= headHeight && isColorChange) {
          setState(() {
            _color = startColor;
            isColorChange = false;
          });
        }
      });
    SpHelper.isAddToShelf(widget.bookId).then((isAdd) {
      isAddToShelf = isAdd;
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget buildBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: buildBookDetail(),
        ),
        BookMenuBar(bookData, isAddToShelf),
      ],
    );
  }

  Widget buildBookDetail() {
    return Scaffold(
      backgroundColor: endColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.grey[600]),
        backgroundColor: _color,
        actions: <Widget>[
          buildIcon(
            icon: Icons.message,
            onTap: (){
              if(_bookInfo!=null){
                RouteUtil.push(context, PageUrl.BOOKS_COMMENT_PAGE,
                    params: {"type": 0 ,"book": _bookInfo, "bookData": bookData});
              }
            },
            color: Colors.grey
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Icon(Icons.share),
          ),
        ],
      ),
      body: ListView(
        controller: _scrollController,
        children: <Widget>[
          buildTitle(),
          HeadCell(_bookInfo, bookData),
          buildPageDivider(),
          CommentCell("精彩短评", _shortReviews.reviews, _bookInfo, bookData),
          buildPageDivider(),
          CommentCell("精彩长评", _reviews.reviews, _bookInfo,bookData),
          buildPageDivider(),
          RelatedCell("本书追友还在读", _recommendList.books, widget.bookId),
          buildPageDivider(),
          BooksListCell(widget.bookId, bookListsTotal, bookLists),
          buildPageDivider(),
        ],
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

  //标题
  Widget buildTitle() {
    return Container(
      height: headHeight,
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        gradient: MyColor.getGradient(),
      ),
      child: Row(
        children: <Widget>[
          CoverImage(
            StringAmend.imgUriAmend(_bookInfo.cover),
            width: 90.0,
            height: 130.0,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      child: TextUtil.build(_bookInfo.title,
                          fontSize: 24.0,
                          color: Colors.black,
                          fontWeight: FontWeight.w700),
                    ),
                    InkWell(
                      onTap: () {
                        RouteUtil.push(context, PageUrl.AUTHOR_BOOKS_PAGE,
                            params: {"title": _bookInfo.author});
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextUtil.build(_bookInfo.author,
                            fontSize: 18.0,
                            color: Colors.red,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                      child: TextUtil.build(
                        "${StringAmend.numAmendInt(_bookInfo.wordCount)}字",
                        fontSize: 16.0,
                      ),
                    )
                  ]),
            ),
          )
        ],
      ),
    );
  }

  @override
  void loadData() {
    String bookInfoUri = "/book/${widget.bookId}";
    String shortReviewsUri =
        "/post/short-review?book=${widget.bookId}&sortType=hottest&&total=true&limit=2";
    String reviewsUri =
        "/post/review/best-by-book?book=${widget.bookId}&sortType=hottest&limit=3";
    String recommendUri = "/book/${widget.bookId}/recommend";
    String bookslistUri = "/book-list/${widget.bookId}/recommend?limit=2";
    netConnect(bookInfoUri, (data) {
      print("===========1.书籍信息============");
      _bookInfo = BookInfo.fromJson(data);
      bookData = BookData(
        bookName: _bookInfo.title.replaceAll(" ", "").replaceAll("\n", ""),
        bookId: widget.bookId,
        coverUrl: StringAmend.imgUriAmend(_bookInfo.cover),
        chapterId: 0,
        lastChapterInfo: _bookInfo.lastChapter,
        lastUpdate: _bookInfo.updated,
      );
    }, checkOk: loadDataOk);
    netConnect(shortReviewsUri, (data) {
      print("===========2.短评============");
      _shortReviews = ShortReviews.fromJson(data);
    }, checkOk: loadDataOk);
    netConnect(reviewsUri, (data) {
      print("===========3.长评============");
      _reviews = Reviews.fromJson(data);
    }, checkOk: loadDataOk);
    netConnect(recommendUri, (data) {
      print("===========4.记录============");
      _recommendList = BookIntroList.fromJson(data);
    }, checkOk: loadDataOk);
    netConnect(bookslistUri, (data) {
      print("===========5.推荐书单============");
      bookLists = BookLists.getBookLists(data["booklists"]);
      bookListsTotal = data["total"];
    }, checkOk: loadDataOk);
  }

  bool loadDataOk() =>
      _bookInfo != null &&
      _shortReviews != null &&
      _reviews != null &&
      _recommendList != null &&
      bookLists != null;
}

//头部组成
class HeadCell extends StatelessWidget {
  final BookInfo _bookInfo;
  final BookData _bookData;

  HeadCell(this._bookInfo, this._bookData);

  @override
  Widget build(BuildContext context) {
    return buildHead(context);
  }

  Widget buildHead(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: <Widget>[
          buildRate(),
          buildShortIntro(),
          SizedBox(
            height: 10.0,
          ),
          Divider(height: 1),
          buildCatalog(context),
        ],
      ),
    );
  }

  //评分
  Widget buildRate() {
    var textSize = 21.0;
    return _bookInfo.rating == null
        ? Container()
        : Container(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                buildRateItem(
                    Row(
                      children: <Widget>[
                        TextUtil.build(
                            _bookInfo.rating.score.toStringAsFixed(1),
                            fontSize: textSize,
                            color: Colors.grey[600]),
                        SizedBox(
                          width: 3.0,
                        ),
                        RatingBar(
                          size: 18.0,
                          rate: _bookInfo.rating.score ?? 0 / 2,
                        )
                      ],
                    ),
                    TextUtil.build("${_bookInfo.rating.count} 人评价")),
                buildRateItem(
                    TextUtil.build("${_bookInfo.retentionRatio}%",
                        fontSize: textSize, color: Colors.grey[600]),
                    TextUtil.build("读者留存")),
                buildRateItem(
                    TextUtil.build("${_bookInfo.latelyFollower}",
                        fontSize: textSize, color: Colors.grey[600]),
                    TextUtil.build("追书人气")),
              ],
            ),
          );
  }

  Widget buildRateItem(Widget left, Widget right) {
    return Column(
      children: <Widget>[
        left,
        right,
      ],
    );
  }

  //简介
  Widget buildShortIntro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          width: double.infinity,
          child: TextUtil.build("简介", fontSize: 16.0, color: Colors.grey[600]),
        ),
        FoldTextView(_bookInfo.longIntro),
      ],
    );
  }

  //目录
  Widget buildCatalog(BuildContext context) {
    String str = _bookInfo.isFineBook
        ? "已完结  共${_bookInfo.chaptersCount}章"
        : _bookInfo.lastChapter;
    return NormalListTile(
      left: <Widget>[
        TextUtil.build("目录", fontSize: 16.0, color: Colors.grey[600]),
      ],
      right: <Widget>[
        Container(
          width: 180.0,
          alignment: Alignment(1, 0),
          child: TextUtil.buildOverFlow(str, color: Colors.blueGrey),
        ),
        Icon(
          Icons.keyboard_arrow_right,
          color: Colors.grey,
        )
      ],
      onTap: () {
        SpHelper.getShelfBookChapterId(_bookData.bookId)
            .then((chapterId) async {
          _bookData.chapterId = chapterId ?? 0;
          showGeneralDialog(
            context: context,
            pageBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation) {
              return CatalogueListPage(
                bookData: _bookData,
              );
            },
            transitionDuration: Duration(milliseconds: 400),
            barrierDismissible: false,
          );
        });
      },
    );
  }
}

//评论组成
class CommentCell extends StatelessWidget {
  final String commentName;
  final List<Review> reviews;
  final BookInfo bookInfo;
  final BookData bookData;
  final double heightPadding = 10.0;

  CommentCell(this.commentName, this.reviews, this.bookInfo, this.bookData);

  @override
  Widget build(BuildContext context) {
    return buildCommentList(context);
  }

  //评论列表
  Widget buildCommentList(BuildContext context) {
    List<Widget> list = [];
    if(commentName!=null||commentName.isNotEmpty){
      Widget topTitle = Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            TextUtil.build(commentName, fontSize: 16.0),
            GestureDetector(
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Icon(
                      MyIcon.pen,
                      color: Colors.redAccent,
                      size: 16,
                    ),
                  ),
                  SizedBox(
                    width: 5.0,
                  ),
                  TextUtil.build("写书评", color: Colors.redAccent, fontSize: 15.0),
                ],
              ),
              onTap: () {
                //跳转到写作界面
              },
            )
          ],
        ),
      );
      list.add(topTitle);
      list.add(
        Divider(height: 1),
      );
    }

    if (reviews.length != null) {
      list.addAll(List.generate(reviews.length,
          (index) => buildCommentItem(context, reviews[index])));
    }
    Widget bottomMore = InkWell(
      child: Container(
        height: 50,
        alignment: Alignment.center,
        child: TextUtil.build(
          "查看全部书评",
          fontSize: 16,
          color: Colors.red,
        ),
      ),
      onTap: () {
        RouteUtil.push(context, PageUrl.BOOKS_COMMENT_PAGE,
            params: {"type": commentName=="精彩短评"? 2 : 1 ,"book": bookInfo, "bookData": bookData});
      },
    );
    list.add(bottomMore);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        children: list,
      ),
    );
  }

  //评论
  Widget buildCommentItem(BuildContext context, Review review) {
    return InkWell(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildAvatar(review.author),
            buildRate(review.rating),
            buildComment(review.content, title: review.title),
            buildBottom(review.updated, review.likeCount),
            Divider(height: 1),
          ],
        ),
      ),
      onTap: review.title == null
          ? null
          : () {
              RouteUtil.push(context, PageUrl.BOOKS_COMMENT_DETAIL_PAGE,
                  params: {"review": review,"type" : 1});
            },
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
              backgroundImage: CachedNetworkImageProvider("http://statics.zhuishushenqi.com${user.avatar}"),
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
          rate: rating?.toDouble()??1.0,
        ),
        SizedBox(
          width: 5.0,
        ),
        TextUtil.build(RatingBar.ratingText[(rating??1) - 1],
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
}

bool isMore = false;

//相关组成
class RelatedCell extends StatelessWidget {
  final String title;
  final List<BookIntro> _list;
  final String bookId;

  RelatedCell(this.title, this._list, this.bookId);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextUtil.build(title, fontSize: 16.0),
            buildContent(context),
            Center(
              child: isMore
                  ? InkWell(
                      child: Container(
                        height: 50,
                        alignment: Alignment.center,
                        child: TextUtil.build(
                          "查看全部",
                          fontSize: 16,
                          color: Colors.red,
                        ),
                      ),
                      onTap: () {
                        RouteUtil.push(context, PageUrl.AUTHOR_BOOKS_PAGE,
                            params: {
                              "title": "你可能喜欢的",
                              "type": "like",
                              "id": bookId
                            });
                      },
                    )
                  : SizedBox.shrink(),
            ),
          ],
        ));
  }

  Widget buildContent(BuildContext context) {
    isMore = _list.length > 4;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: List.generate(isMore ? 4 : _list.length, (index) {
          return buildContentItem(context, _list[index].id, _list[index].cover,
              _list[index].title, _list[index].author);
        }),
      ),
    );
  }

  //书名加封面
  Widget buildContentItem(BuildContext context, String id, String imgUrl,
      String bookName, String bookAuthor) {
    return GestureDetector(
      child: Container(
        width: 82.0,
        child: Column(
          children: <Widget>[
            CoverImage(
              StringAmend.imgUriAmend(imgUrl),
              width: 70.0,
              height: 100.0,
            ),
            TextUtil.buildOverFlow(bookName),
          ],
        ),
      ),
      onTap: () {
        RouteUtil.push(context, PageUrl.BOOK_INFO_PAGE, params: {"id": id});
      },
    );
  }
}

//推荐书单
class BooksListCell extends StatelessWidget {
  final List<BookLists> bookLists;
  final int total;
  final String bookId;

  BooksListCell(this.bookId,this.total, this.bookLists);

  @override
  Widget build(BuildContext context) {
    int count = total > 2 ?  3 : bookLists.length + 1;
    return bookLists.isEmpty
        ? SizedBox.shrink()
        : Column(
            children: List.generate(count, (index) {
              if (index == 0) return buildHeader(context);
              return buildListItem(context, index-1);
            }),
          );
  }

  Widget buildHeader(context) {
    return Container(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: TextUtil.build("推荐书单", fontSize: 16.0),
          ),
          total > 2
              ? FlatButton(
                  onPressed: () {
                    RouteUtil.push(context, PageUrl.BOOKS_LIST_COLLECT_PAGE,params: {"id": bookId});
                  },
                  child: TextUtil.build("更多", fontSize: 12.0),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget buildListItem(context, index) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0,),
      child: ListTile(
        title: TextUtil.buildOverFlow(bookLists[index].title,
            fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w700),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextUtil.buildOverFlow(bookLists[index].desc, maxLines: 2),
            SizedBox(
              height: 5.0,
            ),
            TextUtil.build(
                "${bookLists[index].bookCount}本 | ${bookLists[index].collectorCount}收藏",
                fontSize: 12),
          ],
        ),
        isThreeLine: true,
        onTap: () {
          RouteUtil.push(context, PageUrl.BOOKS_LIST_DETAIL_PAGE,
              params: {"id": bookLists[index].id});
        },
        leading: CoverImage(
          StringAmend.imgUriAmend(bookLists[index].cover),
          width: 48,
        ),
      ),
    );
  }
}
