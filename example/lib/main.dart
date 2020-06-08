import 'package:flutter/material.dart';

import 'package:fast_mvvm/fast_mvvm.dart';

import 'article.dart';

void main() {
  runApp(App());
}

class UserModel extends BaseModel {
  Future<bool> login(String account, String psd) async {
    await Future.delayed(Duration(seconds: 3));
    return true;
  }

  Future<DataResponse<ArticleEntity>> getArticleList() async {
    await Future.delayed(Duration(seconds: 2));

    var entity = ArticleEntity(
        [ArticleItem("1", "好的", "内容内容内容内容内容", DateTime.now().toString())]);

    DataResponse dataResponse =
        DataResponse<ArticleEntity>(entity: entity, totalPageNum: 3);
    return dataResponse;
  }
}

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    initMVVM([UserModel()]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ArticlePage(),
    );
  }
}
