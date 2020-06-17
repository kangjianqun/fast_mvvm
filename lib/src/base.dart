import 'dart:async';

import 'package:dio/dio.dart';
import 'package:fast_event_bus/fast_event_bus.dart';
import 'package:fast_mvvm/fast_mvvm.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'common.dart';
import 'widget.dart';

// 基于MVVM架构设计
// Model 数据业务接口 数据来源服务器或本地。
// ViewModel 给view提供数据 调用model
// View 视图页面

typedef VMBuilder<T extends BaseViewModel> = Widget Function(
    BuildContext context, T viewModel, Widget child, Widget state);

typedef VSBuilder<T extends BaseViewModel> = Widget Function(T vm);

typedef ResetRefreshState = void Function(dynamic controller);
typedef FinishRefresh = void Function(dynamic controller,
    {bool success, bool noMore});
typedef ResetLoadState = void Function(dynamic controller);
typedef FinishLoad = void Function(dynamic controller,
    {bool success, bool noMore});
typedef ControllerBuild = dynamic Function();

/// 初始化 配置初始页面全局状态页
void initMVVM<VM extends BaseViewModel>(
  List<BaseModel> models, {
  int initPage = 1,
  VSBuilder<VM> busy,
  VSBuilder<VM> empty,
  VSBuilder<VM> error,
  VSBuilder<VM> unAuthorized,
  ResetRefreshState resetRefreshState,
  FinishRefresh finishRefresh,
  ResetLoadState resetLoadState,
  FinishLoad finishLoad,
  ControllerBuild controllerBuild,
}) {
  assert(initPage != null);

  /// 载入model 后期调用API
  addModel(list: models);
  BaseListViewModel.pageFirst = initPage;
  _Config.gBusy = busy;
  _Config.gEmpty = empty;
  _Config.gError = error;
  _Config.gunAuthorized = unAuthorized;
  if (resetRefreshState != null)
    BaseListViewModel._resetRefreshState = resetRefreshState;
  if (finishRefresh != null) BaseListViewModel._finishRefresh = finishRefresh;
  if (resetLoadState != null)
    BaseListViewModel._resetLoadState = resetLoadState;
  if (finishLoad != null) BaseListViewModel._finishLoad = finishLoad;
  if (controllerBuild != null)
    BaseListViewModel._controllerBuild = controllerBuild;
}

/// 基类的API 声明API
mixin BaseRepo {}

/// 基类Model  具体实现API
class BaseModel with BaseRepo {}

/// 基类Entity JSON数据实体
class BaseEntity {}

/// ViewModel的状态 控制页面基础显示
enum ViewModelState { idle, busy, empty, error, unAuthorized }

