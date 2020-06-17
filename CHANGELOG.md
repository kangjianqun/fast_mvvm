## 1.0.9

去掉 flutter_easyrefresh 依赖，initMVVM增加刷新全局配置

## 1.0.8
优化的刷新控制，子类可以自己实现控制

BaseListViewModel

BaseListViewModel({params, refreshController})
      : super(defaultOfParams: params) {
    _refreshController = refreshController;
  }

resetRefreshState｜finishRefresh｜resetLoadState｜finishLoad

## 1.0.7
优化代码和注释。

## 1.0.6
修复开启根布局不刷新，下拉刷新获取数据状态控制失效
新增下拉刷新方法 pullRefresh()

## 1.0.5
Demo 增加关于数据刷新的展示。

## 1.0.4
修复http跟本地组装数据

## 1.0.3
initMVVM 初始化提供全局状态页配置

## 1.0.2
更正说明

## 1.0.1
更新一下说明 和案例

## 0.0.1
首次上传 有简单的demo 暂时处理的不完善
