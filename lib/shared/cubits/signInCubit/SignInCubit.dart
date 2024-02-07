import 'package:chat_ai/data/models/userModel/UserModel.dart';
import 'package:chat_ai/shared/components/Components.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/cubits/signInCubit/SignInStates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignInCubit extends Cubit<SignInStates> {

  SignInCubit() : super(InitialSignInState());

  static SignInCubit get(context) => BlocProvider.of(context);


  void userSignIn({
    required String email,
    required String password,
}) async {

    emit(LoadingSignInState());

    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password).then((value) async {

          var deviceToken = await getDeviceToken();

          await FirebaseFirestore.instance.collection('users').doc(value.user!.uid).update({
            'device_token': deviceToken,
          });

          emit(SuccessSignInState(value.user!.uid, value.user!.emailVerified));

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in sign in with email');
      }

      emit(ErrorSignInState(error));
    });


  }


  void signInWithGoogle(context) async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    if(kDebugMode) {
      if(googleAuth == null) {
        showFlutterToast(message: 'Error', state: ToastStates.error, context: context);
        Navigator.pop(context);
      }
    }

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) async {

      await FirebaseFirestore.instance.collection('users').doc(value.user!.uid).get().then((v) async {

        if(v.data() == null) {

          createGoogleAccount(
              uId: value.user?.uid,
              fullName: value.user?.displayName,
              email: value.user?.email,
              imageProfile: value.user?.photoURL,
          );

        } else {

          var deviceToken = await getDeviceToken();

          await FirebaseFirestore.instance.collection('users').doc(value.user!.uid).update({
            'device_token': deviceToken,
          });
          
          emit(SuccessGoogleSignInState(value.user!.uid));

        }
        
      });
    }).catchError((error) {
      
      if(kDebugMode) {
        print('${error.toString()} --> in google sign in');
      }
      
      emit(ErrorGoogleSignInState(error));
    });
  }


  void createGoogleAccount({
    required String? uId,
    required String? fullName,
    required String? email,
    required String? imageProfile,
}) async {

    var deviceToken = await getDeviceToken();

    UserModel model = UserModel(
      uId: uId,
      fullName: fullName,
      email: email,
      imageProfile: imageProfile ?? profile,
      isEmailVerified: true,
      isGoogleSgnIn: true,
      deviceToken: deviceToken,
    );

    await FirebaseFirestore.instance.collection('users').doc(uId).set(model.toMap()).then((value) {

      emit(SuccessCreateAccountGoogleSignInState(model));

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in create google account');
      }

      emit(ErrorCreateAccountGoogleSignInState(error));
    });

  }
}