/// 基类 VM
abstract class BaseViewModel<M extends BaseModel, E extends BaseEntity>
    extends ChangeNotifier {
  /// 根据状态构造
  /// 子类可以在构造函数指定需要的页面状态
  /// FooModel():super(viewState:ViewState.busy);
  BaseViewModel({ViewModelState viewState, this.defaultOfParams})
      : _viewState = viewState ?? ViewModelState.idle {
    init(false);
    Future.delayed(Duration(seconds: 1), () => init(true));
  }

  /// model
  M model;

  M getModel() => null;

  /// 实体类
  E entity;

  /// 默认参数
  var defaultOfParams;

  /// 主动全局刷新 用在首次跟下拉刷新和上拉加载
  bool _activeGlobalRefresh = true;

  /// 防止页面销毁后,异步任务才完成,导致报错
  bool _disposed = false;
  bool _notifyIntercept = false;
  BuildContext context;

  /// 当前的页面状态,默认为busy,可在viewModel的构造方法中指定;
  ViewModelState _viewState;

  ViewModelState get viewState => _viewState;

  /// 出错时的message
  String _errorMessage;

  String get errorMessage => _errorMessage;

  /// 以下变量是为了代码书写方便,加入的变量.严格意义上讲,并不严谨
  bool get busy => viewState == ViewModelState.busy;

  bool get idle => viewState == ViewModelState.idle;

  bool get empty => viewState == ViewModelState.empty;

  bool get error => viewState == ViewModelState.error;

  bool get unAuthorized => viewState == ViewModelState.unAuthorized;

  void setBusy(bool value) {
    _errorMessage = null;
    viewState = value ? ViewModelState.busy : ViewModelState.idle;
  }

  void setEmpty() {
    _errorMessage = null;
    viewState = ViewModelState.empty;
  }

  void setError(String message) {
    _errorMessage = message;
    viewState = ViewModelState.error;
  }

  void setUnAuthorized() {
    _errorMessage = null;
    viewState = ViewModelState.unAuthorized;
  }

  set viewState(ViewModelState viewState) {
    _viewState = viewState;
    notifyListeners();
  }

  /// 端口 key 跟 回调监听
  Map<String, EventListen> get portMap => Map<String, EventListen>();

  /// 绑定端口跟回调
  void _eventButBindListen(String key, EventListen listen) {
    EventBus.getDefault().register(key, listen);
  }

  /// 绑定初始化 大量绑定
  void _eventButAddInit(Map<String, EventListen> portMap) {
    portMap?.forEach((key, callback) {
      _eventButBindListen(key, callback);
    });
  }

  /// 端口删除
  void eventButDelete(String key) {
    EventBus.getDefault().unregister(key);
  }

  /// 端口添加
  @mustCallSuper
  bool eventButAdd(String key, EventListen listen) {
    portMap.update(key, (l) => listen, ifAbsent: () => listen);
    return EventBus.getDefault().register(key, listen);
  }

  List _disposeWait = [];

  void _disposeInit() {
    for (var item in waitDispose()) _disposeAdd(item);
  }

  void _disposeAdd(item) {
    if (item.dispose != null) _disposeWait.add(item);
  }

  /// 清理内存占用
  void _disposeList() {
    for (var item in _disposeWait)
      if (item != null) {
        try {
          if (item is StreamSubscription) {
            item.cancel();
          } else {
            item.dispose();
          }
        } catch (e, s) {
          handleCatch(e, s);
        } finally {
          item = null;
        }
      }
  }

  @override
  void dispose() {
    _disposed = true;
    for (var key in portMap.keys) {
      eventButDelete(key);
    }
    _disposeList();
    super.dispose();
  }

  @mustCallSuper
  void init(bool await) {
    if (!await) {
      model = getModel() ?? getModelGlobal<M>();
//      if (isSaveVM()) _addVM(this);
    } else {
      _eventButAddInit(portMap);
      _disposeInit();
    }
  }

  /// 保存VM
  bool isSaveVM() => false;

  List waitDispose() => [];

  bool isHttp() => true;

  /// 进入页面isInit loading
  Future<void> viewRefresh({
    dynamic params,
    bool notifier = true,
    bool busy = true,
  }) async {
    if (busy) setBusy(true);
    bool result = false;
    result = await _request(param: params);
    _notifyIntercept = !notifier;
//    LogUtil.printLog("notifier : $notifier _notifyIntercept:$_notifyIntercept");
    if (!result) {
      setEmpty();
    } else {
      ///改变页面状态为非加载中
      setBusy(false);
    }
  }

  /// 请求数据
  Future<bool> _request({param}) async {
    try {
      var data = await _httpOrData(false, BaseListViewModel.pageFirst, param);
      if (data == null || data.entity == null) {
        return false;
      } else {
        entity = data.entity;
        initResultData();
        return true;
      }
    } catch (e, s) {
      handleCatch(e, s);
      return false;
    }
  }

  /// 判断http或者data
  Future<DataResponse<E>> _httpOrData(bool isLoad, int page, param) async {
    return isHttp()
        ? await requestHttp(
            isLoad: isLoad, page: page, params: param ?? defaultOfParams)
        : await requestData(isLoad, page);
  }

  /// 非http请求
  Future<DataResponse<E>> requestData(bool isLoad, int page) async => null;

  /// http请求
  Future<DataResponse<E>> requestHttp(
          {@required bool isLoad, int page, params}) async =>
      null;

  /// 初始化返回数据
  @protected
  void initResultData() {}

  @override
  String toString() {
    return 'BaseModel{_viewState: $viewState, _errorMessage: $_errorMessage}';
  }

  @override
  void notifyListeners() {
    if (!_disposed) {
//      LogUtil.printLog("_notifyIntercept: $_notifyIntercept");
      if (_notifyIntercept) {
        _notifyIntercept = false;
      } else {
//        LogUtil.printLog("notifyListeners");
        super.notifyListeners();
      }
    }
  }

  /// Handle Error and Exception
  /// 统一处理子类的异常情况
  /// [e],有可能是Error,也有可能是Exception.所以需要判断处理
  /// [s] 为堆栈信息
  void handleCatch(e, s) {
    // DioError的判断,理论不应该拿进来,增强了代码耦合性,抽取为时组件时.应移除
    if (e is DioError && e.error is UnAuthorizedException) {
      setUnAuthorized();
    } else {
      debugPrint('error--->\n' + e.toString());
      debugPrint('stack--->\n' + s.toString());
      setError(e is Error ? e.toString() : e.message);
    }
  }
}

