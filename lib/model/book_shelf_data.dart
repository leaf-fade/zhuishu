import 'dart:convert';

class BookData{
  String bookName;
  String bookId;
  String sourceId;
  int chapterId;
  String lastUpdate;
  String coverUrl;
  String lastChapterInfo;
  int lastReadDate = 0;
  bool isUpdate = false;
  bool isEnd;

  BookData({this.bookName, this.bookId, this.sourceId, this.chapterId,
      this.lastUpdate, this.coverUrl, this.lastChapterInfo, this.lastReadDate = 0});

  BookData.fromString(String str){
    var data = json.decode(str);
    bookName = data["bookName"];
    bookId = data["bookId"];
    sourceId = data["sourceId"];
    chapterId = data["chapterId"];
    lastUpdate = data["lastUpdate"];
    coverUrl = data["coverUrl"];
    lastChapterInfo = data["lastChapterInfo"];
    lastReadDate = data["lastReadDate"];
  }

  @override
  String toString() {
    return '{"bookName":${bookName != null?'${json.encode(bookName)}':'null'},"bookId":${bookId != null?'${json.encode(bookId)}':'null'},"sourceId":${sourceId != null?'${json.encode(sourceId)}':'null'},"chapterId":$chapterId,"lastUpate":${lastUpdate != null?'${json.encode(lastUpdate)}':'null'},'
        '"coverUrl":${coverUrl != null?'${json.encode(coverUrl)}':'null'},"lastChapterInfo":${lastChapterInfo != null?'${json.encode(lastChapterInfo)}':'null'},"lastReadDate":$lastReadDate}';
  }
}