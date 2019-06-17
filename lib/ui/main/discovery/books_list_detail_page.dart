import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/model/booklists.dart';
import 'package:zhuishu/model/reviews.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_page.dart';
import 'package:zhuishu/ui/base/my_color.dart';
import 'package:zhuishu/ui/widget/cover_image.dart';
import 'package:zhuishu/ui/widget/fold_text.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';


@ARoute(url: PageUrl.BOOKS_LIST_DETAIL_PAGE)
class BooksListDetailPage extends StatelessWidget {
  final dynamic params;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("书单详情"),
        elevation: 0.0,
      ),
      body: BookListDetailWidget(params.params["id"]),
    );
  }

  BooksListDetailPage(this.params);
}

class BookListDetailWidget extends StatefulWidget {
  final String id;
  @override
  _BookListDetailWidgetState createState() => _BookListDetailWidgetState();

  BookListDetailWidget(this.id);
}

class _BookListDetailWidgetState extends BasePageState<BookListDetailWidget> {

  BookListsDetail _bookListsDetail;

  Widget buildHeader(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
          child: buildAvatar(_bookListsDetail.author),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child:  TextUtil.build(_bookListsDetail.title,fontSize: 15, fontWeight: FontWeight.w700,color: Colors.black87),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
          child: TextUtil.build(_bookListsDetail.desc),
        ),
      ],
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
  Widget buildAvatar(User user) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 18,
          backgroundImage: CachedNetworkImageProvider("http://statics.zhuishushenqi.com${user.avatar}"),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: TextUtil.build(user.nickname,color: Color(0xffe7dcbe)),
                ),
                TextUtil.buildBorder("Lv${user.lv}",
                    vertical: 1.0, horizontal: 5.0, color: Color(0xffe7dcbe),),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: TextUtil.build(StringAmend.getTimeDuration(_bookListsDetail.updated),fontSize: 10),
            ),
          ],
        )
      ],
    );
  }

  Widget buildList(int index, List<BookComment> comments){
    List<Widget> commentList = [];
    commentList.add(ListTile(
      title: TextUtil.buildOverFlow(comments[index].book.title,
          fontSize: 15, color: Colors.black87, fontWeight: FontWeight.w700),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.person,
                color: Colors.grey,
                size: 14.0,
              ),
              SizedBox(width: 5.0,),
              TextUtil.buildOverFlow(comments[index].book.author),
            ],
          ),
          SizedBox(height: 5.0,),
          TextUtil.build(
              "${comments[index].book.majorCate??""}    ${StringAmend.numAmend(comments[index].book.latelyFollower)}人气",
              fontSize: 12),
        ],
      ),
      isThreeLine: true,
      leading: CoverImage(
        StringAmend.imgUriAmend(comments[index].book.cover),
        width: 48,
      ),
    ),);
    if(comments[index].comment !=null && comments[index].comment.isNotEmpty){
      commentList.add(Divider(),);
      commentList.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 15.0),
        child: FoldTextView(comments[index].comment,),
      ),);
    }
    return InkWell(
      onTap: (){
        RouteUtil.push(context, PageUrl.BOOK_INFO_PAGE, params: {"id": comments[index].book.id});
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: commentList,
      ),
    );
  }

  @override
  Widget buildBody() {
    return ListView.separated(
      itemCount: _bookListsDetail.books.length+1,
      itemBuilder: (context,index){
        if(index==0) return buildHeader();
        return buildList(index - 1,_bookListsDetail.books);
      },
      separatorBuilder: (context,index)=> buildPageDivider(),
    );
  }

  @override
  void loadData() {
    String url = "/book-list/${widget.id}";
    netConnect(url, (data){
      _bookListsDetail = BookListsDetail.fromJson(data["bookList"]);
    });
  }
}

