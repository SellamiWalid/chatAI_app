import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingIndicatorKit extends StatelessWidget {
  final String os;
  final Color? color;
  const LoadingIndicatorKit({super.key, required this.os, this.color});

  @override
  Widget build(BuildContext context) {
    if (os == 'android') {
      return SpinKitRing(
        color: color ?? Theme.of(context).colorScheme.primary,
        size: 30.0,
        lineWidth: 3.0,
      );
    } else {
      return SpinKitFadingCircle(
        color: color ?? Theme.of(context).colorScheme.primary,
        size: 30.0,
      );
    }
  }
}