/// 基类 ListVM
abstract class BaseListViewModel<M extends BaseModel, E extends BaseEntity, I>
    extends BaseViewModel<M, E> {
  BaseListViewModel({params, refreshController})
      : super(defaultOfParams: params) {
    _refreshController = refreshController;
  }

  /// 分页第一页页码
  static int pageFirst = 1;

  /// 当前页码
  int _currentPageNum = pageFirst;
  static int _totalPageNum = 1;

  /// 跟上拉刷新 下拉加载 相关配置
  static ControllerBuild _controllerBuild = () => null;
  static ResetRefreshState _resetRefreshState = (c) => {};
  static FinishRefresh _finishRefresh = (c, {bool success, bool noMore}) {};
  static ResetLoadState _resetLoadState = (c) {};
  static FinishLoad _finishLoad = (c, {bool success, bool noMore}) {};

  dynamic _refreshController =
      _controllerBuild == null ? null : _controllerBuild();
  get refreshController => _refreshController;

  /// 重置下拉刷新状态
  resetRefreshState(controller) {
    if (_resetRefreshState != null) _resetRefreshState(controller);
  }

  /// 完成下拉刷新
  finishRefresh(controller, {bool success, bool noMore}) {
    if (_finishRefresh != null)
      _finishRefresh(controller, success: success, noMore: noMore);
  }

  /// 重置上拉加载状态
  resetLoadState(controller) {
    if (_resetLoadState != null) _resetLoadState(controller);
  }

  /// 完成上拉加载
  finishLoad(controller, {bool success, bool noMore}) {
    if (_finishLoad != null)
      _finishLoad(controller, success: success, noMore: noMore);
  }

  @protected
  List<I> get list;

  /// 验证数据
  bool _checkData(bool isLoad, DataResponse<E> data) {
    if (data == null || data.entity == null) return true;
    if (isLoad)
      jointList(data.entity);
    else
      entity = data.entity;
    return judgeNull(data);
  }

  /// 判断页面是否为空
  @protected
  bool judgeNull(DataResponse<E> data) => list == null || list.isEmpty;

  /// 拼接数据
  void jointList(E newEntity);

  /// 请求数据后，子类初始数据
  @override
  void initResultData() {}

  /// 获取数据
  Future<bool> _request({param}) async {
    try {
      _currentPageNum = pageFirst;
      var data = await _httpOrData(false, pageFirst, param);
      resetLoadState(_refreshController);
      if (_checkData(false, data)) {
        return false;
      } else {
        initResultData();
        _totalPageNum = data.totalPageNum ?? 1;
        finishRefresh(_refreshController, success: true);
        return true;
      }
    } catch (e, s) {
      finishRefresh(_refreshController, success: false);
      handleCatch(e, s);
      return false;
    } finally {
      resetLoadState(_refreshController);
      resetRefreshState(_refreshController);
    }
  }

  /// 下拉刷新
  Future<void> pullRefresh({bool globalRefresh = true}) async {
    _activeGlobalRefresh = globalRefresh;
    await viewRefresh(busy: false);
  }

  /// 上拉加载更多
  Future<void> loadMore({bool globalRefresh = true}) async {
//    print('------> current: $_currentPageNum  total: $_totalPageNum');
    _activeGlobalRefresh = globalRefresh;
    if (_currentPageNum >= _totalPageNum) {
      finishLoad(_refreshController, success: true, noMore: true);
    } else {
      var cPage = ++_currentPageNum;
      //debugPrint('ViewStateRefreshListViewModel.loadMore page: $currentPage');
      try {
        var data = await _httpOrData(true, cPage, defaultOfParams);
        if (_checkData(true, data)) {
          _currentPageNum--;
          finishLoad(_refreshController, success: true, noMore: true);
        } else {
          finishLoad(_refreshController,
              success: true, noMore: _currentPageNum >= _totalPageNum);
          notifyListeners();
        }
      } catch (e, s) {
        _currentPageNum--;
        finishLoad(_refreshController, success: false);
        debugPrint('error--->\n' + e.toString());
        debugPrint('stack--->\n' + s.toString());
      } finally {
        resetLoadState(_refreshController);
        resetRefreshState(_refreshController);
      }
    }
  }

  @override
  void dispose() {
    try {
      _refreshController.dispose();
    } catch (e) {}
    super.dispose();
  }
}

