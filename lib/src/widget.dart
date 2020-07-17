import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'base.dart';
import 'common.dart';

double pageWidth = 1080;
double pageHeight = 1920;

/// 初始化页面大小 注意适配宽高 还有标题栏高度
void initPageSize(double width, double height) {
  if (height != null) pageHeight = height;
  if (width != null) pageWidth = width;
}

Widget vmEmptyView<T extends BaseViewModel>(
    {@required Function(T vm) builder,
    bool Function(T vm) isEmpty,
    Widget nullChild}) {
  return Consumer<T>(
    builder: (_, vm, __) {
//      LogUtil.printLog(vm.empty);
      bool isNull = isEmpty != null ? isEmpty(vm) : vm.empty;
      return isNull
          ? nullChild ?? ViewStateEmptyWidget(onTap: () => vm.viewRefresh())
          : builder(vm);
    },
  );
}

/// 空Widget大小类型
enum EmptySizeType {
  Not, // 无
  Expanded,
  Size, // 确定
}

enum MaxIndex { top, center, below }

/// 用于当 List 或者 Grid 空的时候生成完整的整页面
/// 如果在[ListView] 里面用
class EmptyIntactWidget {
  EmptyIntactWidget({
    this.top,
    this.center,
    this.below,
    @required this.maxIndex,
  });

  /// 上
  Widget top;

  /// 中
  Widget center;

  /// 下
  Widget below;

  /// 选择哪个最大填充 并且为 List和Grid数据显示的位置
  MaxIndex maxIndex;
}

/// 内容容器 判断 List 或者 Grid 是否为空 显示内容或加载空视图
class ListOrGridEmpty extends StatelessWidget {
  const ListOrGridEmpty({
    Key key,
    @required this.vm,
    @required this.childBuild,
    this.emptyBuild,
    this.emptySizeType = EmptySizeType.Not,
    this.childDifferent = true,
  })  : height = null,
        width = null,
        super(key: key);

  /// [Column] 用这个
  const ListOrGridEmpty.max({
    Key key,
    @required this.vm,
    @required this.childBuild,
    this.emptyBuild,
    this.emptySizeType = EmptySizeType.Expanded,
    this.childDifferent = true,
  })  : height = null,
        width = null,
        super(key: key);

  /// 固定大小，按需使用
  const ListOrGridEmpty.size({
    Key key,
    @required this.vm,
    @required this.childBuild,
    @required this.height,
    @required this.width,
    this.emptyBuild,
    this.emptySizeType = EmptySizeType.Size,
    this.childDifferent = true,
  }) : super(key: key);

  final BaseListViewModel vm;
  final Function() childBuild;
  final VSBuilder<BaseListViewModel> emptyBuild;
  final EmptySizeType emptySizeType;

  /// [childBuild] 不依赖[EmptySizeType]
  final bool childDifferent;
  final num height;
  final num width;

  /// 如果空数据则 显示完整的单独页 在[ListView] 里面用 完整页面 需要大小 可以全局设置
  /// 场景 文章页 头部是广告 下方为文章列表 当list 应该显示广告，列表显示空
  static List<Widget> listWidget({
    @required EmptyIntactWidget emptyIntactWidget,
    num height,
    num width,
    @required BaseListViewModel vm,
    VSBuilder<BaseListViewModel> emptyBuild,
  }) {
    List<Widget> list = [];
    double _height = height ?? pageHeight;
    double _width = width ?? pageWidth;

    var empty = vm.list == null || vm.list.length <= 0;

    Widget emptyView = Expanded(child: _emptyWidget(emptyBuild, vm));

    Widget _top = emptyIntactWidget.top,
        _center = emptyIntactWidget.center,
        _below = emptyIntactWidget.below;
    switch (emptyIntactWidget.maxIndex) {
      case MaxIndex.top:
        _top = empty ? emptyView : emptyIntactWidget.top;
        break;
      case MaxIndex.center:
        _center = empty ? emptyView : emptyIntactWidget.center;
        break;
      case MaxIndex.below:
        _below = empty ? emptyView : emptyIntactWidget.below;
        break;
    }

    if (_top != null) list.add(_top);
    if (_center != null) list.add(_center);
    if (_below != null) list.add(_below);

    if (empty)
      list = [
        Container(width: _width, height: _height, child: Column(children: list))
      ];

    return list;
  }

