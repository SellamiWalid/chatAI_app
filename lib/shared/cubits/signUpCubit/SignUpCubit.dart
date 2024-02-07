import 'package:chat_ai/data/models/userModel/UserModel.dart';
import 'package:chat_ai/shared/components/Constants.dart';
import 'package:chat_ai/shared/cubits/signUpCubit/SignUpStates.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpCubit extends Cubit<SignUpStates> {

  SignUpCubit() : super(InitialSignUpState());

  static SignUpCubit get(context) => BlocProvider.of(context);


  void userSignUp({
    required String fullName,
    required String email,
    required String password,
}) async {

    emit(LoadingSignUpState());

    await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password).then((value) {

          createUserAccount(fullName: fullName, email: email, userId: value.user!.uid);

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in user sign up');
      }

      emit(ErrorSignUpState(error));

    });
  }

  void createUserAccount({
    required String fullName,
    required String email,
    required String userId,
}) async {

    var deviceToken = await getDeviceToken();

    UserModel model = UserModel(
      uId: userId,
      fullName: fullName,
      email: email,
      imageProfile: profile,
      isEmailVerified: false,
      isGoogleSgnIn: false,
      deviceToken: deviceToken,
    );

    await FirebaseFirestore.instance.collection('users').doc(userId).set(model.toMap()).then((value) {

      emit(SuccessCreateUserSignUpState(model));

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in create user account');
      }

      emit(ErrorCreateUserSignUpState(error));
    });

  }


  void sendEmailVerification() async {

    emit(LoadingSendEmailVerificationSignUpState());

    await FirebaseAuth.instance.currentUser?.sendEmailVerification().then((value) {

      emit(SuccessSendEmailVerificationSignUpState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in send email verification');
      }

      emit(ErrorSendEmailVerificationSignUpState(error));

    });

  }


  bool isVerified = false;


  void autoVerified() {

    FirebaseAuth.instance.authStateChanges().listen((event) {

      FirebaseAuth.instance.currentUser?.reload().then((value) {

      if(event?.emailVerified == true) {

        isVerified = true;

      } else {

        isVerified = false;

      }

       emit(SuccessAutoVerifiedEmailSignUpState());

      });

    });

  }


  void updateStatus({
    required String userId,
}) {

    FirebaseFirestore.instance.collection('users').doc(userId).update({
      'is_email_verified': true,
    }).then((value) {
      emit(SuccessUpdateStatusSignUpState());
    });

  }


  void removeAccount({
    required String userId,
}) {

    FirebaseAuth.instance.currentUser?.delete().then((value) {

      FirebaseFirestore.instance.collection('users').doc(userId).delete();

      emit(SuccessRemoveAccountSignUpState());

    }).catchError((error) {

      emit(ErrorRemoveAccountSignUpState());
    });

  }

}