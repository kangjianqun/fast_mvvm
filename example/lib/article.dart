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
  ArticleVM(this.isLoadData);
  bool isLoadData = true;

  /// 首次加载
  bool firstLoad = true;
  ValueNotifier<String> vnTime = ValueNotifier("暂无");

  @override
  void jointList(ArticleEntity newEntity) =>
      entity?.list.addAll(newEntity.list);

  @override
  List<ArticleItem>? get list => entity?.list;

  @override
  Future<DataResponse<ArticleEntity>?>? requestHttp(bool isLoad, int page,
      {params}) {
    /// 判断是否加载数据， 测试状态页用
    if (!isLoadData && firstLoad) {
      firstLoad = false;
      return null;
    }
    return model.getArticleList();
  }

  @override
  void initResultData() {
    vnTime.value = list![0].time;
  }

  /// 修改第一个数据的时间
  void modifyFistTime() {
    list![0].time = DateTime.now().toString();
    vnTime.value = list![0].time;
    notifyListeners();
  }
}

class ArticlePage extends StatelessWidget with BaseView<ArticleVM> {
  ArticlePage(
    this.rootRefresh, {
    Key? key,
    this.configState = false,
    this.loadData = true,
  }) : super(key: key);

  /// 是否全局刷新
  final bool rootRefresh;
  final bool configState;
  final bool loadData;

  @override
  ViewConfig<ArticleVM> initConfig(BuildContext context) {
    var _empty = configState ? (vm) => Center(child: Text("单独配置：empty")) : null;
    return rootRefresh
        ? ViewConfig<ArticleVM>(vm: ArticleVM(loadData), empty: _empty)
        : ViewConfig<ArticleVM>.noRoot(vm: ArticleVM(loadData), empty: _empty);
  }

  @override
  Widget vmBuild(context, ArticleVM vm, Widget? child, Widget? state) {
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
                    child: Text("修改第一个Item时间,测试全局刷新"),
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
      body: Column(
        children: <Widget>[
          Container(
            height: 100,
            color: Colors.red,
            alignment: Alignment.center,
            child: Text("假装这是广告，用来测试ListOrGridEmpty"),
          ),
          ListOrGridEmpty.max(
            vm: vm,
            useViewSizeType: true,
            childBuild: () => EasyRefresh(
              controller: vm.refreshController,
              onLoad: vm.loadMore,
              onRefresh: vm.pullRefresh,
              child: ListView.builder(
                itemCount: vm.list!.length,
                itemBuilder: (ctx, index) {
                  return Selector<ArticleVM, ArticleItem>(
                    selector: (_, aVM) => aVM.list![index],
                    shouldRebuild: (pre, next) => pre == next,
                    builder: (_, ArticleItem value, __) => _item(value),
                  );
                },
              ),
            ),
          ),
        ],
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

// 测试 The class doesn't have a concrete implementation of the super-invoked member 'build'.
//class AAA extends StatefulWidget {
//  @override
//  _AAAState createState() => _AAAState();
//}
//
//class _AAAState extends State<AAA> with BaseViewOfState<AAA, SelectVM> {
//  @override
//  ViewConfig<SelectVM> initConfig(BuildContext context) {
//    // TODO: implement initConfig
//    throw UnimplementedError();
//  }
//
//  @override
//  Widget vmBuild(
//      BuildContext context, SelectVM vm, Widget child, Widget state) {
//    // TODO: implement vmBuild
//    throw UnimplementedError();
//  }
//}
