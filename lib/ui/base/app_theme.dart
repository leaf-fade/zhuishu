import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zhuishu/ui/base/app_scene.dart';
import 'package:zhuishu/ui/base/my_color.dart';
import 'package:zhuishu/util/event_bus.dart';
import 'package:zhuishu/util/sp.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/*
* 主题设置
* */
class AppTheme extends StatefulWidget {
  @override
  _AppThemeState createState() => _AppThemeState();
}

class _AppThemeState extends State<AppTheme> {
  int themeIndex;

  getDefaultTheme() async {
    SpHelper.getTheme().then((index){
      themeIndex = index ?? 0;
      setState(() {});
    });
  }

  @override
  void initState() {
    getDefaultTheme();
    eventBus.on<ThemeEvent>().listen((event){
      themeIndex = event.index ?? 0;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
      home: Stack(
        children: <Widget>[
          AppScene(),
          IgnorePointer(
            child: Container(
              color: themeIndex == 1 ? Color(0xAA000000) : Color(0x00000000),
            ),
          )
        ],
      ),
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
