import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {

  final String os;

  const LoadingIndicator({super.key, required this.os});

  @override
  Widget build(BuildContext context) {

    if(os == 'android') {

      return CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      );

    } else {

      return CupertinoActivityIndicator(
        color: Theme.of(context).colorScheme.primary,
      );

    }
  }
}
