// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// RouteWriterGenerator
// **************************************************************************

import 'dart:convert';
import 'package:annotation_route/route.dart';
import 'package:zhuishu/ui/main/discovery/book_categories_page.dart';
import 'package:zhuishu/ui/main/discovery/book_comment_page.dart';
import 'package:zhuishu/ui/main/discovery/books_list_detail_page.dart';
import 'package:zhuishu/ui/main/discovery/books_list_page.dart';
import 'package:zhuishu/ui/main/discovery/book_categories_info_page.dart';
import 'package:zhuishu/ui/main/discovery/book_comment_detail_page.dart';
import 'package:zhuishu/ui/main/discovery/book_info_page.dart';
import 'package:zhuishu/ui/main/discovery/rank_page.dart';
import 'package:zhuishu/ui/main/shelf/author_books_page.dart';
import 'package:zhuishu/ui/main/shelf/collect_books_page.dart';
import 'package:zhuishu/ui/main/shelf/search_page.dart';
import 'package:zhuishu/ui/reader/reader_scene.dart';

class ARouterInternalImpl extends ARouterInternal {
  ARouterInternalImpl();
  final Map<String, List<Map<String, dynamic>>> innerRouterMap =
      <String, List<Map<String, dynamic>>>{
    'page://book_categories_page': [
      {'clazz': CategoriesPage}
    ],
    'page://books_comment_page': [
      {'clazz': BookCommentPage}
    ],
    'page://books_list_detail_page': [
      {'clazz': BooksListDetailPage}
    ],
    'page://books_list_page': [
      {'clazz': BooksListPage}
    ],
    'page://book_categories_info_page': [
      {'clazz': CategoriesInfoPage}
    ],
    'page://books_comment_detail_page': [
      {'clazz': BookCommentDetailPage}
    ],
    'page://book_info_page': [
      {'clazz': BookInfoPage}
    ],
    'page://rank_page': [
      {'clazz': RankPage}
    ],
    'page://author_books_page': [
      {'clazz': BookListPage}
    ],
    'page://books_list_collect_page': [
      {'clazz': BooksListCollectPage}
    ],
    'page://search_page': [
      {'clazz': SearchPage}
    ],
    'page://reader_scene': [
      {'clazz': ReaderScene}
    ]
  };

  @override
  bool hasPageConfig(ARouteOption option) {
    final dynamic pageConfig = findPageConfig(option);
    return pageConfig != null;
  }

  @override
  ARouterResult findPage(ARouteOption option, dynamic initOption) {
    final dynamic pageConfig = findPageConfig(option);
    if (pageConfig != null) {
      return implFromPageConfig(pageConfig, initOption);
    } else {
      return ARouterResult(state: ARouterResultState.NOT_FOUND);
    }
  }

  void instanceCreated(
      dynamic clazzInstance, Map<String, dynamic> pageConfig) {}

  dynamic instanceFromClazz(Type clazz, dynamic option) {
    switch (clazz) {
      case CategoriesPage:
        return new CategoriesPage(option);
      case BookCommentPage:
        return new BookCommentPage(option);
      case BooksListDetailPage:
        return new BooksListDetailPage(option);
      case BooksListPage:
        return new BooksListPage(option);
      case CategoriesInfoPage:
        return new CategoriesInfoPage(option);
      case BookCommentDetailPage:
        return new BookCommentDetailPage(option);
      case BookInfoPage:
        return new BookInfoPage(option);
      case RankPage:
        return new RankPage(option);
      case BookListPage:
        return new BookListPage(option);
      case BooksListCollectPage:
        return new BooksListCollectPage(option);
      case SearchPage:
        return new SearchPage(option);
      case ReaderScene:
        return new ReaderScene(option);
      default:
        return null;
    }
  }

  ARouterResult implFromPageConfig(
      Map<String, dynamic> pageConfig, dynamic option) {
    final String interceptor = pageConfig['interceptor'];
    if (interceptor != null) {
      return ARouterResult(
          state: ARouterResultState.REDIRECT, interceptor: interceptor);
    }
    final Type clazz = pageConfig['clazz'];
    if (clazz == null) {
      return ARouterResult(state: ARouterResultState.NOT_FOUND);
    }
    try {
      final dynamic clazzInstance = instanceFromClazz(clazz, option);
      instanceCreated(clazzInstance, pageConfig);
      return ARouterResult(
          widget: clazzInstance, state: ARouterResultState.FOUND);
    } catch (e) {
      return ARouterResult(state: ARouterResultState.NOT_FOUND);
    }
  }

  dynamic findPageConfig(ARouteOption option) {
    final List<Map<String, dynamic>> pageConfigList =
        innerRouterMap[option.urlpattern];
    if (null != pageConfigList) {
      for (int i = 0; i < pageConfigList.length; i++) {
        final Map<String, dynamic> pageConfig = pageConfigList[i];
        final String paramsString = pageConfig['params'];
        if (null != paramsString) {
          Map<String, dynamic> params;
          try {
            params = json.decode(paramsString);
          } catch (e) {
            print('not found A{pageConfig};');
          }
          if (null != params) {
            bool match = true;
            final Function matchParams = (String k, dynamic v) {
              if (params[k] != option?.params[k]) {
                match = false;
                print('not match:A{params[k]}:A{option?.params[k]}');
              }
            };
            params.forEach(matchParams);
            if (match) {
              return pageConfig;
            }
          } else {
            print('ERROR: in parsing paramsA{pageConfig}');
          }
        } else {
          return pageConfig;
        }
      }
    }
    return null;
  }
}