/// 基类配置，配置全局默认状态页
class _Config<VM extends BaseViewModel> {
  static VSBuilder gBusy;
  static VSBuilder gEmpty;
  static VSBuilder gError;
  static VSBuilder gunAuthorized;

  VSBuilder<VM> busy;
  VSBuilder<VM> empty;
  VSBuilder<VM> error;
  VSBuilder<VM> unAuthorized;

  _Config(this.busy, this.empty, this.error, this.unAuthorized) {
    this.busy ??= gBusy;
    this.empty ??= gEmpty;
    this.error ??= gError;
    this.unAuthorized ??= gunAuthorized;
  }
}

/// view层 配置用类
class ViewConfig<VM extends BaseViewModel> extends _Config<VM> {
  ViewConfig({
    @required this.vm,
    this.child,
    this.color,
    this.load = true,
    this.checkEmpty = true,
    this.state,
    this.value = false,
    VSBuilder<VM> busy,
    VSBuilder<VM> empty,
    VSBuilder<VM> error,
    VSBuilder<VM> unAuthorized,
  })  : this.root = true,
        super(busy, empty, error, unAuthorized);

  ViewConfig.value({
    @required this.vm,
    this.child,
    this.color,
    this.load = false,
    this.checkEmpty = true,
    this.state,
    this.value = true,
    VSBuilder<VM> busy,
    VSBuilder<VM> empty,
    VSBuilder<VM> error,
    VSBuilder<VM> unAuthorized,
  })  : this.root = true,
        super(busy, empty, error, unAuthorized);

  ViewConfig.noRoot({
    @required this.vm,
    this.child,
    this.color,
    this.load = true,
    this.checkEmpty = true,
    this.state,
    this.value = false,
    VSBuilder<VM> busy,
    VSBuilder<VM> empty,
    VSBuilder<VM> error,
    VSBuilder<VM> unAuthorized,
  })  : this.root = false,
        super(busy, empty, error, unAuthorized);

  /// VM
  VM vm;

  Widget child;

  /// 背景颜色
  Color color;

  /// 加载
  bool load;

  /// 是否根布局刷新 采用 [Selector]
  bool root;

  /// [ChangeNotifierProvider.value] 或者[ChangeNotifierProvider]
  bool value;

  /// 是否验证空数据
  bool checkEmpty;

  /// 页面变化控制  可以被其他页面控制刷新
  int state;
}

/// 获取可用的监听 [ChangeNotifierProvider.value] 或者 [ChangeNotifierProvider]
ChangeNotifierProvider _availableCNP<T extends BaseViewModel>(
    BuildContext context, ViewConfig<T> changeNotifier,
    {Widget child}) {
  if (changeNotifier.value) {
    changeNotifier.vm = Provider.of<T>(context);
    return ChangeNotifierProvider<T>.value(
        value: changeNotifier.vm, child: child);
  } else {
    return ChangeNotifierProvider<T>(
        create: (_) => changeNotifier.vm, child: child);
  }
}

