/*
* 可缺省的表格，带边框
*
* 注：Table构建的表格不可缺省cell
* */
import 'package:flutter/material.dart';

typedef BuildWidget<T> = Widget Function(T a);

class AutoTable<T> extends StatelessWidget {
  final List<T> list;
  final int colNum;
  final Color color;
  final BuildWidget builder;
  AutoTable(
      this.list,
      this.builder,
      { this.colNum = 3,
        this.color = Colors.grey,
      });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          top: BorderSide(color: color),
          start: BorderSide(color: color),
        ),
      ),
      child: Column(
        children: buildTableRowList(),
      ),
    );
  }

  List<Widget> buildTableRowList(){
    int length = list.length;
    if(length == 0) return [];
    int num = length%colNum == 0 ? length~/colNum : length~/colNum+1;
    return List.generate(num, (index){
      //最后一行
      if(index == num-1){
        int cellNum = length%colNum == 0 ? colNum : length%colNum;
        return buildTableRow(list, index*colNum , cellNum);
      }
      return buildTableRow(list, index*colNum , colNum);
    });
  }

  Widget buildTableRow(List<T> list,int startIndex, int cellNum) {
    return Row(
        children: List.generate(colNum, (index) {
          if(cellNum < colNum && index > cellNum-1){
            return Expanded(
              child: buildNull(),
            );
          }
          T typeNum = list[startIndex + index];
          return Expanded(
            child: buildCell(typeNum),
          );
        })
    );
  }

  Widget buildCell(T t){
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(color: color),
          end: BorderSide(color: color),
        ),
      ),
      child: builder(t),
    );
  }

  Widget buildNull(){
    return Container();
  }
}





