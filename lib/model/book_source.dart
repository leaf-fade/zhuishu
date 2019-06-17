/*
* 书籍来源
* */
class BookSource {

  int chaptersCount;
  bool isCharge;
  bool starting;
  String id; /*资源通道 id*/
  String host;
  String lastChapter;
  String link;
  String name;
  String source;
  String updated;

  BookSource.fromJson(jsonRes) {
    chaptersCount = jsonRes['chaptersCount'];
    isCharge = jsonRes['isCharge'];
    starting = jsonRes['starting'];
    id = jsonRes['_id'];
    host = jsonRes['host'];
    lastChapter = jsonRes['lastChapter'];
    link = jsonRes['link'];
    name = jsonRes['name'];
    source = jsonRes['source'];
    updated = jsonRes['updated'];
  }
}


/*
* 来源章节列表信息
* */
class SourceChapters {

  String id;
  String book;
  String host;
  String link;
  String name;
  String source;
  String updated;
  List<Chapter> chapters;

  SourceChapters.fromJson(jsonRes) {
    id = jsonRes['_id'];
    book = jsonRes['book'];
    host = jsonRes['host'];
    link = jsonRes['link'];
    name = jsonRes['name'];
    source = jsonRes['source'];
    updated = jsonRes['updated'];
    chapters = jsonRes['chapters'] == null ? null : [];
    for (var chapter in chapters == null ? [] : jsonRes['chapters']){
      chapters.add(Chapter.fromJson(chapter));
    }
  }
}

/*
* 章节列表
* */
class Chapter {
  int currency;
  int order;
  int partsize;
  int time;
  int totalpage;
  bool isVip;
  bool unreadble;
  String chapterCover;
  String id;
  String link;
  String title;

  Chapter.fromJson(jsonRes) {
    currency = jsonRes['currency'];
    order = jsonRes['order'];
    partsize = jsonRes['partsize'];
    time = jsonRes['time'];
    totalpage = jsonRes['totalpage'];
    isVip = jsonRes['isVip'];
    unreadble = jsonRes['unreadble'];
    chapterCover = jsonRes['chapterCover'];
    id = jsonRes['id'];
    link = jsonRes['link'];
    title = jsonRes['title'];
  }
}


/*
* 章节信息，带具体文字内容
* */
class ChapterInfo{
  int chapterId ;
  int nextChapterId;
  int preChapterId;
  String bookName;
  String bookId;
  String link;
  String title;
  String content;
  List<String> pageInfo;
  int state = 0;

  ChapterInfo({this.chapterId,this.bookName,this.bookId ,this.link, this.title, this.content, this.state = 0}):
   this.nextChapterId =(chapterId??0) + 1, this.preChapterId = (chapterId??0)-1;

  int get pageCount => pageInfo.length;

}


