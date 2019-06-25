## 效果图
![主页](https://upload-images.jianshu.io/upload_images/5999599-20bc9ee89dbe97b2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![阅读](https://upload-images.jianshu.io/upload_images/5999599-56fb89234df796a3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![搜索](https://upload-images.jianshu.io/upload_images/5999599-475d810fc76fe3bd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![讨论](https://upload-images.jianshu.io/upload_images/5999599-4ff286f34289afed.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


实现了书架、书单、排行榜、分类，阅读、换源、搜索、历史、夜间模式等功能

1. 路由使用了咸鱼的ARoute框架
2. 图标新建了一个自己的图标库（图标都来源自iconfont）
3. 对网络状况、系统电量、系统亮度做了处理

**不足：**

1. 未有状态管理（个人偏向于 bloc+rxdart，毕竟是小项目, 界面和逻辑分离总是好的）
2. 并未实现全部功能，后续功能应该也不会再添加了
3. 有些做的不够严谨，并未单独抽出来放在一个常量文件中（比如颜色、文字等）
4. 优化卡顿



