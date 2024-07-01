import 'package:chat_ai/firebase_options.dart';
import 'package:chat_ai/presentation/modules/chatModule/ChatScreen.dart';
import 'package:chat_ai/presentation/modules/startUpModule/authOptionsScreen/AuthOptionsScreen.dart';
import 'package:chat_ai/presentation/modules/startUpModule/splashScreen/SplashScreen.dart';
import 'package:chat_ai/presentation/modules/startUpModule/welcomeScreen/WelcomeScreen.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/cubits/appCubit/AppCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/forgetPassCubit/ForgotPassCubit.dart';
import 'package:chat_ai/shared/cubits/signInCubit/SignInCubit.dart';
import 'package:chat_ai/shared/cubits/signUpCubit/SignUpCubit.dart';
import 'package:chat_ai/shared/cubits/themeCubit/ThemeCubit.dart';
import 'package:chat_ai/shared/cubits/themeCubit/ThemeStates.dart';
import 'package:chat_ai/shared/network/local/CacheHelper.dart';
import 'package:chat_ai/shared/network/remot/DioHelper.dart';
import 'package:chat_ai/shared/simpleBlocObserver/SimpleBlocObserver.dart';
import 'package:chat_ai/shared/styles/Styles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:overlay_support/overlay_support.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Bloc.observer = SimpleBlocObserver();

  await CacheHelper.init();

  DioHelper.init();

  bool? isStarted = CacheHelper.getCachedData(key: 'isStarted');

  var isDark = CacheHelper.getCachedData(key: 'isDark');

  uId = CacheHelper.getCachedData(key: 'uId');


  Widget widget;

  if(isStarted != null) {
    if(uId != null) {
      widget = const ChatScreen();
    } else {
      widget = const AuthOptionsScreen();
    }
  } else {
    widget = const WelcomeScreen();
  }

  runApp(MyApp(startWidget: widget, isDark: isDark,));
}

class MyApp extends StatelessWidget {

  final Widget? startWidget;
  final bool? isDark;

  const MyApp({super.key, this.startWidget, this.isDark});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (BuildContext context) => AppCubit()),
        BlocProvider(create: (BuildContext context) => SignInCubit()),
        BlocProvider(create: (BuildContext context) => SignUpCubit()),
        BlocProvider(create: (BuildContext context) => ForgotPassCubit()),
        BlocProvider(create: (BuildContext context) => CheckCubit()..checkConnection()),
        BlocProvider(create: (BuildContext context) => ThemeCubit()..changeTheme(isDark ?? false)),
      ],
      child: BlocConsumer<ThemeCubit, ThemeStates>(
        listener: (context, state) {},
        builder: (context, state) {

          var cubit = ThemeCubit.get(context);

          return OverlaySupport.global(
            child: MaterialApp(
              title: 'Flutter ChatAI App',
              debugShowCheckedModeBanner: false,
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: cubit.isDarkTheme ? ThemeMode.dark : ThemeMode.light,
              home: SplashScreen(startWidget: startWidget!),
            ),
          );
        },
      ),
    );
  }
}

