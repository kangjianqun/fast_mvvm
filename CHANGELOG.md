## 1.2.2+2
修复 ListOrGridEmpty 新增 emptyViewUseViewSizeType

修改pageWidth | pageHeight为_pageWidth _pageHeight 防止变量名冲突

## 1.2.2+1
修复 ListOrGridEmpty 错误 修改 childDifferent 为 useViewSizeType

## 1.2.2
新增 ViewConfig.noLoad
修复 ListOrGridEmpty.max 错误

## 1.2.1
修复 ListOrGridEmpty.listWidget 异常。
新增 BaseListViewModel 的 item 方法

## 1.2.0+2

新增 DataResponse 的 extend 属性；
新增 DataResponse 新的构造 DataResponse.copy

## 1.2.0+1
修复 ListOrGridEmpty.listWidget 异常。

新增 页面大小设置 initPageSize

## 1.2.0
修复 刷新状态异常。

## 1.1.9+4
修改 部分代码和注释与注解。

## 1.1.9+3
修改 BaseViewState build 兼容。
新增 BaseViewState 类中的 mixinBuild 方法

## 1.1.9+2
修改 BaseViewState build 兼容。
新增 ViewConfig.gListDataEmpty 配置列表页面->广告数据非空，列表数据空时的空视图，

## 1.1.9+1
修改 _disposeAdd 异常 兼容处理 null 和 StreamSubscription

## 1.1.9
修改 _disposeAdd 异常 导致page页面错误

## 1.1.8
修复 从列表页进入下一页面，返回列表页上拉失效。

ListOrGridEmpty 新增 listWidget 方法

initMVVM 新增 height 和 width 设置

## 1.1.7
优化 ViewConfig 配置

## 1.1.6
修复 The class doesn't have a concrete implementation of the super-invoked member 'build'. 错误

优化 ViewConfig 配置 checkEmpty 应用到BaeViewModel上面；
优化 刷新页面便捷方法；
新增 initPage 功能；
新增 ListOrGridEmpty；

## 1.1.5
新增公共方法getVM(),得到ViewModel全局调用的语法糖。
initMVVM 初始化新增参数 DataFromNetworkOrDatabase

## 1.1.4
BaseView新增获取对应ViewModel方法 VM vm(BuildContext context)；

BaseViewOfState新增获取对应ViewModel方法 VM vm()；

## 1.1.3
优化根布局刷新，修复当开启根布局不刷新后，页面为空或者数据错误，点击刷新没有效果。
增加demo状态页配置案例。

## 1.1.2
修复单独页面配置状态页类型错误。

## 1.1.1
修复不规范配置 上拉刷新下拉加载 造成的空异常。

## 1.1.0
优化刷新的空判断。

## 1.0.9

去掉 flutter_easyrefresh 依赖，initMVVM增加上拉刷新下拉加载全局配置

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
