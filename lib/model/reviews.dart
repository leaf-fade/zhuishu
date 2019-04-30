/*
* 书评
* */

class ShortReviews {
  bool ok;
  List<Review> reviews;

  ShortReviews.fromJson(jsonRes) {
    ok = jsonRes['ok'];
    reviews = jsonRes['docs'] == null ? null : [];

    for (var reviewsItem in reviews == null ? [] : jsonRes['docs']){
      reviews.add(reviewsItem == null ? null : Review.fromJson(reviewsItem));
    }
  }
}

class Reviews {
  bool ok;
  List<Review> reviews;

  Reviews.fromJson(jsonRes) {
    ok = jsonRes['ok'];
    reviews = jsonRes['reviews'] == null ? null : [];

    for (var reviewsItem in reviews == null ? [] : jsonRes['reviews']){
      reviews.add(reviewsItem == null ? null : Review.fromJson(reviewsItem));
    }
  }
}

//长评
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

