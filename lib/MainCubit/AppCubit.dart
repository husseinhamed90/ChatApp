import 'package:chatapp/MainCubit/AppCubitStates.dart';
import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/Massage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chatapp/Models/User.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc/bloc.dart';


class AppCubit extends Cubit<AppCubitStates> {

  AppCubit() : super(initialState());

  static AppCubit get(BuildContext context) => BlocProvider.of(context);

  CollectionReference userscollection = FirebaseFirestore.instance.collection('Users');

  List<user> users = [];
  List<conversation>userConversations;

  bool isloging=false;
  bool issearch=false;

  user currentuser;
  List<user>searchlist=[];
  conversation currentConversation;

  List<conversation>myConversations=[];

  void setCurrentUser(user updatedUser){
    currentuser=updatedUser;
    emit(setUpdatedUser());
  }

  void resetCurrentConversation(){
    currentConversation=null;
    emit(getConversationsDetailsState());
  }


  Future sendMessage(String massage,AppCubit appCubit)async{
    Massage newMessage =Massage(massage, DateTime.now().toString(), DateTime.now().millisecondsSinceEpoch.toString(),appCubit.currentuser.id);
    if(appCubit.currentConversation==null){
      List<Massage>messages=[];
       messages.add(newMessage);
       await appCubit.addnewconversation(messages);
    }
    else{
       appCubit.addMessageToConversation(newMessage);
    }
    await appCubit.updateMessagesInFirebase();
  }

  Future updateMessagesInFirebase()async{
    await userscollection.doc(currentuser.id).collection("chats").doc(chosenUser.id).update(
        {"Messages": currentConversation.massages.map((e) => e.toJson()).toList(),'lastMassage':currentConversation.massages.last.massage,"istyping": "false"});

    await userscollection.doc(chosenUser.id).collection("chats").doc(currentuser.id).update(
        {"Messages": currentConversation.massages.map((e) => e.toJson()).toList(),'lastMassage':currentConversation.massages.last.massage,"istyping": "false"});
  }

  void emptythesearchlist(){
    searchlist=[];
    emit(searchlistisNowEmpty());
  }
  Future getsearchedlist(String searchedWord)async{

    await userscollection.get().then((value) {
      searchlist=[];
      value.docs.forEach((element) {
        if(user.fromJson(element.data()).id!=currentuser.id) {
          if (user.fromJson(element.data()).name.startsWith(searchedWord)) {
            bool isFound =false;
            searchlist.forEach((item) {
              if(user.fromJson(element.data()).id==item.id){
                isFound=true;
              }
            });
            if(isFound==false){
              searchlist.add(user.fromJson(element.data()));
            }
            emit(SearchedListCome());
          }
        }
      });
    });
  }

  void addMessageToConversation(Massage newMessage){
    currentConversation.massages.add(newMessage);
    setCurrentConversation(currentConversation);
    //emit(getConversationsDetailsState());
  }

  void setCurrentConversation(conversation conversation){
    currentConversation=conversation;
    emit(getConversationsDetailsState());
  }

  void changesearchbarState(){
    issearch=!issearch;
    searchlist=[];
    emit(searchbarresetState());
  }
  user chosenUser;
  Future setChosenUser(user chosen)async{
    chosenUser=chosen;
    await FirebaseFirestore.instance.collection("Users").doc(currentuser.id).collection("chats").doc(chosenUser.id).get().then((conversationDocument) async {
      if(conversationDocument.data()!=null){
        currentConversation=conversation.fromJson(conversationDocument.data());
      }
      emit(newconversationAddedSuccssefully());
    });
    emit(searchbarresetState());
  }
  Future<conversation> addnewconversation(List<Massage>messages)async{

    conversation newconversation =conversation(currentuser, chosenUser);
    newconversation.massages=messages;

     await FirebaseFirestore.instance.collection("Users").doc(currentuser.id).collection("chats").doc(chosenUser.id).set(newconversation.toJson()).then((valuee) async {
       currentConversation=newconversation;
       conversation createReceiverConversation =conversation(chosenUser, currentuser);
       await FirebaseFirestore.instance.collection("Users").doc(chosenUser.id).collection("chats").doc(currentuser.id).set(createReceiverConversation.toJson()).then((valuee) async {
         emit(newconversationAddedSuccssefully());
       });
       emit(newconversationAddedSuccssefully());
     });

  }
  void GetCurrentUser(user user)async{
    currentuser=user;
    await getusers();
    emit(GetUserIDSate());
  }
  bool checkvalidatyofinputs(String username,String password){
    if(username == "" || password == ""){
      return false;
    }
    else{
      return true;
    }
  }

  Future<UserCredential>GetUserCredentialFromFireBase(String username,String password) async{
    try{
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: '${username.replaceAll(' ', '')}@stepone.com',
          password: password + "steponeapp"
      ).catchError((error) {
        emit(invaliduser());
      });
    }catch (e) {
      emit(invaliduser());
    }
  }

  Future<void>isValidUser(UserCredential userCredential)async{
    await FirebaseFirestore.instance.collection('Users').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (user.fromJson(doc.data()).id == userCredential.user.uid) {
          GetCurrentUser(user.fromJson(doc.data()));
          //emit(currentuserdata());
          emit(validuser());
        }
      });
    });
  }

  Future<void> loginwithusernameandpassword(String username, String password) async {
    emit(loginsistart());
    isloging=true;
    if (!checkvalidatyofinputs(username,password)) {
      emit(emptyfeildsstate());
      isloging=false;
    }
    else {
      //emit(validateiuser());
      UserCredential userCredential =await GetUserCredentialFromFireBase(username,password);
      if(userCredential!=null){
        await isValidUser(userCredential);
        isloging=false;
      }
      else{
        isloging=false;
      }
    }
  }

  Future<user>CreateAccountInFireBaeAuthentication(TextEditingController username, TextEditingController password)async{

    UserCredential userCredential= await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '${username.text.replaceAll(' ', '')}@stepone.com',
        password: password.text + "steponeapp");
    return user(username.text, password.text, 'user', userCredential.user.uid);
  }

  Future<void>CreateNewUser(user newuser){

    DocumentReference documentReference = FirebaseFirestore.instance.collection("Users").doc(newuser.id);
    documentReference.set(newuser.toJson()).then((value){
      emit(userregistered());
    });
  }

  Future<void>RegisterNewUser(TextEditingController username, TextEditingController password)async{
    try {
      emit(loaddatafromfirebase());
      user newuser =await CreateAccountInFireBaeAuthentication(username,password);
      await CreateNewUser(newuser);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        emit(weakpassword());
      } else if (e.code == 'email-already-in-use') {
        emit(accountalreadyexists());
      }
    } catch (e) {
      print(e);
    }
  }

  void register(TextEditingController username, TextEditingController password) async {
    if (!checkvalidatyofinputs(username.text, password.text)) {
      emit(emptyfeildregistersstate());
    }
    else {
      await RegisterNewUser(username,password);
    }
  }

  Future<void> getusers() async {
    users = [];
    emit(loaddatafromfirebase());
    await userscollection.get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        users.add(user.fromJson(doc.data()));
      });
      emit(getusersstate());
    }).catchError((error) {
      print(error);
    });
  }
}