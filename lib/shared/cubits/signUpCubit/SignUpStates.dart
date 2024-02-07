import 'package:chat_ai/data/models/userModel/UserModel.dart';

abstract class SignUpStates {}

class InitialSignUpState extends SignUpStates {}

class LoadingSignUpState extends SignUpStates {}

class ErrorSignUpState extends SignUpStates {

  dynamic error;
  ErrorSignUpState(this.error);

}

class SuccessCreateUserSignUpState extends SignUpStates {

  final UserModel userModel;
  SuccessCreateUserSignUpState(this.userModel);

}

class ErrorCreateUserSignUpState extends SignUpStates {

  dynamic error;
  ErrorCreateUserSignUpState(this.error);

}


class LoadingSendEmailVerificationSignUpState extends SignUpStates {}

class SuccessSendEmailVerificationSignUpState extends SignUpStates {}

class ErrorSendEmailVerificationSignUpState extends SignUpStates {

  dynamic error;
  ErrorSendEmailVerificationSignUpState(this.error);

}


class SuccessAutoVerifiedEmailSignUpState extends SignUpStates {}

class SuccessUpdateStatusSignUpState extends SignUpStates {}

class SuccessRemoveAccountSignUpState extends SignUpStates {}

class ErrorRemoveAccountSignUpState extends SignUpStates {}
