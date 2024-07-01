import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final String os;
  final Color? color;
  final double? strWidth;

  const LoadingIndicator({super.key, required this.os, this.color, this.strWidth});

  @override
  Widget build(BuildContext context) {
    if (os == 'android') {
      return CircularProgressIndicator(
        color: color ?? Theme.of(context).colorScheme.primary,
        strokeCap: StrokeCap.round,
        strokeWidth: strWidth ?? 4.0,
      );
    } else {
      return CupertinoActivityIndicator(
        color: color ?? Theme.of(context).colorScheme.primary,
      );
    }
  }
}
