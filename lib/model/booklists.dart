import 'dart:convert' show json;

import 'package:zhuishu/model/categories_info.dart';
import 'package:zhuishu/model/reviews.dart';

class BookLists {
  int bookCount;
  int collectorCount;
  String id;
  String author;
  String cover;
  String desc;
  String gender;
  String title;
  List<String> covers;


  BookLists.fromJson(jsonRes) {
    bookCount = jsonRes['bookCount'];
    collectorCount = jsonRes['collectorCount'];
    id = jsonRes['_id']??jsonRes["id"];
    author = jsonRes['author'];
    cover = jsonRes['cover'];
    desc = jsonRes['desc'];
    gender = jsonRes['gender'];
    title = jsonRes['title'];
    covers = jsonRes['covers'] == null ? null : [];

    for (var coversItem in covers == null ? [] : jsonRes['covers']){
      covers.add(coversItem);
    }
  }

  static List<BookLists> getBookLists(jsonRes){
    List<BookLists> list = [];
    for (var item in jsonRes ?? []){
      list.add(BookLists.fromJson(item));
    }
    return list;
  }

  @override
  String toString() {
    return '{"bookCount": $bookCount,"collectorCount": $collectorCount,"_id": ${id != null?'${json.encode(id)}':'null'},"author": ${author != null?'${json.encode(author)}':'null'},"cover": ${cover != null?'${json.encode(cover)}':'null'},"desc": ${desc != null?'${json.encode(desc)}':'null'},"gender": ${gender != null?'${json.encode(gender)}':'null'},"title": ${title != null?'${json.encode(title)}':'null'},"covers": $covers}';
  }
}

class BookListsDetail {
  Object stickStopTime;
  int collectorCount;
  int total;
  int updateCount;
  bool isDistillate;
  bool isDraft;
  String created;
  String desc;
  String gender;
  String id;
  String shareLink;
  String title;
  String updated;
  List<BookComment> books;
  List<String> tags;
  User author;

  BookListsDetail.fromJson(jsonRes) {
    stickStopTime = jsonRes['stickStopTime'];
    collectorCount = jsonRes['collectorCount'];
    total = jsonRes['total'];
    updateCount = jsonRes['updateCount'];
    isDistillate = jsonRes['isDistillate'];
    isDraft = jsonRes['isDraft'];
    id = jsonRes['_id'];
    created = jsonRes['created'];
    desc = jsonRes['desc'];
    gender = jsonRes['gender'];
    shareLink = jsonRes['shareLink'];
    title = jsonRes['title'];
    updated = jsonRes['updated'];
    books = jsonRes['books'] == null ? null : [];

    for (var booksItem in books == null ? [] : jsonRes['books']){
      books.add(booksItem == null ? null : new BookComment.fromJson(booksItem));
    }

    tags = jsonRes['tags'] == null ? null : [];

    for (var tagsItem in tags == null ? [] : jsonRes['tags']){
      tags.add(tagsItem);
    }

    author = jsonRes['author'] == null ? null : new User.fromJson(jsonRes['author']);
  }

}

class BookComment {
  String comment;
  BookIntro book;

  BookComment.fromJson(jsonRes) {
    comment = jsonRes['comment'];
    book = jsonRes['book'] == null ? null : new BookIntro.fromJson(jsonRes['book']);
  }
}




