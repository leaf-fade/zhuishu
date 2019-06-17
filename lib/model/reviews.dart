/*
* 书评
* */

import 'package:zhuishu/util/string.dart';

class ShortReviews {
  bool ok;
  int total;
  int today;
  List<Review> reviews;

  ShortReviews.fromJson(jsonRes) {
    ok = jsonRes['ok'];
    total = jsonRes['total'];
    today = jsonRes['today'];
    reviews = jsonRes['docs'] == null ? null : [];

    for (var reviewsItem in reviews == null ? [] : jsonRes['docs']){
      reviews.add(reviewsItem == null ? null : Review.fromJson(reviewsItem));
    }
  }
}

class Reviews {
  bool ok;
  int total;
  int today;
  List<Review> reviews;

  Reviews.fromJson(jsonRes) {
    ok = jsonRes['ok'];
    total = jsonRes['total'];
    today = jsonRes['today'];
    reviews = jsonRes['reviews'] == null ? null : [];

    for (var reviewsItem in reviews == null ? [] : jsonRes['reviews']){
      reviews.add(reviewsItem == null ? null : Review.fromJson(reviewsItem));
    }
  }
}

//评论
class Review {
  int commentCount;
  int likeCount;
  int rating;
  String id;
  String content;
  String created;
  String state;
  String title;
  String updated;
  User author;
  Helpful helpful;

  Review(this.id);

  void copy(Review other){
    commentCount = other.commentCount;
    likeCount = other.likeCount;
    id = other.id;
    content = other.content;
    created = other.created;
    state = other.state;
    title = other.title;
    updated = other.updated;
    author = other.author;
    helpful = other.helpful;
  }

  Review.fromJson(jsonRes) {
    commentCount = jsonRes['commentCount'];
    likeCount = jsonRes['likeCount'];
    rating = jsonRes['rating'];
    id = jsonRes['_id'];
    content = jsonRes['content'];
    created = jsonRes['created'];
    state = jsonRes['state'];
    title = jsonRes['title'];
    updated = jsonRes['updated'];
    author = jsonRes['author'] == null ? null : new User.fromJson(jsonRes['author']);
    helpful = jsonRes['helpful'] == null ? null : new Helpful.fromJson(jsonRes['helpful']);
  }

  static List<Review> getReviews(jsonRes){
    List<Review> list = [];
    for (var item in jsonRes ?? []){
      list.add(Review.fromJson(item));
    }
    return list;
  }
}


class Helpful {

  int no;
  int total;
  int yes;

  Helpful.fromParams({this.no, this.total, this.yes});

  Helpful.fromJson(jsonRes) {
    no = jsonRes['no'];
    total = jsonRes['total'];
    yes = jsonRes['yes'];
  }

  @override
  String toString() {
    return '{"no": $no,"total": $total,"yes": $yes}';
  }
}



class ReviewComment {
  Object replyAuthor;
  Object replyTo;
  int floor;
  int likeCount;
  String id;
  String content;
  String created;
  User author;

  ReviewComment.fromJson(jsonRes) {
    replyAuthor = jsonRes['replyAuthor'];
    replyTo = jsonRes['replyTo'];
    floor = jsonRes['floor'];
    likeCount = jsonRes['likeCount'];
    id = jsonRes['_id'];
    content = jsonRes['content'];
    created = jsonRes['created'];
    author = jsonRes['author'] == null ? null : new User.fromJson(jsonRes['author']);
  }

  static List<ReviewComment> getReviewComments(jsonRes){
    List<ReviewComment> list = [];
    for (var item in jsonRes ?? []){
      list.add(ReviewComment.fromJson(item));
    }
    return list;
  }
}


class User {
  int lv;
  String id;
  String activityAvatar;
  String avatar;
  String gender;
  String nickname;
  String type;

  User.fromJson(jsonRes) {
    lv = jsonRes['lv'];
    id = jsonRes['_id'];
    activityAvatar = jsonRes['activityAvatar'];
    avatar = jsonRes['avatar'];
    gender = jsonRes['gender'];
    nickname = jsonRes['nickname'];
    type = jsonRes['type'];
  }
}



class ReviewImageInfo{
  String type;
  String url;
  int width;
  int height;

  ReviewImageInfo.fromString(String str){
    List<String> list = str.split(",");
    Map<String,String> map = Map();
    list.forEach((s){
      List<String> l = s.split(":");
      map[l[0]] = l[1];
    });
    type = map["type"];
    url = map["url"];
    if(url != null && url.isNotEmpty){
      this.url = StringAmend.imgUriAmend(url);
    }
    String size = map["size"];
    if(size != null && size.isNotEmpty){
      List<String> s = size.split("-");
      width = int.parse(s[0]);
      height =  int.parse(s[1]);
    }
  }

  ReviewImageInfo.fromJson(jsonRes){
    type = jsonRes["type"];
    url = jsonRes["url"];
    if(url != null && url.isNotEmpty){
      this.url = StringAmend.imgUriAmend(url);
      print(url);
    }
    String size = jsonRes["size"];
    if(size != null && size.isNotEmpty){
      List<String> s = size.split("-");
      width = int.parse(s[0]);
      height =  int.parse(s[1]);
    }
  }
}
