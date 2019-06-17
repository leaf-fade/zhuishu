class CategoriesInfo {

  int total;
  List<BookIntro> books;

  CategoriesInfo.fromJson(jsonRes) {
    total = jsonRes['total'];
    books = [];

    for (var booksItem in jsonRes['books']??[]){
      books.add(BookIntro.fromJson(booksItem));
    }
  }
}

class BookIntroList {

  List<BookIntro> books;

  BookIntroList.fromJson(jsonRes) {
    books = jsonRes['books'] == null ? null : [];

    for (var booksItem in books == null ? [] : jsonRes['books']){
      books.add(booksItem == null ? null : BookIntro.fromJson(booksItem));
    }
  }
}

class BookIntro {

  int latelyFollower;
  bool allowMonthly;
  String id;
  String author;
  String contentType;
  String cover;
  String lastChapter;
  String cat;
  String majorCate;
  String minorCate;
  String shortIntro;
  String site;
  String superscript;
  String title;
  List<String> tags;

  BookIntro.fromParams({this.latelyFollower,this.allowMonthly, this.id, this.author, this.contentType, this.cover, this.lastChapter, this.majorCate, this.minorCate, this.shortIntro, this.site, this.superscript, this.title, this.tags});

  BookIntro.fromJson(jsonRes) {
    latelyFollower = jsonRes['latelyFollower'];
    allowMonthly = jsonRes['allowMonthly'];
    id = jsonRes['_id'];
    author = jsonRes['author'];
    contentType = jsonRes['contentType'];
    cover = jsonRes['cover'];
    lastChapter = jsonRes['lastChapter'];
    majorCate = jsonRes['majorCate'];
    minorCate = jsonRes['minorCate'];
    cat = jsonRes['cat'];
    shortIntro = jsonRes['shortIntro'];
    site = jsonRes['site'];
    superscript = jsonRes['superscript'];
    title = jsonRes['title'];
    tags = jsonRes['tags'] == null ? null : [];

    for (var tagsItem in tags == null ? [] : jsonRes['tags']){
      tags.add(tagsItem);
    }
  }

  static List<BookIntro> getBooksList(data){
    List<BookIntro> list = [];
    for(var info in data??[]){
      list.add(BookIntro.fromJson(info));
    }
    return list;
  }
}

class CatsTag{
  String major;
  List<String> mins;

  CatsTag.fromJson(jsonRes) {
    major = jsonRes['major'];
    mins = jsonRes['mins'] == null ? null : [];

    for (var minsItem in mins == null ? [] : jsonRes['mins']){
      mins.add(minsItem);
    }
  }

  static List<CatsTag> getCatsTags(data){
    List<CatsTag> list = [];
    for(var info in data??[]){
      list.add(CatsTag.fromJson(info));
    }
    return list;
  }
}



