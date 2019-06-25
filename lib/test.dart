import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Test(),
      ),
    );
  }
}

class MyApp2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("第二个"),
        ),
        body: Listener(
          child: Container(
            color: Colors.yellow,
          ),
          onPointerMove:(PointerMoveEvent event){
            print("滑动了====${event.delta.dx}======");
            if(event.delta.dx < -10){
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyApp()));
            }else if(event.delta.dx > 10){
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  bool tagsMenuOpen = false;
  PageController _pageController;
  bool start = true;
  bool end = false;
  @override
  void initState() {
    _pageController = PageController();

    _pageController.addListener((){
      end = _pageController.page == 4;
      start = _pageController.page == 0;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      child: PageView.builder(
        controller: _pageController,
        itemCount: 5,
        itemBuilder:(BuildContext context,int index)=>_rendRow(context, index),
        scrollDirection: Axis.horizontal,
      ),
      onPointerMove:(PointerMoveEvent event){
        print("滑动了====${event.delta.dx}======");
        if(end && event.delta.dx < -10){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MyApp2()));
        }else if(start && event.delta.dx > 10){
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget _rendRow(BuildContext context,int index){
    return Center(
      child: Container(
        color: Colors.red,
        child: Text("$index"),
      ),
    );
  }
}

