import 'package:fast_mvvm/fast_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class ArticleEntity extends BaseEntity {
  List<ArticleItem> list;

  ArticleEntity(this.list);
}

class ArticleItem {
  String id;
  String title;
  String content;
  String time;

  ArticleItem(this.id, this.title, this.content, this.time);
}

class ArticleVM
    extends BaseListViewModel<UserModel, ArticleEntity, ArticleItem> {
  ValueNotifier<String> vnTime = ValueNotifier("暂无");

  @override
  void jointList(ArticleEntity newEntity) => entity.list.addAll(newEntity.list);

  @override
  List<ArticleItem> get list => entity.list;

//  @override
//  Future<DataResponse<ArticleEntity>> requestHttp(
//      {bool isLoad, int page, params}) {
//    return model.getArticleList();
//  }

  @override
  void initResultData() {
    vnTime.value = list[0].time;
  }

  /// 修改第一个数据的时间
  void modifyFistTime() {
    list[0].time = DateTime.now().toString();
    vnTime.value = list[0].time;
    notifyListeners();
  }
}

class ArticlePage extends StatelessWidget with BaseView<ArticleVM> {
  const ArticlePage(this.rootRefresh, {Key key}) : super(key: key);

  /// 是否全局刷新
  final bool rootRefresh;

  @override
  ViewConfig<ArticleVM> initConfig(BuildContext context) {
    return rootRefresh
        ? ViewConfig<ArticleVM>(
            vm: ArticleVM(),
            empty: (vm) => Text("data"),
          )
        : ViewConfig<ArticleVM>.noRoot(
            vm: ArticleVM(),
            empty: (vm) => Text("data"),
          );
  }

  @override
  Widget vmBuild(
      BuildContext context, ArticleVM vm, Widget child, Widget state) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("文章")),
      bottomNavigationBar: state != null
          ? SizedBox()
          : Container(
              color: Colors.amber,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  MaterialButton(
                    onPressed: vm.modifyFistTime,
                    color: Colors.white,
                    child: Text("修改第一个Item时间"),
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: vm.vnTime,
                    builder: (_, value, __) {
                      return Text("第一个Item时间：$value");
                    },
                  ),
                  Text("根布局刷新时间：${DateTime.now().toString()}"),
                ],
              ),
            ),
      body: state ??
          EasyRefresh(
            controller: vm.refreshController,
            onLoad: vm.loadMore,
            onRefresh: vm.pullRefresh,
            child: ListView.builder(
              itemCount: vm.list.length,
              itemBuilder: (ctx, index) {
                return Selector<ArticleVM, ArticleItem>(
                  selector: (_, aVM) => aVM.list[index],
                  shouldRebuild: (pre, next) => pre == next,
                  builder: (_, ArticleItem value, __) => _item(value),
                );
              },
            ),
          ),
    );
  }

  Widget _item(ArticleItem item) {
    return Container(
      color: Colors.lightGreen,
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(4),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(item.title),
              Text(item.time),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(item.content),
          ),
        ],
      ),
    );
  }
}
