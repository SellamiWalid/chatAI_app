import 'package:chat_ai/data/models/userModel/UserModel.dart';

abstract class SignInStates {}

class InitialSignInState extends SignInStates {}


// Sign in with email

class LoadingSignInState extends SignInStates {}

class SuccessSignInState extends SignInStates {

  final String userId;
  final bool isEmailVerified;

  SuccessSignInState(this.userId, this.isEmailVerified);

}

class ErrorSignInState extends SignInStates {

  dynamic error;
  ErrorSignInState(this.error);

}



// Sign in with google

class LoadingGoogleSignInState extends SignInStates {}

class SuccessGoogleSignInState extends SignInStates {

  final String userId;
  SuccessGoogleSignInState(this.userId);

}

class ErrorGoogleSignInState extends SignInStates {

  dynamic error;
  ErrorGoogleSignInState(this.error);

}

class SuccessCreateAccountGoogleSignInState extends SignInStates {

  final UserModel userModel;
  SuccessCreateAccountGoogleSignInState(this.userModel);

}

class ErrorCreateAccountGoogleSignInState extends SignInStates {

  dynamic error;
  ErrorCreateAccountGoogleSignInState(this.error);

}