/// 页面状态展示 空 正常 错误 忙碌
Widget _viewState<VM extends BaseViewModel>(
    ViewConfig data, Widget Function(Widget state) builder) {
  VM vm = data.vm;
  var bgColor = data.color;
  var checkEmpty = data.checkEmpty;
  var state = data.state;

  /// 配置状态页 是否自定义
  var empty = data.empty == null ? null : data.empty(vm);
  var busy = data.busy == null ? null : data.busy(vm);
  var error = data.error == null ? null : data.error(vm);
  var un = data.unAuthorized == null ? null : data.unAuthorized(vm);

  Widget _widget;

  /// vm空 ｜｜ 需要验证空并且VM确实没有值
  if (vm == null || checkEmpty && vm.empty) {
    _widget = empty ??
        Container(
          color: bgColor,
          child: ViewStateEmptyWidget(onTap: () => vm.viewRefresh()),
        );
  } else if (vm.busy) {
    _widget = busy ?? ViewStateBusyWidget(backgroundColor: bgColor);
  } else if (vm.error) {
    _widget = error ?? ViewStateWidget(onTap: () => vm.viewRefresh());
  } else if (vm.unAuthorized) {
    _widget = un ?? ViewStateUnAuthWidget(onTap: () => vm.viewRefresh());
  }

  Widget view = builder(_widget);

  /// 添加背景颜色
  if (bgColor != null) view = Container(child: view, color: bgColor);

  /// 判断是否需要页面控制刷新
  if (state == null) {
    return view;
  } else {
    /// view状态变化提醒
    var changer = ValueListenableBuilder(
      valueListenable: changerStateGet(state).vn,
      builder: (_, changer, __) {
//          LogUtil.printLog("state : ${state.toString()} value: $changer");
        try {
          var vsChanger = changerStateCheck(state);
          if (vsChanger.changer) {
//                  LogUtil.printLog("state : ${state.toString()} value: $changer"
//                      "notifier: ${vsChanger.notifier}");
            vm.viewRefresh(notifier: vsChanger.notifier, busy: false);
          }
        } catch (e) {
          print(e);
        }
        return SizedBox();
      },
    );
    return Stack(children: <Widget>[changer, Positioned.fill(child: view)]);
  }
}

/// root 根节点加工 根节点是否需要刷新，不刷新就执行一次刷新 更新第一次状态变化
Widget _root<VM extends BaseViewModel>(
    BuildContext context, ViewConfig config, VMBuilder builder) {
  /// 是否根节点需要刷新
  return _availableCNP<VM>(
    context,
    config,
    child: Selector<VM, dynamic>(
      child: config.child,
      selector: (ctx, vm) => vm.entity,
      shouldRebuild: (_, __) {
        if (config.root) return true;
        if (!config.vm._activeGlobalRefresh) return false;
        config.vm._activeGlobalRefresh = false;
        return true;
      },
      builder: (ctx, value, child) =>
          _viewState(config, (state) => builder(ctx, config.vm, child, state)),
    ),
  );
}

/// 基类 view 扩展[StatelessWidget]
mixin BaseView<VM extends BaseViewModel> on StatelessWidget {
  /// 初始化配置
  @protected
  ViewConfig<VM> initConfig(BuildContext context);

  /// VM 相关
  @protected
  Widget vmBuild(BuildContext context, VM vm, Widget child, Widget state);

  /// 初始化操作 加载等
  _init(BuildContext context, ViewConfig<VM> config) async {
    config.vm.context ??= context;
    if (config.load) await config.vm.viewRefresh();
  }

  /// 不要使用  推荐使用 [vmBuild]
  @override
  @deprecated
  Widget build(BuildContext ctx) {
//    LogUtil.printLog("build:----" + this.runtimeType.toString());
    var config = initConfig(ctx);
    if (config == null) throw "initConfig 方法 返回空值";

    /// 是否需要加载
    if (!config.load) return _root<VM>(ctx, config, vmBuild);

    return FutureBuilder(
        future: _init(ctx, config),
        builder: (ctx, __) => _root<VM>(ctx, config, vmBuild));
  }
}

/// 基类 state 扩展[StatefulWidget] 的 [State]
mixin BaseViewOfState<T extends StatefulWidget, VM extends BaseViewModel>
    on State<T> {
  ViewConfig<VM> _config;

  /// VM 相关
  @protected
  Widget vmBuild(BuildContext context, VM vm, Widget child, Widget state);

  /// 初始化配置
  @protected
  ViewConfig<VM> initConfig(BuildContext context);

  /// 初始化操作 加载等
  @override
  void initState() {
    _config = initConfig(context);
    if (_config == null) {
      throw "initConfig 方法 返回空值";
    }
    _config.vm.context ??= context;
    if (_config.load) _config.vm.viewRefresh();
    super.initState();
  }

  /// 不要使用  推荐使用 [vmBuild]
  @override
  Widget build(BuildContext context) {
    super.build(context);
//    LogUtil.printLog("build:----" + this.runtimeType.toString());
    return _root<VM>(context, _config, vmBuild);
  }
}