  /// 空视图 优先级
  static Widget _emptyWidget(
      VSBuilder<BaseListViewModel> emptyBuild, BaseListViewModel vm) {
    return emptyBuild != null
        ? emptyBuild(vm)
        : ViewConfig.gListDataEmpty != null
            ? ViewConfig.gListDataEmpty(vm)
            : ViewStateEmptyWidget(
                onTap: () => vm.viewRefresh(rootRefresh: true));
  }

  @override
  Widget build(BuildContext context) {
    var empty = vm.list == null || vm.list.length <= 0;

    Widget view = empty ? _emptyWidget(emptyBuild, vm) : childBuild();
    if (!childDifferent) {
      switch (emptySizeType) {
        case EmptySizeType.Not:
          break;
        case EmptySizeType.Expanded:
          view = Expanded(child: view);
          break;
        case EmptySizeType.Size:
          view = Container(height: height, width: width, child: view);
          break;
      }
    }

    return view;
  }
}

/// 用于未登录等权限不够,需要跳转授权页面
class UnAuthorizedException implements Exception {
  const UnAuthorizedException();

  @override
  String toString() => 'UnAuthorizedException';
}

/// 加载中
class ViewStateBusyWidget extends StatelessWidget {
  const ViewStateBusyWidget({
    Key key,
    this.backgroundColor,
  }) : super(key: key);
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.white,
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}

/// 基础Widget
class ViewStateWidget extends StatelessWidget {
  ViewStateWidget({
    Key key,
    this.image,
    this.message,
    this.buttonText,
    @required this.onTap,
  }) : super(key: key);

  final String message;
  final Widget image;
  final Widget buttonText;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          image ?? Icon(Icons.error_outline, size: 48, color: Colors.grey[500]),
          Padding(
            padding: EdgeInsets.only(top: 48, bottom: 88),
            child: Text(
              message ?? "加载失败",
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(color: Colors.grey),
            ),
          ),
          ViewStateButton(child: buttonText, onTap: onTap)
        ],
      ),
    );
  }
}

/// 页面无数据
class ViewStateEmptyWidget extends StatelessWidget {
  const ViewStateEmptyWidget({
    Key key,
    this.image,
    this.message,
    this.buttonText,
    @required this.onTap,
  }) : super(key: key);

  final String message;
  final Widget image;
  final Widget buttonText;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ViewStateWidget(
      onTap: this.onTap,
      image: image ??
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
      message: message ?? "空空如也",
      buttonText: buttonText ?? Text("刷新一下", style: TextStyle(fontSize: 20)),
    );
  }
}

/// 页面未授权
class ViewStateUnAuthWidget extends StatelessWidget {
  const ViewStateUnAuthWidget({
    Key key,
    this.image,
    this.message,
    this.buttonText,
    @required this.onTap,
  }) : super(key: key);

  final String message;
  final Widget image;
  final Widget buttonText;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ViewStateWidget(
      onTap: this.onTap,
      image: image,
      message: message ?? "未登录",
      buttonText: buttonText ?? Text("登录", style: TextStyle(wordSpacing: 5)),
    );
  }
}

/// 公用Button
class ViewStateButton extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget child;

  const ViewStateButton({@required this.onTap, this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: child ??
          Container(
            padding: EdgeInsets.fromLTRB(32, 8, 32, 8),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.horizontal(),
            ),
            child: Text(
              "重试",
              style: TextStyle(fontSize: 50),
            ),
          ),
      onTap: onTap,
    );
  }
}
