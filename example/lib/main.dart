import 'package:flutter/material.dart';

import 'package:fast_mvvm/fast_mvvm.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

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
    await Future.delayed(Duration(seconds: 1));

    var entity = ArticleEntity([
      ArticleItem("1", "好的", "内容内容内容内容内容", DateTime.now().toString()),
      ArticleItem("1", "好的", "内容内容内容内容内容", DateTime.now().toString()),
    ]);

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
    initMVVM<BaseViewModel>(
      [UserModel()],
      controllerBuild: () => EasyRefreshController(),
      resetRefreshState: (c) =>
          (c as EasyRefreshController)?.resetRefreshState(),
      finishRefresh: (c, {bool success, bool noMore}) =>
          (c as EasyRefreshController)
              ?.finishRefresh(success: success, noMore: noMore),
      resetLoadState: (c) => (c as EasyRefreshController)?.resetLoadState(),
      finishLoad: (c, {bool success, bool noMore}) =>
          (c as EasyRefreshController)
              ?.finishLoad(success: success, noMore: noMore),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SelectPage(),
    );
  }
}

class SelectPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("选择")),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("根布局刷新"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ArticlePage(true)));
            },
          ),
          ListTile(
            title: Text("根布局不刷新"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ArticlePage(false)));
            },
          ),
        ],
      ),
    );
  }
}
