import 'package:event_bus/event_bus.dart';

EventBus eventBus = EventBus();

/*
* 加入书架事件
* */
class AddShelfEvent{
  bool isAdd;

  AddShelfEvent(this.isAdd);
}

/*
* 主题
* */
class ThemeEvent{
  int index;

  ThemeEvent(this.index);
}


/*
* 下载进度
* */
class DownloadEvent{
  int downloadCount;
  int totalCount;

  DownloadEvent(this.downloadCount, this.totalCount);

}