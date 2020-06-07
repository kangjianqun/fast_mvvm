import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'base.dart';

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
            padding: EdgeInsets.only(top: 48,bottom: 88),
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
