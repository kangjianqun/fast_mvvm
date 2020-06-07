import 'package:fast_mvvm/fast_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

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

  @override
  void jointList(ArticleEntity newEntity) => entity.list.addAll(newEntity.list);

  @override
  List<ArticleItem> get list => entity.list;

  @override
  Future<DataResponse<ArticleEntity>> request({bool isLoad, int page, params}) {
    return model.getArticleList();
  }
}

class ArticlePage extends StatelessWidget with BaseView<ArticleVM> {
  @override
  ViewConfig<ArticleVM> initConfig(BuildContext context) =>
      ViewConfig(vm: ArticleVM());

  @override
  Widget vmBuild(
      BuildContext context, ArticleVM vm, Widget child, Widget state) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text("文章")),
      body: state ??
          EasyRefresh(
            controller: vm.refreshController,
            onLoad: vm.loadMore,
            onRefresh: vm.viewRefresh,
            child: ListView.builder(
                itemCount: vm.list.length,
                itemBuilder: (ctx, index) => _item(vm.list[index])),
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
