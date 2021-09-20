import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/Message.dart';
import 'package:chatapp/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseApiServices{
  static CollectionReference usersCollection;

  static init(){
    FirebaseApiServices();
    usersCollection = FirebaseFirestore.instance.collection('Users');
  }

  static DocumentReference chosenUserChat(String currentUserID,String chosenUserID) =>
       usersCollection.doc(currentUserID)
      .collection("chats")
      .doc(chosenUserID);

  static DocumentReference currentUserChat(String currentUserID,String chosenUserID) =>
      usersCollection.doc(chosenUserID)
          .collection("chats")
          .doc(currentUserID);

  static DocumentReference getChosenUserChat(String currentUserID,String chosenUserID) {
    return usersCollection.doc(currentUserID).collection("chats").doc(chosenUserID);
  }

  static Future getSearchedList(String searchedWord)async{
    return await usersCollection.get();
  }

  static Stream<QuerySnapshot> getStreamOfConversations(String currentUserID) {
    return usersCollection.doc(currentUserID)
        .collection("chats")
        .orderBy("dateOfConversation",descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> streamOfMessages(String currentUserID,String chosenUserID,int pageSize) {
      return FirebaseApiServices.chosenUserChat( currentUserID, chosenUserID)
          .collection("Messages")
          .orderBy("timeStamp")
          .limitToLast(pageSize)
          .snapshots();
  }

  static Future updateMessagesInFirebase(Message newMessage,String currentUserID,String chosenUserID)async{
    await FirebaseApiServices.chosenUserChat(currentUserID, chosenUserID)
        .collection("Messages")
        .add(newMessage.toJson());

    await FirebaseApiServices.chosenUserChat(currentUserID, chosenUserID)
        .update({'lastMassage':newMessage.massage,"istyping": "false","dateOfConversation":newMessage.timeStamp});

    await FirebaseApiServices.currentUserChat(currentUserID, chosenUserID)
        .collection("Messages")
        .add(newMessage.toJson());

    await FirebaseApiServices.currentUserChat(currentUserID, chosenUserID)
        .update({'lastMassage':newMessage.massage,"istyping": "false","dateOfConversation":newMessage.timeStamp});
  }

  static Future<void> changeTypingState(bool typingState,String currentUserID, String chosenUserID) async {
    await FirebaseApiServices.chosenUserChat(currentUserID, chosenUserID).update({"istyping": typingState.toString()});
    await FirebaseApiServices.currentUserChat(currentUserID, chosenUserID).update({"istyping": typingState.toString()});
  }

  static Future<void> addConversationToUserAccount(String currentUserID, String chosenUserID,
      Conversation newConversation,Conversation receiverConversation)async{

    await FirebaseApiServices.chosenUserChat(currentUserID,chosenUserID).set(newConversation.toJson());
    await FirebaseApiServices.currentUserChat(currentUserID,chosenUserID).set(receiverConversation.toJson());
  }

  static Future<UserCredential>getUserCredentialFromFireBase(String username,String password) async{
    try{
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: '${username.replaceAll(' ', '')}@stepone.com',
          password: password + "steponeapp"
      ).catchError((error) {
        return null;
      });
    }catch (e) {
      return null;
    }
  }

  static getUserAccountData(UserCredential userCredential) => usersCollection.doc(userCredential.user.uid).get();

  static Future<UserCredential> createUserInFirebase(String username, String password) async {
    return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: '${username.replaceAll(' ', '')}@stepone.com',
        password: password + "steponeapp");
  }

  static Future createNewDocumentForNewUserInFirebase(UserAccount newUser) async {
    await usersCollection.doc(newUser.id).set(newUser.toJson());
  }
}