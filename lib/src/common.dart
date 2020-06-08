import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

import 'base.dart';

class DataResponse<T> {
  T entity;
  bool result;
  Response response;
  int totalPageNum;
  get data => response.data;

  DataResponse({
    @required this.entity,
    this.result = false,
    this.response,
    this.totalPageNum = 1,
  });
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

void _addModel(BaseModel model) => _mList[model.runtimeType.toString()] = model;

/// 全局Model
M getModelGlobal<M extends BaseModel>() => _mList[M.toString()];
