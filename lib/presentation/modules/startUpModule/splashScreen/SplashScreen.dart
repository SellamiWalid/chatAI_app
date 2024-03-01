import 'package:animate_do/animate_do.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/cubits/appCubit/AppCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {

  final Widget startWidget;

  const SplashScreen({super.key,required this.startWidget});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      if(CheckCubit.get(context).hasInternet == true) {
        if(uId != null) AppCubit.get(context).getProfile();
        Future.delayed(const Duration(seconds: 1)).then((value) {
          navigateAndNotReturn(context: context, screen: widget.startWidget);
          CheckCubit.get(context).changeStatus();
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckCubit, CheckStates>(
      listener: (context, state) {

        var checkCubit = CheckCubit.get(context);

        if(state is SuccessCheckState) {
          if(!checkCubit.hasInternet) {
            Future.delayed(const Duration(seconds: 1)).then((value) {
              showAlertCheckConnection(context, isSplashScreen: true);
            });
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          body: ZoomIn(
            duration: const Duration(milliseconds: 400),
            child: Center(
              child: Image.asset('assets/images/logo.png',
                height: 170.0,
                width: 170.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
