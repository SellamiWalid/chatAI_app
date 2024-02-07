abstract class ForgotPassStates {}

class InitialForgotPassState extends ForgotPassStates {}

class LoadingForgotPassState extends ForgotPassStates {}

class SuccessForgotPassState extends ForgotPassStates {}

class ErrorForgotPassState extends ForgotPassStates {

  dynamic error;
  ErrorForgotPassState(this.error);

}