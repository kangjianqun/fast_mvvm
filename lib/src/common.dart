import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'base.dart';

/// 接口数据 响应
class DataResponse<T> {
  T entity;

  /// 最终结果
  bool result;

  /// dio 的默认
  Response response;

  /// 当前页面总页码  配合 [BaseListViewModel] 默认一页
  int totalPageNum;

  /// 扩展数据
  Map<String, dynamic> extend;

  /// 语法糖
  get data => response.data;

  /// 语法糖 默认的[Response]的statusCode 可以在 [InterceptorsWrapper] 自定义处理
  int get code => response.statusCode;

  DataResponse({
    @required this.entity,
    this.result = false,
    this.response,
    this.totalPageNum = 1,
  });

  /// 拷贝
  DataResponse.copy(
      {DataResponse dataResponse,
      @required this.entity,
      this.response,
      this.totalPageNum,
      this.result,
      this.extend}) {
    response ??= dataResponse.response;
    totalPageNum ??= dataResponse.totalPageNum;
    result ??= dataResponse.result;
    extend ??= dataResponse.extend;
  }
}

/// view层 配置用类  配置全局默认状态页
class ViewConfig<VM extends BaseViewModel> {
  ViewConfig({
    @required this.vm,
    this.child,
    this.color,
    this.load = true,
    this.checkEmpty = true,
    this.state,
    this.value = false,
    this.busy,
    this.empty,
    this.error,
    this.unAuthorized,
  }) : this.root = true {
    setViewState();
  }

  ViewConfig.value({
    @required this.vm,
    this.child,
    this.color,
    this.load = false,
    this.checkEmpty = true,
    this.state,
    this.value = true,
    this.busy,
    this.empty,
    this.error,
    this.unAuthorized,
  }) : this.root = true {
    setViewState();
  }

  ViewConfig.noRoot({
    @required this.vm,
    this.child,
    this.color,
    this.load = true,
    this.checkEmpty = true,
    this.state,
    this.value = false,
    this.busy,
    this.empty,
    this.error,
    this.unAuthorized,
  }) : this.root = false {
    setViewState();
  }

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

  static VSBuilder gBusy;
  static VSBuilder gEmpty;
  static VSBuilder gError;
  static VSBuilder gunAuthorized;

  /// 列表页  列表数据空
  static VSBuilder gListDataEmpty;

  VSBuilder<VM> busy;
  VSBuilder<VM> empty;
  VSBuilder<VM> error;
  VSBuilder<VM> unAuthorized;

  void setViewState() {
    this.busy ??= gBusy;
    this.empty ??= gEmpty;
    this.error ??= gError;
    this.unAuthorized ??= gunAuthorized;
  }
}

/// 获取可用的监听 [ChangeNotifierProvider.value] 或者 [ChangeNotifierProvider]
ChangeNotifierProvider availableCNP<T extends BaseViewModel>(
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

class _ViewStateNotifier {
  ValueNotifier<bool> vn;
  bool notifier;
  _ViewStateNotifier(this.vn, {this.notifier = true});
}

/// 状态通知 跨页面通知数据需要变动
class ViewStateNotifier {
  bool changer;
  bool notifier;

  ViewStateNotifier(this.changer, this.notifier);
}

/// 全局状态变动存储
Map<int, _ViewStateNotifier> _changerState = {};

/// 获取状态配置
_ViewStateNotifier changerStateGet(int state) {
  if (!_changerState.containsKey(state)) {
    _changerState[state] = _ViewStateNotifier(ValueNotifier(false));
  }
  return _changerState[state];
}

/// 更新页面状态
void changerStateUpdate(int state, {bool notifier = true}) {
  if (_changerState.containsKey(state)) {
    _changerState[state].vn.value = true;
    _changerState[state].notifier = notifier;
  }
}

/// 验证是否需要变化
ViewStateNotifier changerStateCheck(int state) {
  var result = _changerState[state].vn.value;
  _changerState[state].vn.value = false;
  return ViewStateNotifier(result, _changerState[state].notifier);
}

/// 全局Model管理
Map<String, BaseModel> _mList = {};

/// 添加Model
void addModel({List<BaseModel> list}) =>
    list.forEach((element) => _addModel(element));

_addModel(BaseModel model) => _mList[model.runtimeType.toString()] = model;

/// 全局Model
M getModelGlobal<M extends BaseModel>() => _mList[M.toString()];

/// 得到通知者
T getVM<T extends ChangeNotifier>(BuildContext ctx, {bool listen: false}) =>
    Provider.of<T>(ctx, listen: listen);
