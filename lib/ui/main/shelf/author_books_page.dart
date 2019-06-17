import 'package:flutter/material.dart';
import 'package:zhuishu/model/categories_info.dart';
import 'package:zhuishu/router/index.dart';
import 'package:zhuishu/ui/base/base_future_page.dart';
import 'package:zhuishu/ui/widget/book_list_tile.dart';
import 'package:zhuishu/util/net.dart';
import 'package:zhuishu/util/string.dart';
import 'package:zhuishu/util/text.dart';

@ARoute(url: PageUrl.AUTHOR_BOOKS_PAGE)
class BookListPage extends BaseFuturePage {
  final RouteOption option;
  @override
  final String title;

  loadCacheData() async {
    String type = option.params["type"];
    String url;
    if(type == "tag"){
      url = "/book/fuzzy-search?query=$title";
    }else if(type == "like"){
      url = "/book/${option.params["id"]}/recommend";
    }else{
      url = "/book/accurate-search?author=$title";
    }
    return await HttpUtil.getJson(url);
  }

  buildFail(context, error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("images/icon_cartoon.png"),
          SizedBox(
            height: 30,
          ),
          TextUtil.build(error is Error? error.msg : "网络错误",
              fontWeight: FontWeight.w500, fontSize: 16, color: Colors.grey),
        ],
      ),
    );
  }

  BookListPage(this.option) : title = option.params["title"];

  Widget buildItem(BuildContext context, BookIntro book) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: InkWell(
        child: BookListTile(
          icon: StringAmend.imgUriAmend(book.cover),
          name: book.title,
          author: book.author,
          shortIntro: book.shortIntro,
          follower: StringAmend.numAmend(book.latelyFollower),
          minor: book.minorCate == null || book.minorCate.isEmpty
              ? book.majorCate == null || book.majorCate.isEmpty? book.cat : book.majorCate
              : book.minorCate,
        ),
        onTap: () {
          //跳转到对应界面
          RouteUtil.push(context, PageUrl.BOOK_INFO_PAGE,
              params: {"id": book.id});
        },
      ),
    );
  }

  @override
  Widget buildSuccess(context, data) {
    var books = BookIntroList.fromJson(data).books;
    return ListView.builder(
      itemCount: books.length + 1,
      itemBuilder: (context, index){
        if(index == books.length) return buildBottom();
        return buildItem(context, books[index]);
      },
    );
  }

  Widget buildBottom() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Divider(
          height: 1,
        ),
        Container(
          alignment: Alignment.center,
          height: 40,
          child: TextUtil.build("--没有更多--"),
        )
      ],
    );
  }
}
