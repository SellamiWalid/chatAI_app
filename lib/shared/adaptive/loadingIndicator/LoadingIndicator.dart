import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {

  final String os;
  final Color? color;

  const LoadingIndicator({super.key, required this.os, this.color});

  @override
  Widget build(BuildContext context) {

    if(os == 'android') {

      return CircularProgressIndicator(
        color: color ?? Theme.of(context).colorScheme.primary,
      );

    } else {

      return CupertinoActivityIndicator(
        color: color ?? Theme.of(context).colorScheme.primary,
      );

    }
  }
}
