import 'package:chatapp/AuthCubit/AuthCubitStates.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/Network/local/SharedPreferencesStorage.dart';
import 'package:chatapp/Network/remote/FirebaseApi.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/Models/User.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthCubit extends Cubit<AuthCubitStates> {

  AuthCubit() : super(InitialState());

  static AuthCubit get(BuildContext context) => BlocProvider.of(context);

  UserAccount currentUser;
  bool isSecure=true;
  final picker = ImagePicker();
  XFile imageFile;
  Future capturePhoto({ImageSource imageSource})async{
      imageFile = await picker.pickImage(source: imageSource);
      emit(CapturedPhotoDone());
  }

  bool checkvalidatyofinputs(String username,String password){
    if(username == "" || password == ""){
      return false;
    }
    else{
      return true;
    }
  }

  Future<UserAccount>getUserAccountInformation(UserCredential userCredential)async{
    DocumentSnapshot querySnapshot = await FirebaseApiServices.getUserAccountData(userCredential);
    if(querySnapshot.data()!=null){
      return UserAccount.fromJson(querySnapshot.data());
    }
    else{
      return null;
    }
  }

  Future<void> loginWithUsernameAndPassword(String username, String password,ConversationsCubit conversationsCubit,ChatRoomCubit chatRoomCubit) async {
    emit(LoginIsStart());
    if (!checkvalidatyofinputs(username,password)) {
      emit(EmptyFieldsFoundState());
    }
    else {
      await tryLogin(username, password, conversationsCubit, chatRoomCubit);
    }
  }

  Future<void> tryLogin(String username, String password, ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit) async {
     UserCredential userCredential =await FirebaseApiServices.getUserCredentialFromFireBase(username,password);
    if(userCredential!=null){
      await loginSuccessful(userCredential, conversationsCubit, chatRoomCubit);
    }
    else{
      emit(InvalidUser());
    }
  }

  void resetTextVisibilityState(){
    isSecure = true;
    imageFile=null;
    emit(TextVisibilityStateChanged());
  }
  String deviceToken;

  Future<void> loginSuccessful(UserCredential userCredential, ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit) async {
    UserAccount newUser = await getUserAccountInformation(userCredential);
    deviceToken = SharedPreferencesStorage.getDeviceTokenFromSharedPreferences();
    await FirebaseFirestore.instance.collection("Tokens").where("token",isEqualTo: deviceToken).get().then((value) {
      value.docs.forEach((element) async {
        await FirebaseFirestore.instance.collection("Tokens").doc(element.id).delete();
      });
    });
    await FirebaseFirestore.instance.collection("Tokens").doc(newUser.id).set({"token":deviceToken});
    if(newUser!=null){
      currentUser=newUser;
      isSecure=true;
      chatRoomCubit.setCurrentUser(currentUser);
      conversationsCubit.setCurrentUser(newUser);
      emit(GetUserIDDate());
    }
    else{
      emit(NoUserFound());
    }
  }

  void changePasswordVisibilityState(){
    isSecure=!isSecure;
    emit(PasswordVisibilityState());
  }

  Future<UserAccount>createAccountInFireBaeAuthentication(TextEditingController username, TextEditingController password)async{
    UserCredential userCredential= await FirebaseApiServices.createUserInFirebase(username.text, password.text);
    String token =await FirebaseMessaging.instance.getToken();
    print(token);
    await FirebaseFirestore.instance.collection("Tokens").where("token",isEqualTo: token).get().then((value) {
      value.docs.forEach((element) async {
        print(element.data());
        await FirebaseFirestore.instance.collection("Tokens").doc(element.id).delete();
      });
    });
    await FirebaseFirestore.instance.collection("Tokens").doc(userCredential.user.uid).set({"token":token});
    return UserAccount(name: username.text, password: password.text, userType: 'user', id: userCredential.user.uid,token: token);
  }


  Future<void>createNewUser(UserAccount newUser,ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit)async{
    await FirebaseApiServices.createNewDocumentForNewUserInFirebase(newUser,imageFile);
    imageFile=null;
    currentUser=newUser;
    chatRoomCubit.setCurrentUser(currentUser);
    conversationsCubit.setCurrentUser(newUser);
    emit(UserRegistered());
  }

  Future<void>registerNewUser(TextEditingController username, TextEditingController password,ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit)async{
    try {
      emit(LoadDataFromFirebase());
      UserAccount newUser =await createAccountInFireBaeAuthentication(username,password);
      await createNewUser(newUser,conversationsCubit,chatRoomCubit);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(WeakPassword());
      }
      else if (e.code == 'email-already-in-use') {
        emit(AccountAlreadyExists());
      }
    } catch (e) {
      print(e);
    }
  }

  Future register(TextEditingController username, TextEditingController password,ConversationsCubit conversationsCubit, ChatRoomCubit chatRoomCubit) async {
    if (!checkvalidatyofinputs(username.text, password.text)) {
      emit(EmptyFieldRegistersState());
    }
    else {
      await registerNewUser(username,password, conversationsCubit,  chatRoomCubit);
    }
  }
}