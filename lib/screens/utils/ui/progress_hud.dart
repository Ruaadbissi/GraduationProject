import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';






class ProgressHud {
  static ProgressHud shared = ProgressHud();
  BuildContext? context;

  Widget createLoadingView({
    Color? color,
    double size = 30.0,
  }) {
    return Stack(
      children: <Widget>[
        getCircularProgressIndicator(
            color: color ?? Colors.black, size: size),
      ],
    );
  }

  Widget createPagenationView({
    Color? color,
    double size = 30.0,
  }) {
    return Stack(
      children: <Widget>[
        SpinKitCircle(color: color ?? Colors.black, size: size),
      ],
    );
  }

  Widget getCircularProgressIndicator({
    Color? color,
    double size = 30.0,
  }) =>
      Center(child: SpinKitCubeGrid(color: color, size: size));

  void startLoading(BuildContext context) {
    ProgressHud.shared.context = context;

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return createLoadingView(size: 50);
      },
    );
  }

  void stopLoading() {
    try {
      if (ProgressHud.shared.context != null &&
          Navigator.of(ProgressHud.shared.context!).canPop()) {
        Navigator.of(ProgressHud.shared.context!, rootNavigator: true)
            .pop('Discard');
        ProgressHud.shared.context = null;
      }
    } catch (_) {}
  }
}
