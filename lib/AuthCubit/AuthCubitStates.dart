abstract class AuthCubitStates {}

class InitialState extends AuthCubitStates{}

class InvalidUser extends AuthCubitStates{}

class EmptyFieldsFoundState extends AuthCubitStates{}

class UserRegistered extends AuthCubitStates{}

class EmptyFieldRegistersState extends AuthCubitStates{}

class AccountAlreadyExists extends AuthCubitStates{}

class WeakPassword extends AuthCubitStates{}

class LoginIsStart extends AuthCubitStates{}

class LoadDataFromFirebase extends AuthCubitStates{}

class GetUserIDDate extends AuthCubitStates{}

class NoUserFound extends  AuthCubitStates{}

class PasswordVisibilityState extends AuthCubitStates{}

class TextVisibilityStateChanged extends AuthCubitStates{}