import 'package:animate_do/animate_do.dart';
import 'package:chat_ai/presentation/modules/startUpModule/authOptionsScreen/AuthOptionsScreen.dart';
import 'package:chat_ai/shared/adaptive/loadingIndicator/LoadingIndicator.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/cubits/themeCubit/ThemeCubit.dart';
import 'package:chat_ai/shared/styles/Colors.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:hexcolor/hexcolor.dart';

navigateTo({required BuildContext context , required Widget screen}) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));



navigateAndNotReturn({required BuildContext context, required Widget screen}) =>
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (context) => screen), (route) => false);



Route createRoute({required screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}



Route createSecondRoute({required screen}) {
  return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeIn;

        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      });
}


Widget defaultFormField({
  required String label,
  required TextEditingController controller,
  required TextInputType type,
  required FocusNode focusNode,
  required String? Function(String?) ? validate,
  bool isPassword = false,
  IconData? prefixIcon,
  IconData? suffixIcon,
  Function? onPress,
  void Function(String?) ? onSubmit,
  // bool? isAuth,
  // required BuildContext context,

}) => TextFormField(
  controller: controller,
  keyboardType: type,
  focusNode: focusNode,
  obscureText: isPassword,
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: 0.6,
  ),
  decoration: InputDecoration(
    labelText: label,
    errorMaxLines: 3,
    // fillColor: ThemeCubit.get(context).isDark ? firstDarkColor : Colors.blueGrey.shade100.withOpacity(.1),
    // filled: (isAuth == true) ? true : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: const BorderSide(
        width: 2.0,
      ),
    ),
    prefixIcon: (prefixIcon != null) ? Icon(prefixIcon) : null,
    suffixIcon: (suffixIcon != null) ? ((controller.text.isNotEmpty) ? IconButton(
      onPressed: () => onPress!(),
      icon: Icon(suffixIcon),
    ) : null ): null,
  ),
  validator: validate,
  onFieldSubmitted: (value) {
    if(value.isNotEmpty) {
      onSubmit!(value);
    }
  },
);



Widget defaultSearchFormField({
  required String text,
  required TextEditingController controller,
  required TextInputType type,
  required FocusNode focusNode,
  void Function(String) ? onChange,
  Function? onPress,
  void Function(String?) ? onSubmit,

}) => TextFormField(
  controller: controller,
  keyboardType: TextInputType.text,
  textCapitalization: TextCapitalization.sentences,
  style: const TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: 0.6,
  ),
  decoration: InputDecoration(
    hintText: text,
    hintStyle: const TextStyle(
      letterSpacing: 0.6,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.0),
      borderSide: const BorderSide(
        width: 2.0,
      ),
    ),
    prefixIcon: const Icon(
      EvaIcons.searchOutline,
    ),
    suffixIcon: (controller.text.isNotEmpty) ? IconButton(
      onPressed: () {
        onPress!();
      },
      icon: const Icon(
        Icons.close_rounded,
      ),
    ) : null,
  ),
  onChanged: onChange,
  onFieldSubmitted: (value) {
    if(value.isNotEmpty) {
      onSubmit!(value);
    }
  },
);


Widget defaultButton({
  double width = double.infinity,
  double height = 48.0,
  required String text,
  required Function onPress,
  required BuildContext context,
}) => SizedBox(
  width: width,
  child: MaterialButton(
    height: height,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
    color: Theme.of(context).colorScheme.primary,
    onPressed: () {
      onPress();
    },
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18.0,
        color: Colors.white,
        letterSpacing: 0.5,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
);


Widget defaultSecondButton({
  required Function onPress,
  required String text,
  required IconData icon
}) => OutlinedButton(
  onPressed: onPress(),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon),
      const SizedBox(
        width: 8.0,
      ),
      Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ],
  ),
);


Widget defaultTextButton({
  required String text,
  required Function onPress,
}) => TextButton(
  onPressed: () {
    onPress();
  },
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 16.5,
      letterSpacing: 0.5,
      fontWeight: FontWeight.bold,
    ),
  ),
);


defaultAppBar({
  required Function onPress,
  String? title,
  List<Widget>? actions,
}) => AppBar(
  clipBehavior: Clip.antiAlias,
  leading: IconButton(
    onPressed: () {
      onPress();
    },
    icon: const Icon(
      Icons.arrow_back_ios_new_rounded,
    ),
    tooltip: 'Back',
  ),
  titleSpacing: 5.0,
  title: Text(
    title ?? '',
    maxLines: 1,
    style: const TextStyle(
      overflow: TextOverflow.ellipsis,
      fontSize: 19.0,
      letterSpacing: 0.6,
      fontWeight: FontWeight.bold,
    ),
  ),
  actions: actions,
);


enum ToastStates {success , warning , error}

void showFlutterToast({
  required String message,
  required ToastStates state,
  required BuildContext context,
  int duration = 3,
  StyledToastPosition position = StyledToastPosition.bottom,
}) =>
    showToast(
      message,
      context: context,
      backgroundColor: chooseToastColor(s: state),
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: position,
      animDuration: const Duration(milliseconds: 1500),
      duration: Duration(seconds: duration),
      curve: Curves.elasticInOut,
      reverseCurve: Curves.linear,
    );


Color chooseToastColor({
  required ToastStates s,
}) {

  return switch(s) {

    ToastStates.success => greenColor,
    ToastStates.warning => Colors.amber.shade900,
    ToastStates.error => Colors.red,

  };

}


Widget defaultIconButton({
  required String toolTip,
  required double elevation,
  required double radius1,
  required double radius2,
  required double padding,
  required Function function,
  required IconData icon,
  required color,
  required colorIcon,
  double? sizeIcon,
}) =>  Tooltip(
  message: toolTip,
  enableFeedback: true,
  child: Material(
    elevation: elevation,
    borderRadius: BorderRadius.circular(radius1),
    clipBehavior: Clip.antiAlias,
    color: color,
    child: InkWell(
      borderRadius: BorderRadius.circular(radius2),
      onTap: () => function(),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Icon(
          icon,
          color: colorIcon,
          size: sizeIcon,
        ),
      ),
    ),
  ),
);


dynamic showLoading(context) => showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return FadeIn(
        duration: const Duration(milliseconds: 200),
        child: PopScope(
          canPop: false,
          child: Center(
            child: Container(
                padding: const EdgeInsets.all(26.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18.0),
                  color: ThemeCubit.get(context).isDarkTheme ? HexColor('141d26') : Colors.white,
                ),
                clipBehavior: Clip.antiAlias,
                child: LoadingIndicator(os: getOs())),
          ),
        ),
      );
    });



dynamic showAlertExit(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          title: const Text(
            'Do you want to exit?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.0,
              letterSpacing: 0.6,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'No',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: Text(
                'Exit',
                style: TextStyle(
                  color: redColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}


dynamic showAlertVerification(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                16.0,
              ),
            ),
            title: Text(
              'Time is up!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.0,
                color: redColor,
                letterSpacing: 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'You did not verify your email on specified time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.0,
                letterSpacing: 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  navigateAndNotReturn(
                      context: context, screen: const AuthOptionsScreen());
                },
                child: const Text(
                  'Ok',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

dynamic showAlertCheckConnection(BuildContext context , {bool isSplashScreen = false}) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return FadeIn(
        duration: const Duration(milliseconds: 300),
        child: PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              'No Internet Connection',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                letterSpacing: 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'You are currently offline!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17.0,
                letterSpacing: 0.6,
              ),
            ),
            actions: [
              if(!isSplashScreen)
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Wait',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(
                  'Exit',
                  style: TextStyle(
                    color: redColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


