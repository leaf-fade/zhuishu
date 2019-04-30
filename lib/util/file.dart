import 'dart:io';

import 'package:path_provider/path_provider.dart';

class FileUtil{

  static Future<bool> createFile(String name,int index, String content) async{
    try{
      await getApplicationDocumentsDirectory().then((directory) async{
        //创建一个目录（创建的目录还有子目录时，create方法中的recursive要为true）
        Directory dir = Directory("${directory.path}/$name");
        bool isExist = await dir.exists();
        if(!isExist){
          dir = await dir.create();
        }
        var file = File("${dir.path}/$index.txt");
        file.writeAsString(content);
      });
      return true;
    }catch(error){
      print(error);
      return false;
    }
  }

  static Future<bool> removeAllFile(String name) async{
    try{
      await getApplicationDocumentsDirectory().then((directory) async{
        Directory dir = Directory("${directory.path}/$name");
        bool isExist = await dir.exists();
        if(!isExist) return;
        for(File file in dir.listSync()){
          file.delete();
        }
      });
      return true;
    }catch(error){
      print(error);
      return false;
    }
  }

  static Future<String> readFile(String name,int index) async{
    try{
      String str;
      //文件存在会覆盖写入
      await getApplicationDocumentsDirectory().then((directory) async{
        var file = File("${directory.path}/$name/$index.txt");
        str = await file.readAsString();
      });
      return str;
    }catch(error){
      return null;
    }
  }
}