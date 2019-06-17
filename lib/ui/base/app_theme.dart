import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:screen/screen.dart';
import 'package:zhuishu/ui/base/app_scene.dart';
import 'package:zhuishu/ui/base/my_color.dart';
import 'package:zhuishu/util/event_bus.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/*
* 主题设置
* */
class AppTheme extends StatelessWidget {

  getDefaultTheme() async {
    SpHelper.getTheme().then((index){
      int themeIndex = index ?? 0;
      Screen.setBrightness(themeIndex== 1? 0.1: 0.5);
    });
  }

  @override
  Widget build(BuildContext context) {
    getDefaultTheme();
    eventBus.on<ThemeEvent>().listen((event){
      int themeIndex = event.index ?? 0;
      Screen.setBrightness(themeIndex== 1? 0.1: 0.5);
    });
    return MaterialApp(
      title: '追书',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: MyColor.primary,
        dividerColor: MyColor.divider,
        scaffoldBackgroundColor: MyColor.paper,
        textTheme: TextTheme(body1: TextStyle(color: Colors.white)),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FallbackCupertinoLocalisationsDelegate(),
      ],
      locale: Locale('zh'),
      supportedLocales: [
        const Locale('zh','CH'),
        const Locale('en','US'),
      ],
      home: AppScene(),
    );
  }
}



class FallbackCupertinoLocalisationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalisationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      DefaultCupertinoLocalizations.load(locale);

  @override
  bool shouldReload(FallbackCupertinoLocalisationsDelegate old) => false;
}
