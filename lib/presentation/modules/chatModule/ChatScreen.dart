import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:chat_ai/data/models/userModel/UserModel.dart';
import 'package:chat_ai/presentation/modules/chatModule/SearchChatScreen.dart';
import 'package:chat_ai/presentation/modules/startUpModule/authOptionsScreen/AuthOptionsScreen.dart';
import 'package:chat_ai/shared/adaptive/loadingIndicator/LoadingIndicator.dart';
import 'package:chat_ai/shared/adaptive/loadingIndicator/LoadingIndicatorKit.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/cubits/appCubit/AppCubit.dart';
import 'package:chat_ai/shared/cubits/appCubit/AppStates.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckCubit.dart';
import 'package:chat_ai/shared/cubits/checkCubit/CheckStates.dart';
import 'package:chat_ai/shared/cubits/themeCubit/ThemeCubit.dart';
import 'package:chat_ai/shared/cubits/themeCubit/ThemeStates.dart';
import 'package:chat_ai/shared/network/local/CacheHelper.dart';
import 'package:chat_ai/shared/styles/Colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_icons/icons8.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {

  final TextEditingController msgController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final FocusNode focusNode = FocusNode();

  final FocusNode focusNode2 = FocusNode();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final GlobalKey<FormState> anotherFormKey = GlobalKey<FormState>();

  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  late AnimationController animationController;

  final SpeechToText speechToText = SpeechToText();

  final FlutterTts flutterTts = FlutterTts();

  final ScrollController scrollController = ScrollController();

  bool isVisible = false;
  bool isVocalVisible = true;

  bool isHasFocus = false;

  bool isMicActive = false;

  bool isStartListening = false;

  String textInput = '';

  bool isLoading = false;
  bool isMicLoading = false;

  bool isCanSpeak = false;
  bool isSpeaking = false;

  bool get isIOS => Platform.isIOS;
  bool get isAndroid => Platform.isAndroid;

  bool canExit = false;

  bool isChatEmpty = false;

  String local = 'en-US';

  void toast(text) {
    showToast(
      text,
      context: context,
      backgroundColor: Colors.grey.shade800.withOpacity(.9),
      animation: StyledToastAnimation.scale,
      reverseAnimation: StyledToastAnimation.fade,
      position: StyledToastPosition.bottom,
      animDuration: const Duration(milliseconds: 1200),
      duration: const Duration(milliseconds: 3500),
      curve: Curves.elasticInOut,
      reverseCurve: Curves.linear,
    );
  }


  void exit(timeBackPressed) {
    final difference = DateTime.now().difference(timeBackPressed);
    final isWarning = difference >= const Duration(milliseconds: 500);
    timeBackPressed = DateTime.now();

    if (isWarning) {
      toast('Press back again to exit');
      setState(() {
        canExit = false;
      });
    } else {
      SystemNavigator.pop();
      setState(() {
        canExit = true;
      });
    }
  }


  Future<void> startListening(lang) async {
    await HapticFeedback.vibrate();
    setState(() {
      isStartListening = true;
    });
    var available = await speechToText.initialize(
      onError: (error) {
        setState(() {
          isStartListening = false;
        });
      },
    );

    if(available) {
      await speechToText.listen(
        localeId: lang,
        onResult: (value) {
          setState(() {
            textInput = value.recognizedWords;
          });
        },
        pauseFor: const Duration(seconds: 5),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.deviceDefault,
        ),
      );
    }
  }


  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {
      isStartListening = false;
    });
  }


  // For IOS
  void tts() async {
    await flutterTts.setSharedInstance(true);
  }


  void aiSpeak(content, lang) async {
    if(isAndroid) {
      await flutterTts.getDefaultVoice;
    }
    await flutterTts.setLanguage(lang);
    await flutterTts.speak(content);
    setState(() {
      isSpeaking = true;
    });
  }


  Future<void> vocalConfig(lang) async {
    var cubit = AppCubit.get(context);
    if(!isStartListening && speechToText.isNotListening) {
      if(isSpeaking) {
        await flutterTts.stop();
        setState(() {
          isSpeaking = false;
        });
      }
      await startListening(lang);
    } else {
      await stopListening();
      if(textInput.isNotEmpty) {
        setState(() {
          isMicLoading = true;
        });
        if(cubit.image != null) {
          await Future.delayed(const Duration(milliseconds: 200)).then((value) {
            cubit.clearImage();
          });
        }
        await cubit.sendMessage(
          message: textInput,
          dateTime: DateTime.now().toString(),
          timesTamp: Timestamp.now(),
          idChat: (cubit.chats.isNotEmpty) ?
          cubit.groupedIdChats.values.
          elementAt(cubit.globalIndex ?? 0)[cubit.currentIndex ?? 0] : null,
        );
      }
    }
  }


  void resetSettings() {
    setState(() {
      isMicActive = false;
      isStartListening = false;
      textInput = '';
      isMicLoading = false;
      isLoading = false;
      isCanSpeak = false;
      isSpeaking = false;
      local = 'en-US';
      speechToText.stop();
      flutterTts.stop();
    });
  }


  void scrollToBottom() async {
    if(scrollController.hasClients) {
      await scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: (isSpeaking) ? const Duration(milliseconds: 1800) : const Duration(seconds: 1),
          curve: Curves.easeInOut);
    }
  }



  @override
  void initState() {
    if(CheckCubit.get(context).hasInternet) {
      AppCubit.get(context).getProfile();
    }
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    msgController.addListener(() {
      setState(() {});
    });
    focusNode.addListener(() {
      if(focusNode.hasPrimaryFocus) {
        setState(() {
          isHasFocus = true;
        });
      } else {
        Future.delayed(const Duration(milliseconds: 200)).then((value) {
          setState(() {
            isHasFocus = false;
          });
        });
      }
    });
    nameController.addListener(() {
      setState(() {});
    });

    if(!ThemeCubit.get(context).isDarkTheme) {
      animationController.animateTo(0.65);
    }

    if(isIOS) {
      tts();
    }
    super.initState();
  }


  @override
  void dispose() {
    animationController.dispose();
    speechToText.stop();
    flutterTts.stop();
    scrollController.dispose();
    msgController.dispose();
    nameController.dispose();
    focusNode.dispose();
    focusNode2.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final DateTime timeBackPressed = DateTime.now();
    return Builder(
      builder: (context) {
        final ThemeData theme = Theme.of(context);
        final bool isDark = theme.brightness == Brightness.dark;

        if(CheckCubit.get(context).hasInternet) {
          AppCubit.get(context).getChats();
        }

        return BlocConsumer<CheckCubit, CheckStates>(
          listener: (context, state) {},
          builder: (context, state) {

            var checkCubit = CheckCubit.get(context);

            return BlocConsumer<ThemeCubit, ThemeStates>(
              listener: (context, state) {

                if(state is SuccessCheckState) {
                  if(!CheckCubit.get(context).hasInternet) {
                    resetSettings();
                  }
                }

              },
              builder: (context, state) {

                var themeCubit = ThemeCubit.get(context);

                return BlocConsumer<AppCubit, AppStates>(
                  listener: (context, state) {

                    var cubit = AppCubit.get(context);

                    if(state is SuccessGetMessagesAppState) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        scrollToBottom();
                      });
                    }

                    if(state is SuccessAddAiMessageAppState) {
                      setState(() {
                        isLoading = false;
                        isVisible = false;
                        isVocalVisible = true;
                        if(isMicActive) {
                          isMicLoading = false;
                          textInput = '';
                        }
                      });
                      if(isCanSpeak) {
                         aiSpeak(cubit.messages[cubit.messages.length - 1]['message'], local);
                      }
                    }

                    if(state is ErrorSendMessageAppState ||
                        state is ErrorPostMessageAppState ||
                        state is ErrorUploadAndGetImageUrlAppState ||
                        state is ErrorGetImageDownloadUrlAppState ||
                        state is ErrorGetImageUrlEncodedAppState) {

                      showFlutterToast(
                          message: 'Error, may be on server try again later',
                          state: ToastStates.error,
                          context: context,
                          duration: 4,
                      );

                      if(checkCubit.hasInternet) {
                          cubit.removeMessage(
                            idChat: cubit.groupedIdChats.values.
                            elementAt(cubit.globalIndex ?? 0)[cubit.currentIndex ?? 0],
                            idMessage: cubit.idMessages[cubit.idMessages.length - 1]);
                          Future.delayed(const Duration(milliseconds: 600)).then((value) {
                            if(cubit.messages.isEmpty) {
                              setState(() {
                                isChatEmpty = true;
                              });
                              cubit.clearIndexing();
                              cubit.removeChat(idChat: cubit.groupedIdChats.values.
                              elementAt(0)[0]);
                            }
                          });
                      }

                      setState(() {
                        isLoading = false;
                        isVisible = false;
                        isVocalVisible = true;
                        if(isMicActive) {
                          isMicLoading = false;
                          textInput = '';
                        }
                      });
                    }

                    if(state is SuccessGetImageAppState || state is ErrorGetImageAppState) {
                      Navigator.pop(context);
                    }


                    if(state is SuccessRenameChatAppState) {
                      showFlutterToast(
                          message: 'Done with success',
                          state: ToastStates.success,
                          context: context);
                    }

                    if(state is SuccessRemoveChatAppState) {
                      if(!isChatEmpty) {
                        showFlutterToast(
                            message: 'Done with success',
                            state: ToastStates.success,
                            context: context);
                        if(cubit.messages.isEmpty && (cubit.currentIndex != null)) {
                          int index = cubit.currentIndex!;
                          if(cubit.groupedIdChats.values.elementAt(cubit.globalIndex!).length >= index+1) {
                            cubit.getMessages(idChat: cubit.groupedIdChats.values
                                .elementAt(cubit.globalIndex!)[cubit.currentIndex!]);
                          }
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    }

                    if(state is ErrorRenameChatAppState) {
                      showFlutterToast(
                          message: '${state.error}',
                          state: ToastStates.success,
                          context: context);
                    }

                    if(state is ErrorRemoveChatAppState) {
                      showFlutterToast(
                          message: '${state.error}',
                          state: ToastStates.success,
                          context: context);
                      Navigator.pop(context);
                    }


                    if(state is SuccessSignOutAppState) {
                      Future.delayed(const Duration(milliseconds: 1200)).then((value) {
                        CacheHelper.removeData(key: 'uId').then((value) {
                          if(value == true) {
                            Navigator.pop(context);
                            navigateAndNotReturn(context: context, screen: const AuthOptionsScreen());
                            Future.delayed(const Duration(milliseconds: 500)).then((value) {
                              cubit.clearMessages();
                              cubit.clearChats();
                              cubit.clearIndexing();
                            });
                          }
                        });
                      });
                    }

                    if(state is ErrorSignOutAppState) {
                      showFlutterToast(
                          message: '${state.error}',
                          state: ToastStates.error,
                          context: context);
                      Navigator.pop(context);
                    }

                  },
                  builder: (context, state) {

                    var cubit = AppCubit.get(context);

                    return GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          scaffoldKey.currentState?.openDrawer();
                        }
                      },
                      child: PopScope(
                        canPop: canExit,
                        onPopInvoked: (v) {
                          exit(timeBackPressed);
                        },
                        child: Scaffold(
                          key: scaffoldKey,
                          drawer: drawer(isDark, cubit.userModel, state),
                          appBar: AppBar(
                            centerTitle: true,
                            elevation: 0.0,
                            scrolledUnderElevation: 0.0,
                            clipBehavior: Clip.antiAlias,
                            title: FadeIn(
                              duration: const Duration(milliseconds: 400),
                              child: Text(
                                'ChatAI',
                                style: TextStyle(
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            actions: [
                              if(cubit.messages.isNotEmpty)
                              FadeIn(
                                duration: const Duration(milliseconds: 300),
                                child: IconButton(
                                    tooltip: 'New Chat',
                                    enableFeedback: true,
                                    onPressed: () {
                                      if(CheckCubit.get(context).hasInternet) {
                                        AppCubit.get(context).clearIndexing();
                                        AppCubit.get(context).clearMessages();
                                      } else {
                                        showFlutterToast(
                                            message: 'No Internet Connection',
                                            state: ToastStates.error,
                                            context: context);
                                      }

                                    },
                                    icon: Icon(
                                      EvaIcons.plusSquareOutline,
                                      size: 30.0,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                ),
                              ),
                              const SizedBox(
                                width: 2.0,
                              ),
                            ],
                            systemOverlayStyle: SystemUiOverlayStyle(
                              statusBarColor: Theme.of(context).scaffoldBackgroundColor,
                              statusBarIconBrightness: themeCubit.isDarkTheme ? Brightness.light : Brightness.dark,
                              systemNavigationBarColor: themeCubit.isDarkTheme
                                  ? firstColor
                                  : secondColor,
                            ),
                          ),
                          body: Form(
                            key: formKey,
                            child: Column(
                              children: [
                                Expanded(
                                  child: ConditionalBuilder(
                                    condition: cubit.messages.isNotEmpty,
                                    builder: (context) => Padding(
                                      padding: const EdgeInsets.fromLTRB(14.0, 8.0, 14.0, 0.0),
                                      child: ListView.separated(
                                        controller: scrollController,
                                        itemBuilder: (context, index) => buildItemMessage(cubit.messages[index], index),
                                        separatorBuilder: (context, index) => const SizedBox(
                                          height: 20.0,
                                        ),
                                        itemCount: cubit.messages.length,
                                      ),
                                    ),
                                    fallback: (context) => (checkCubit.hasInternet) ?
                                    Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        children: [
                                          if((!isHasFocus && cubit.image == null) &&
                                              (!isLoading && !isMicLoading)) ...[
                                            ZoomIn(
                                              duration: const Duration(milliseconds: 400),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Image.asset(
                                                  'assets/images/logo.png',
                                                  width: 90.0,
                                                  height: 90.0,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 35.0,
                                            ),
                                            FadeInRight(
                                              duration: const Duration(milliseconds: 400),
                                              child: Text(
                                                'Hello, ${(cubit.userModel != null) ?
                                                (cubit.userModel!.fullName!.contains(' ') ?
                                                cubit.userModel?.fullName?.split(' ')[0] : cubit.userModel?.fullName)
                                                    : '...'}',
                                                style: const TextStyle(
                                                  fontSize: 24.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 12.0,
                                            ),
                                            FadeInRight(
                                              duration: const Duration(milliseconds: 400),
                                              child: const Text(
                                                'Tell me what\'s on your mind.',
                                                style: TextStyle(
                                                  fontSize: 19.0,
                                                ),
                                              ),
                                            ),
                                          ]
                                          else if(cubit.messages.isEmpty) ...[
                                            FadeIn(
                                              duration: const Duration(milliseconds: 300),
                                              child: const Center(
                                                child: Text(
                                                  'Waiting for your message ...',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    letterSpacing: 0.6,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ) :
                                    FadeIn(
                                      duration: const Duration(milliseconds: 400),
                                      child: const Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'No Internet',
                                              style: TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 4.0,
                                            ),
                                            Icon(
                                              EvaIcons.wifiOffOutline,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8.0,
                                ),
                                Material(
                                  elevation: 30.0,
                                  clipBehavior: Clip.antiAlias,
                                  color: themeCubit.isDarkTheme
                                      ? firstColor
                                      : secondColor,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 20.0,
                                    ),
                                    child: Column(
                                      children: [
                                        if(cubit.image != null) ...[
                                          FadeInDown(
                                            duration: const Duration(milliseconds: 300),
                                            child: buildImageUpload(cubit, themeCubit),
                                          ),
                                          const SizedBox(
                                            height: 10.0,
                                          ),
                                        ],
                                        Row(
                                          children: [
                                            if(cubit.image == null && !isLoading
                                                && !isMicLoading && !isStartListening && checkCubit.hasInternet)
                                            FadeInLeft(
                                              duration: const Duration(milliseconds: 100),
                                              child: defaultIconButton(
                                                toolTip: 'Add image',
                                                elevation: 2.0,
                                                radius1: 50.0,
                                                radius2: 20.0,
                                                function: () async {
                                                   await showOptionsForUploadingImage();
                                                },
                                                padding: 8.0,
                                                icon: Icons.add_photo_alternate_outlined,
                                                color: themeCubit.isDarkTheme ?
                                                Colors.grey.shade700.withOpacity(.7) : Colors.white,
                                                colorIcon: themeCubit.isDarkTheme ?
                                                Colors.white : Colors.black,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10.0,
                                            ),
                                            Expanded(
                                              child: (!isMicActive) ?
                                              TextFormField(
                                                controller: msgController,
                                                keyboardType: TextInputType.multiline,
                                                maxLines: null,
                                                textCapitalization: TextCapitalization.sentences,
                                                focusNode: focusNode,
                                                style: const TextStyle(
                                                  letterSpacing: 0.6,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: 'Type ...',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(14.0),
                                                    borderSide: const BorderSide(
                                                      width: 2.0,
                                                    ),
                                                  ),
                                                  constraints: BoxConstraints(
                                                    maxHeight: MediaQuery.of(context).size.height / 4.5,
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  if(checkCubit.hasInternet) {
                                                    if(value.isNotEmpty && value.trim().isNotEmpty) {
                                                      if(!formKey.currentState!.validate()) {
                                                        setState(() {
                                                          isVisible = false;
                                                          isVocalVisible = false;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          isVisible = true;
                                                          isVocalVisible = false;
                                                        });
                                                      }
                                                    } else {
                                                      setState(() {
                                                        isVisible = false;
                                                        isVocalVisible = true;
                                                      });
                                                    }
                                                  }
                                                },
                                                validator: (value) {
                                                  if(value != null && value.length > 10000) {
                                                    return 'Text is too large';
                                                  }
                                                  return null;
                                                },
                                              ) :
                                              Center(
                                                child: ConditionalBuilder(
                                                  condition: !isMicLoading,
                                                  builder: (context) =>
                                                  FadeIn(
                                                    duration: const Duration(milliseconds: 200),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        if(checkCubit.hasInternet) {
                                                          await vocalConfig(local);
                                                        } else {
                                                         showFlutterToast(
                                                             message: 'No Internet Connection',
                                                             state: ToastStates.error,
                                                             context: context);
                                                        }
                                                      },
                                                      child: AvatarGlow(
                                                        startDelay: const Duration(milliseconds: 650),
                                                        duration: const Duration(milliseconds: 1300),
                                                        glowRadiusFactor: 2.5,
                                                        glowColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                                                        glowShape: BoxShape.circle,
                                                        animate: isStartListening,
                                                        curve: Curves.fastOutSlowIn,
                                                        glowCount: 2,
                                                        repeat: true,
                                                        child: CircleAvatar(
                                                          radius: 40.0,
                                                          backgroundColor: (!isStartListening) ? (themeCubit.isDarkTheme ?
                                                          Colors.grey.shade300 : Colors.black54.withOpacity(.1)) :
                                                          Theme.of(context).colorScheme.primary,
                                                          child: CircleAvatar(
                                                            radius: 36.0,
                                                            child: Icon(
                                                              (!isStartListening) ? EvaIcons.micOffOutline : EvaIcons.micOutline,
                                                              size: (!isStartListening) ? 28.0 : 30.0,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  fallback: (context) => FadeIn(
                                                      duration: const Duration(milliseconds: 200),
                                                      child: LoadingIndicator(os: getOs())),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 10.0,
                                            ),
                                            ConditionalBuilder(
                                              condition: !isLoading,
                                              builder: (context) => Visibility(
                                                visible: isVisible,
                                                child: FadeIn(
                                                  duration: const Duration(milliseconds: 100),
                                                  child: Tooltip(
                                                    message: 'Send',
                                                    enableFeedback: true,
                                                    child: InkWell(
                                                      borderRadius: BorderRadius.circular(20.0),
                                                      onTap: () async {
                                                        focusNode.unfocus();
                                                        if(checkCubit.hasInternet) {
                                                          String message = msgController.text;
                                                          msgController.clear();
                                                          setState(() {
                                                            isLoading = true;
                                                          });
                                                          if(cubit.image != null) {
                                                            await Future.delayed(const Duration(milliseconds: 200)).then((value) {
                                                              cubit.clearImage();
                                                            });
                                                          }
                                                          await cubit.sendMessage(
                                                            message: message,
                                                            dateTime: DateTime.now().toString(),
                                                            timesTamp: Timestamp.now(),
                                                            idChat: (cubit.chats.isNotEmpty) ?
                                                            cubit.groupedIdChats.values.
                                                            elementAt(cubit.globalIndex ?? 0)[cubit.currentIndex ?? 0] :
                                                            null,
                                                          );
                                                        } else {
                                                          showFlutterToast(
                                                              message: 'No Internet Connection',
                                                              state: ToastStates.error,
                                                              context: context);
                                                        }

                                                      },
                                                      child: Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: Icon(
                                                          Icons.send_rounded,
                                                          color: Theme.of(context).colorScheme.primary,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              fallback: (context) => FadeInRight(
                                                duration: const Duration(milliseconds: 100),
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 4.0,
                                                  ),
                                                  child: LoadingIndicatorKit(os: getOs()),
                                                ),
                                              ),
                                            ),
                                            if(!isLoading && !isMicLoading &&
                                                !isStartListening && checkCubit.hasInternet)
                                              Visibility(
                                                visible: isVocalVisible,
                                                child: FadeInRight(
                                                  duration: const Duration(milliseconds: 100),
                                                  child: defaultIconButton(
                                                      toolTip: (!isMicActive) ? 'Mic' : 'Close',
                                                      elevation: 2.0,
                                                      radius1: 50.0,
                                                      radius2: 20.0,
                                                      function: () {
                                                        if(!isMicActive) {
                                                          Future.delayed(const Duration(milliseconds: 300))
                                                              .then((value) async {
                                                            await speakConfirmation();
                                                          });
                                                        } else {
                                                          setState(() {
                                                            isCanSpeak = false;
                                                            if(isSpeaking) {
                                                              isSpeaking = false;
                                                              flutterTts.stop();
                                                            }
                                                          });
                                                        }
                                                        setState(() {
                                                          isMicActive = !isMicActive;
                                                        });
                                                      },
                                                      padding: 8.0,
                                                      icon: (!isMicActive) ? EvaIcons.micOutline :
                                                      Icons.close_rounded,
                                                      color: themeCubit.isDarkTheme ?
                                                      Colors.grey.shade700.withOpacity(.7) : Colors.white,
                                                      colorIcon: themeCubit.isDarkTheme ?
                                                      Colors.white : Colors.black,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      }
    );
  }

  // Upload Images From Device
  Widget buildImageUpload(cubit, themeCubit) => SizedBox(
    width: 155.0,
    height: 125.0,
    child: Stack(
      alignment: Alignment.topRight,
      children: [
        Align(
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.file(File(cubit.image!.path),
              width: 100.0,
              height: 100.0,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if(frame == null) {
                  return Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0,),
                        color: Colors.blue.shade800,
                      ),
                      clipBehavior: Clip.antiAlias,
                  );
                }
                return FadeIn(
                  duration: const Duration(milliseconds: 300),
                  child: child,
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0,),
                    color: Colors.blue.shade800,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 24.0,
                      color: themeCubit.isDarkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        defaultIconButton(
          toolTip: 'Remove',
          elevation: 2.0,
          radius1: 20.0,
          radius2: 20.0,
          padding: 3.0,
          function: () {
            cubit.clearImage(isClearAll: true);
          },
          icon: Icons.close_rounded,
          color: themeCubit.isDarkTheme ?
          Colors.grey.shade700.withOpacity(.7) : Colors.white,
          colorIcon: themeCubit.isDarkTheme ?
          Colors.white : Colors.black,),
      ],
    ),
  );

  Future<dynamic> showOptionsForUploadingImage() => showModalBottomSheet(
    showDragHandle: true,
    clipBehavior: Clip.antiAlias,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
          child: Wrap(
            clipBehavior: Clip.antiAlias,
            children: [
              ListTile(
                enableFeedback: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onTap: () async {
                  await AppCubit.get(context).getImage(ImageSource.camera);
                },
                leading: Icon(
                  Icons.camera_alt_rounded,
                  color: ThemeCubit.get(context).isDarkTheme ? Colors.white : Colors.black,
                ),
                title: const Text(
                  'Camera',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                enableFeedback: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onTap: () async {
                  await AppCubit.get(context).getImage(ImageSource.gallery);
                },
                leading: Icon(
                  Icons.image_rounded,
                  color: ThemeCubit.get(context).isDarkTheme ? Colors.white : Colors.black,
                ),
                title: const Text(
                  'Gallery',
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



  // Drawer
  Widget drawer(isDark, UserModel? model, state) => Drawer(
    elevation: 10.0,
    clipBehavior: Clip.antiAlias,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SlideInLeft(
          duration: const Duration(milliseconds: 300),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 36.0,
                          backgroundColor: ThemeCubit.get(context).isDarkTheme ?
                          Colors.white : Colors.black,
                          child: CircleAvatar(
                            radius: 34.0,
                            backgroundImage: NetworkImage('${model?.imageProfile}'),
                          ),
                        ),
                        Material(
                          elevation: 2.0,
                          borderRadius: BorderRadius.circular(50.0),
                          clipBehavior: Clip.antiAlias,
                          color: ThemeCubit.get(context).isDarkTheme ? thirdColor : Colors.white,
                          child: IconButton(
                            onPressed: () {
                              ThemeCubit.get(context).changeTheme(!isDark);
                              if (!ThemeCubit.get(context).isDarkTheme) {
                                animationController.reset();
                                animationController.animateTo(0.65);
                              } else {
                                animationController.reverse();
                              }
                            },
                            icon: Lottie.asset(
                                Icons8.day_night_weather,
                                width: 30.0,
                                height: 30.0,
                                controller: animationController),
                            tooltip: 'Change Mode',
                            enableFeedback: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 14.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 2.0,
                      ),
                      child: Text(
                        model?.fullName ?? '...',
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 16.0,
                          overflow: TextOverflow.ellipsis,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Divider(
                  thickness: 0.6,
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Expanded(
                child: Column(
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if(CheckCubit.get(context).hasInternet) {
                                  if(AppCubit.get(context).messages.isNotEmpty) {
                                    AppCubit.get(context).clearIndexing();
                                    AppCubit.get(context).clearMessages();
                                    Future.delayed(const Duration(milliseconds: 100)).then((value) {
                                      scaffoldKey.currentState?.closeDrawer();
                                    });
                                  }
                                } else {
                                  showFlutterToast(
                                      message: 'No Internet Connection',
                                      state: ToastStates.error,
                                      context: context);
                                }
                              },
                              style: ButtonStyle(
                                shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                side: MaterialStatePropertyAll(
                                  BorderSide(
                                    width: 1.0,
                                    color: (AppCubit.get(context).messages.isEmpty) ?
                                    Theme.of(context).colorScheme.primary.withOpacity(.3) :
                                    Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                ),
                              icon: Icon(
                                EvaIcons.plusSquareOutline,
                                color: (AppCubit.get(context).messages.isEmpty) ?
                                Theme.of(context).colorScheme.primary.withOpacity(.3) : null,
                              ),
                              label: Text(
                                'New Chat',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: (AppCubit.get(context).messages.isEmpty) ?
                                  Theme.of(context).colorScheme.primary.withOpacity(.3) : null,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            defaultIconButton(
                                toolTip: 'Search',
                                elevation: 2.0,
                                radius1: 10.0,
                                radius2: 10.0,
                                padding: 8.0,
                                function: () {
                                  if(CheckCubit.get(context).hasInternet) {
                                    Future.delayed(const Duration(milliseconds: 100)).then((value) {
                                      scaffoldKey.currentState?.closeDrawer();
                                      Navigator.of(context).push(createSecondRoute(screen: const SearchChatScreen()));
                                    });
                                  } else {
                                    showFlutterToast(
                                        message: 'No Internet Connection',
                                        state: ToastStates.error,
                                        context: context);
                                  }
                                },
                                icon: EvaIcons.searchOutline,
                                color: Theme.of(context).colorScheme.primary.withOpacity(.9),
                                colorIcon: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 12.0,
                    ),
                    Expanded(
                      child: ConditionalBuilder(
                        condition: AppCubit.get(context).groupedChats.isNotEmpty,
                        builder: (context) => RefreshIndicator(
                              key: refreshIndicatorKey,
                              color: Theme.of(context).colorScheme.primary,
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              onRefresh: () async {
                                await Future.delayed(const Duration(seconds: 2)).then((value) {
                                  if(CheckCubit.get(context).hasInternet) {
                                    AppCubit.get(context).getChats();
                                  }
                                });
                              },
                              child: ListView.separated(
                                itemBuilder: (context, i) {
                                  String status = AppCubit.get(context).groupedChats.keys.elementAt(i);
                                  List<dynamic> chats = AppCubit.get(context).groupedChats.values.elementAt(i);
                                  List<String> idChats = AppCubit.get(context).groupedIdChats.values.elementAt(i);

                                  // Inner indexes
                                  Map<int, List<int>> listOfIndex = {
                                    i: List.generate(chats.length, (index) => index),
                                  };

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          SlideInLeft(
                                            duration: const Duration(milliseconds: 200),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 8.0,
                                              ),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                  color: ThemeCubit.get(context).isDarkTheme ?
                                                  Colors.grey.shade500 : Colors.grey.shade600,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                int actualIndex = listOfIndex[i]![index];
                                                return buildItemChat(chats[actualIndex], idChats[actualIndex],
                                                    i, actualIndex);
                                              },
                                              itemCount: chats.length),
                                        ],
                                      );
                                  },
                                separatorBuilder: (context, index) => const SizedBox(
                                  height: 24.0,
                                ),
                                itemCount: AppCubit.get(context).groupedChats.length,
                                ),
                            ),
                        fallback: (context) => (state is LoadingGetChatsAppState) ?
                        Center(child: LoadingIndicator(os: getOs())) :
                        const Center(
                          child: Text(
                            'There is no chats',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.0,
                ),
                child: Divider(
                  thickness: 0.6,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                ),
                child: ElevatedButton(
                  clipBehavior: Clip.antiAlias,
                  style: ButtonStyle(
                    side: MaterialStatePropertyAll(
                      BorderSide(
                        width: 1.5,
                        color: redColor,
                      ),
                    ),
                  ),
                  onPressed: () {
                    if(CheckCubit.get(context).hasInternet) {
                      showAlertSignOut(context);
                    } else {
                      showFlutterToast(
                          message: 'No Internet Connection',
                          state: ToastStates.error,
                          context: context);
                    }
                  },
                  child: Text(
                    'Sign Out',
                    style: TextStyle(
                      fontSize: 17.0,
                      color: redColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );


  dynamic showAlertSignOut(BuildContext context) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        HapticFeedback.vibrate();
        return FadeIn(
          duration: const Duration(milliseconds: 300),
          child: AlertDialog(
            title: const Text(
              'Do you want to sign out?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                letterSpacing: 0.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
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
                  Navigator.pop(dialogContext);
                  showLoading(context);
                  AppCubit.get(context).signOut();
                },
                child: Text(
                  'Yes',
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




  // Chats
  Widget buildItemChat(chat, idChat, gIndex, actualIndex) => Padding(
    padding: const EdgeInsets.symmetric(
      vertical: 8.0,
      horizontal: 4.0,
    ),
    child: SlideInLeft(
      duration: const Duration(milliseconds: 300),
      child: Container(
        decoration: BoxDecoration(
          color: ((AppCubit.get(context).globalIndex == gIndex) &&
              (AppCubit.get(context).currentIndex == actualIndex)) ?
          Theme.of(context).scaffoldBackgroundColor.withOpacity(.9) : null,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          onTap: () {
            if(CheckCubit.get(context).hasInternet) {
              AppCubit.get(context).changeIndexing(gIndex: gIndex, innerIndex: actualIndex);
              AppCubit.get(context).getMessages(idChat: idChat);
              Future.delayed(const Duration(milliseconds: 100)).then((value) {
                scaffoldKey.currentState?.closeDrawer();
              });
            } else {
              showFlutterToast(
                  message: 'No Internet Connection',
                  state: ToastStates.error,
                  context: context);
            }
          },
          onLongPress: () async {
            if(CheckCubit.get(context).hasInternet) {
              AppCubit.get(context).getMessages(idChat: idChat, isRemoving: true);
              await showOptionsForChat(idChat: idChat, chatName: chat['name'],);
            } else {
              showFlutterToast(
                  message: 'No Internet Connection',
                  state: ToastStates.error,
                  context: context);
            }
          },
          selected: ((AppCubit.get(context).globalIndex == gIndex) &&
              (AppCubit.get(context).currentIndex == actualIndex)) ? true : false,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          enableFeedback: true,
          leading: const Icon(
            EvaIcons.chevronRightOutline,
          ),
          title: Text(
            '${chat['name']}',
            maxLines: 1,
            style: const TextStyle(
              fontSize: 15.0,
              letterSpacing: 0.6,
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );


  Future<dynamic> showOptionsForChat({
    required String idChat,
    required String chatName,
  }) => showModalBottomSheet(
    showDragHandle: true,
    clipBehavior: Clip.antiAlias,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
          child: Wrap(
            clipBehavior: Clip.antiAlias,
            children: [
              ListTile(
                enableFeedback: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onTap: () {
                  showAlertRename(context, idChat, chatName);
                },
                leading: Icon(
                  EvaIcons.editOutline,
                  color: greenColor,
                ),
                title: Text(
                  'Rename',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: greenColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                enableFeedback: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                onTap: () {
                  setState(() {
                    isChatEmpty = false;
                  });
                  showAlertRemove(context, idChat);
                },
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: redColor,
                ),
                title: Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: redColor,
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


  dynamic showAlertRename(BuildContext context, idChat, chatName) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        HapticFeedback.vibrate();
        nameController.text = chatName;
        return FadeIn(
          duration: const Duration(milliseconds: 300),
          child: Form(
            key: anotherFormKey,
            child: AlertDialog(
              clipBehavior: Clip.antiAlias,
              title: TextFormField(
                controller: nameController,
                focusNode: focusNode2,
                keyboardType: TextInputType.text,
                maxLength: 30,
                clipBehavior: Clip.antiAlias,
                decoration: InputDecoration(
                  hintText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.0),
                    borderSide: const BorderSide(
                      width: 2.0,
                    ),
                  ),
                  prefixIcon: const Icon(
                      EvaIcons.editOutline
                  ),
                ),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return 'Chat name must not be empty';
                  }
                  if(value.length > 30) {
                    return 'Name too large';
                  }
                  return null;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FadeIn(
                  duration: const Duration(milliseconds: 100),
                  child: TextButton(
                    onPressed: () {
                      focusNode.unfocus();
                      if(CheckCubit.get(context).hasInternet) {
                        if(anotherFormKey.currentState!.validate()) {
                          String name = nameController.text;
                          AppCubit.get(context).renameChat(idChat: idChat, name: name);
                          Navigator.pop(dialogContext);
                          Navigator.pop(context);
                          nameController.clear();
                        }
                      } else {
                        showFlutterToast(
                            message: 'No Internet Connection',
                            state: ToastStates.error,
                            context: context);
                      }
                    },
                    child: Text(
                      'Rename',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: greenColor,
                        fontWeight: FontWeight.bold,
                      ),
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


  dynamic showAlertRemove(BuildContext context, idChat) {
    return showDialog(
      context: context,
      builder: (dialogContext) {
        HapticFeedback.vibrate();
        return FadeIn(
          duration: const Duration(milliseconds: 300),
          child: AlertDialog(
            clipBehavior: Clip.antiAlias,
            title: Text(
              'Do you want to remove this chat?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                color: redColor.withOpacity(.9),
                letterSpacing: 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
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
                  if(CheckCubit.get(context).hasInternet) {
                    AppCubit.get(context).removeChat(idChat: idChat);
                    Navigator.pop(dialogContext);
                    showLoading(context);
                  } else {
                    Navigator.pop(dialogContext);
                    showFlutterToast(
                        message: 'No Internet Connection',
                        state: ToastStates.error,
                        context: context);
                  }
                },
                child: Text(
                  'Yes',
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





  // Messages
  Widget buildItemMessage(msg, index) => Align(
    alignment: (msg['is_user']) ? Alignment.centerRight: Alignment.centerLeft,
    child: (msg['is_user']) ?
    FadeInRight(
      duration: const Duration(milliseconds: 150),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).colorScheme.primary,
        ),
        clipBehavior: Clip.antiAlias,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width.toInt() / 1.3,
        ),
        child: (msg['image_url'] == '' || msg['image_url'] == null) ?
        Text(
          '${msg['message']}',
          style: const TextStyle(
            fontSize: 15.0,
            color: Colors.white,
            letterSpacing: 0.6,
            fontWeight: FontWeight.bold,
          ),
        ) :
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                showFullImage(msg['image_url']);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  '${msg['image_url']}',
                  width: 150.0,
                  height: 150.0,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                    if(frame == null) {
                      return Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0,),
                            color: Colors.blue.shade800,
                          ),
                          clipBehavior: Clip.antiAlias,
                      );
                    }
                    return FadeIn(
                        duration: const Duration(milliseconds: 300),
                        child: child);
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 150.0,
                      height: 150.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0,),
                        color: Colors.blue.shade800,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: const Center(
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 30.0,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Text(
              '${msg['message']}',
              style: const TextStyle(
                fontSize: 15.0,
                color: Colors.white,
                letterSpacing: 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ) :
    FadeInLeft(
      duration: const Duration(milliseconds: 150),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            width: 1.5,
            color: ThemeCubit.get(context).isDarkTheme ? Colors.white : Colors.black,
          ),
          color: ThemeCubit.get(context).isDarkTheme ? HexColor('303030').withOpacity(.8) : Colors.grey.shade200,
        ),
        clipBehavior: Clip.antiAlias,
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width.toInt() / 1.3,
        ),
        child: Text.rich(
            TextSpan(
              style: const TextStyle(
                fontFamily: 'Varela',
                fontSize: 15.0,
                letterSpacing: 0.6,
                fontWeight: FontWeight.bold,
              ),
              children: buildTextSpans(msg['message']),
            )),
      ),
    ),
  );



  List<TextSpan> buildTextSpans(String inputText) {
    final RegExp urlRegex = RegExp(
      r'\b(?:https?|ftp)://[\w\-?=%.]+\.[a-zA-Z]{2,}(?:/\S*)?\b',
      caseSensitive: false,
    );

    // final RegExp titleRegex = RegExp(
    //   r'\* \w+\.\w+:',
    //   caseSensitive: false,
    // );

    List<TextSpan> spans = [];
    int previousEnd = 0;

    Iterable<Match> urlMatches = urlRegex.allMatches(inputText);
    // Iterable<Match> titleMatches = titleRegex.allMatches(inputText);

    for (Match match in urlMatches) {
      if (match.start > previousEnd) {
        spans.add(
          TextSpan(
            text: inputText.substring(previousEnd, match.start),
            style: TextStyle(
              color: ThemeCubit.get(context).isDarkTheme
                  ? Colors.white
                  : Colors.black,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              if(CheckCubit.get(context).hasInternet) {
                await HapticFeedback.vibrate();
                String url = match.group(0) ?? '';
                if(!url.contains('https') || !url.contains('http')) {
                  url = 'https://${match.group(0)}';
                }
                await lunch(url).then((value) {
                  showFlutterToast(
                      message: 'Opening ...',
                      state: ToastStates.success,
                      context: context);
                }).catchError((error) {
                  showFlutterToast(
                      message: error.toString(),
                      state: ToastStates.error,
                      context: context);
                });
              } else {
                showFlutterToast(
                    message: 'No Internet Connection',
                    state: ToastStates.error,
                    context: context);
              }
            },
        ),
      );
      previousEnd = match.end;
    }

    // for (Match match in titleMatches) {
    //   if (match.start > previousEnd) {
    //     spans.add(
    //       TextSpan(
    //         text: inputText.substring(previousEnd, match.start),
    //         style: TextStyle(
    //           color: ThemeCubit.get(context).isDarkTheme
    //               ? Colors.white
    //               : Colors.black,
    //         ),
    //       ),
    //     );
    //   }
    //   spans.add(
    //     TextSpan(
    //       text: match.group(0),
    //       style: TextStyle(
    //         color: greenColor,
    //       ),
    //     ),
    //   );
    //   previousEnd = match.end;
    // }

    if (previousEnd < inputText.length) {
      spans.add(
        TextSpan(
          text: inputText.substring(previousEnd, inputText.length),
          style: TextStyle(
            color: ThemeCubit.get(context).isDarkTheme
                ? Colors.white
                : Colors.black,
          ),
        ),
      );
    }

    return spans;
  }




  Future<void> lunch(String url) async {
    final Uri baseUrl = Uri.parse(url);
    if (await canLaunchUrl(baseUrl)) {
      await launchUrl(baseUrl, mode: LaunchMode.externalApplication);
    }
  }





  // Vocal Config
  Future<dynamic> langConfig() => showModalBottomSheet(
    showDragHandle: true,
    isDismissible: false,
    enableDrag: false,
    clipBehavior: Clip.antiAlias,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
         padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'Which lang do you want to use : \n',
                  children: [
                    const TextSpan(
                        text: 'Default is  ',
                    ),
                    TextSpan(
                      text: 'English',
                      style: TextStyle(
                        color: greenColor,
                        height: 2.0,
                      )
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 17.0,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () {
                        setState(() {
                          local = 'ar-DZ';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Arabic',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          local = 'en-US';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'English',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          local = 'fr-FR';
                        });
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'French',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );


  Future<dynamic> speakConfirmation() => showModalBottomSheet(
    showDragHandle: true,
    isDismissible: false,
    enableDrag: false,
    clipBehavior: Clip.antiAlias,
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Padding(
         padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text.rich(
                textAlign: TextAlign.center,
                TextSpan(
                  text: 'Do you want ',
                  children: [
                    TextSpan(
                      text: 'ChatAI ',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ),
                    const TextSpan(
                      text: 'speak with you?',
                    ),
                  ],
                  style: const TextStyle(
                    fontSize: 17.0,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                      onPressed: () async {
                        setState(() {
                          isCanSpeak = false;
                        });
                        Navigator.pop(context);
                        await langConfig();
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
                      onPressed: () async {
                        setState(() {
                          isCanSpeak = true;
                        });
                        Navigator.pop(context);
                        await langConfig();
                      },
                      child: Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: greenColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );


  dynamic showFullImage(String imageUrl) =>
       Navigator.of(context).push(createSecondRoute(screen: Scaffold(
         body: SafeArea(
           child: SlideInRight(
             duration: const Duration(seconds: 1),
             child: GestureDetector(
               onTap: () {
                 Navigator.pop(context);
               },
               child: InteractiveViewer(
                 child: Image.network(imageUrl,
                   width: MediaQuery.of(context).size.width,
                   height: MediaQuery.of(context).size.height,
                   fit: BoxFit.fitWidth,
                   frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                     if(frame == null) {
                       return SizedBox(
                         width: MediaQuery.of(context).size.width,
                         height: MediaQuery.of(context).size.height,
                         child: Center(child: LoadingIndicator(os: getOs())),
                       );
                     }
                     return child;
                   },
                   errorBuilder: (context, error, stackTrace) {
                     return SizedBox(
                       width: MediaQuery.of(context).size.width,
                       height: MediaQuery.of(context).size.height,
                       child: Center(
                         child: Icon(
                           Icons.error_outline_rounded,
                           size: 46.0,
                           color: ThemeCubit.get(context).isDarkTheme ? Colors.white : Colors.black,
                         ),
                       ),
                     );
                   },
                 ),
               ),
             ),
           ),
         ),
       ),));
}
