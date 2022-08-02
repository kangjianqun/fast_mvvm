import 'package:fast_mvvm/fast_mvvm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';

import 'article.dart';

void main() {
  runApp(const App());
}

class UserModel extends BaseModel {
  Future<bool> login(String account, String psd) async {
    await Future.delayed(const Duration(seconds: 3));
    return true;
  }

  Future<DataResponse<ArticleEntity>> getArticleList() async {
    await Future.delayed(const Duration(seconds: 1));

    var entity = ArticleEntity([
      ArticleItem("1", "好的", "内容内容内容内容内容", DateTime.now().toString()),
      ArticleItem("1", "好的", "内容内容内容内容内容", DateTime.now().toString()),
    ]);

    DataResponse<ArticleEntity> dataResponse =
        DataResponse<ArticleEntity>(entity: entity, totalPageNum: 3);
    return dataResponse;
  }
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    initMVVM<BaseViewModel>(
      [UserModel()],
      controllerBuild: () => EasyRefreshController(),
      resetRefreshState: (c) =>
          (c as EasyRefreshController).resetRefreshState(),
      finishRefresh: (c, {required bool success, required bool noMore}) =>
          (c as EasyRefreshController)
              .finishRefresh(success: success, noMore: noMore),
      resetLoadState: (c) => (c as EasyRefreshController).resetLoadState(),
      finishLoad: (c, {required bool success, required bool noMore}) =>
          (c as EasyRefreshController)
              .finishLoad(success: success, noMore: noMore),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SelectPage(),
    );
  }
}

class SelectVM extends BaseViewModel {
  ValueNotifier<bool> isLoadData = ValueNotifier(true);
  ValueNotifier<bool> isConfigState = ValueNotifier(false);
}

class SelectPage extends StatelessWidget with BaseView<SelectVM> {
  const SelectPage({Key? key}) : super(key: key);

  @override
  ViewConfig<SelectVM> initConfig() => ViewConfig.noLoad(SelectVM());

  @override
  Widget vBuild(context, SelectVM vm, Widget? child, Widget? state) {
    return Scaffold(
      appBar: AppBar(title: const Text("选择")),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text("是否加载数据,用来测试状态页和重新加载数据"),
            trailing: ValueListenableBuilder<bool>(
              valueListenable: vm.isLoadData,
              builder: (_, value, __) => Switch(
                value: value,
                onChanged: (value) => vm.isLoadData.value = value,
              ),
            ),
          ),
          ListTile(
            title: const Text("是否单独配置状态页,用来测试状态页和重新加载数据"),
            trailing: ValueListenableBuilder<bool>(
              valueListenable: vm.isConfigState,
              builder: (_, value, __) => Switch(
                value: value,
                onChanged: (value) => vm.isConfigState.value = value,
              ),
            ),
          ),
          ListTile(
            title: const Text("根布局刷新"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticlePage(
                    true,
                    configState: vm.isConfigState.value,
                    loadData: vm.isLoadData.value,
                  ),
                ),
              );
            },
          ),
          ListTile(
            title: const Text("根布局不刷新"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ArticlePage(
                    false,
                    configState: vm.isConfigState.value,
                    loadData: vm.isLoadData.value,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
