
import 'package:chat_ai/shared/cubits/forgetPassCubit/ForgotPassStates.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPassCubit extends Cubit<ForgotPassStates> {

  ForgotPassCubit() : super(InitialForgotPassState());

  static ForgotPassCubit get(context) => BlocProvider.of(context);


  void restPassword({
    required String email,
}) {

    emit(LoadingForgotPassState());

    FirebaseAuth.instance.sendPasswordResetEmail(email: email).then((value) {

      emit(SuccessForgotPassState());

    }).catchError((error) {

      if(kDebugMode) {
        print('${error.toString()} --> in reset password');
      }

      emit(ErrorForgotPassState(error));

    });


  }

}