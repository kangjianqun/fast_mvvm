# fast_mvvm

博客讲解：https://blog.csdn.net/q948182974/article/details/106613565

掘金讲解：https://juejin.im/post/5ee86c9b51882543313a0de7

一个MVVM框架附带简单的demo,会一直更新，希望支持一下.有问题可以反馈QQ 275918180。

## Demo 讲解
这里模拟了文章列表。
Model：<kbd>UserModel</kbd>
BaseListViewModel： <kbd>ArticleVM</kbd>
View：<kbd>ArticlePage</kbd>
数据实体类 BaseEntity：<kbd>ArticleEntity</kbd>
主要讲解了初始化配置， 状态页效果，根布局刷新，数据获取。

### UserModel
首先创建项目模块所需要用的<kbd>Model</kbd>，按大模块区分。
这里创建<kbd>UserModel</kbd>。
```
class UserModel extends BaseModel {
  /// 登录
  Future<bool> login(String account, String psd) async {
    await Future.delayed(Duration(seconds: 3));
    return true;
  }

  /// 资讯列表
  Future<DataResponse<ArticleEntity>> getArticleList() async {
    await Future.delayed(Duration(seconds: 2));

    var entity = ArticleEntity([
      ArticleItem("1", "好的", "内容内容内容内容内容", DateTime.now().toString()),
      ArticleItem("1", "好的", "内容内容内容内容内容", DateTime.now().toString()),
    ]);

    DataResponse dataResponse =
        DataResponse<ArticleEntity>(entity: entity, totalPageNum: 3);
    return dataResponse;
  }
}
```
### 初始化
在APP首页启动的时候初始化框架。
调用initMVVM(),装载UserModel，配置上拉加载下拉刷新;
选择文章页面是否根布局刷新选项,是否配置单独的状态页。
```

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

class SelectVM extends BaseViewModel {
  ValueNotifier<bool> isLoadData = ValueNotifier(true);
  ValueNotifier<bool> isConfigState = ValueNotifier(false);
}

class SelectPage extends StatelessWidget with BaseView<SelectVM> {
  @override
  ViewConfig<SelectVM> initConfig(BuildContext context) =>
      ViewConfig(vm: SelectVM());

  @override
  Widget vmBuild(
      BuildContext context, SelectVM vm, Widget child, Widget state) {
    return Scaffold(
      appBar: AppBar(title: Text("选择")),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("是否加载数据,用来测试状态页和重新加载数据"),
            trailing: ValueListenableBuilder(
              valueListenable: vm.isLoadData,
              builder: (_, value, __) => Switch(
                value: value,
                onChanged: (value) => vm.isLoadData.value = value,
              ),
            ),
          ),
          ListTile(
            title: Text("是否单独配置状态页,用来测试状态页和重新加载数据"),
            trailing: ValueListenableBuilder(
              valueListenable: vm.isConfigState,
              builder: (_, value, __) => Switch(
                value: value,
                onChanged: (value) => vm.isConfigState.value = value,
              ),
            ),
          ),
          ListTile(
            title: Text("根布局刷新"),
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
            title: Text("根布局不刷新"),
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
```
### ArticleEntity
模拟接口返回的数据实体类：
```
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
```

### ArticleVM
UserModel 继承  BaseModel，ArticleEntity继承BaseEntity，ArticleItem 暂没要求。
是否首次加载数据测试空状态页的效果
创建<kbd>vnTime</kbd> 用来监听<kbd>List</kbd>第一个<kbd>ArticleItem</kbd>的时间刷新
```

class ArticleVM
    extends BaseListViewModel<UserModel, ArticleEntity, ArticleItem> {
  ArticleVM(this.isLoadData);
  bool isLoadData = true;

  /// 首次加载
  bool firstLoad = true;
  ValueNotifier<String> vnTime = ValueNotifier("暂无");

  @override
  void jointList(ArticleEntity newEntity) => entity.list.addAll(newEntity.list);

  @override
  List<ArticleItem> get list => entity.list;
  @override
  Future<DataResponse<ArticleEntity>> requestHttp(
      {bool isLoad, int page, params}) {
    /// 判断是否加载数据， 测试状态页用
    if (!isLoadData && firstLoad) {
      firstLoad = false;
      return null;
    }
    return model.getArticleList();
  }

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
```
### ArticlePage View
文章具体页面，显示一个列表，下方显示第一个item对应的时间，和根布局刷新的时间。

```
class ArticlePage extends StatelessWidget with BaseView<ArticleVM> {
  const ArticlePage(
    this.rootRefresh, {
    Key key,
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
```
### 数据刷新
通过<kbd>ValueListenableBuilder</kbd> 监听在<kbd>ArticleVM</kbd>创建的<kbd>ValueNotifier</kbd> 对象，实现局部刷新。
通过<kbd>Selector</kbd> 监听<kbd>ArticleEntity</kbd>中<kbd>List</kbd> 的 <kbd>ArticleItem</kbd> 的变化
```
ValueListenableBuilder<String>(
                  valueListenable: vm.vnTime,
                  builder: (_, value, __) {
                    return Text("第一个Item时间：$value");
                  },
                )
Selector<ArticleVM, ArticleItem>(
                  selector: (_, aVM) => aVM.list[index],
                  shouldRebuild: (pre, next) => pre == next,
                  builder: (_, ArticleItem value, __) => _item(value),
                )
```


## 更多帮助
博客讲解：https://blog.csdn.net/q948182974/article/details/106613565

掘金讲解：https://juejin.im/post/5ee86c9b51882543313a0de7

一个MVVM框架附带简单的demo,会一直更新，希望支持一下.有问题可以反馈QQ 275918180。

<center>谢谢支持，请作者喝咖啡。 </center>
<table>
    <tr>
        <td >
        <center>
        <img src="https://img-blog.csdnimg.cn/2020062212024598.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3E5NDgxODI5NzQ=,size_16,color_FFFFFF,t_70" >
        </center>
        </td>
        <td >
        <center>
        <img src="https://img-blog.csdnimg.cn/20200622121147113.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3E5NDgxODI5NzQ=,size_16,color_FFFFFF,t_70"  >
        </center>
        </td>
    </tr>
</table>