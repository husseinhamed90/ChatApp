import 'dart:io';
import 'package:chatapp/Models/Conversation.dart';
import 'package:chatapp/Models/Message.dart';
import 'package:chatapp/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;


class FirebaseApiServices{
  static CollectionReference usersCollection;
  static init(){
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

  static Future createNewDocumentForNewUserInFirebase(UserAccount newUser,XFile file) async {
    if(file!=null){
      newUser = await saveFileIntoFireBaseStorage(file, newUser);
    }
    else{
      newUser.imagepath="https://o.remove.bg/downloads/9cf41bbf-1ae4-4c98-9acd-2d11e0af5571/image-removebg-preview.png";
    }
    await usersCollection.doc(newUser.id).set(newUser.toJson());
  }

  static Future<UserAccount> saveFileIntoFireBaseStorage(XFile file,UserAccount account) async{
    String extention = p.extension(file.path).split('.')[1];
    String filename = p.basename(file.path);
    Reference ref = FirebaseStorage.instance.ref().child('${extention}s/$filename');
    UploadTask uploadedFileProgress = ref.putFile(File(file.path), SettableMetadata(contentType: 'application/$extention'));

    await uploadedFileProgress.then((value) async {
      await value.ref.getDownloadURL().then((path) async {
        account.imagepath=path;
      });
    });
    return account;
  }

  static Future<DocumentSnapshot> getReceiverTokenDocumentFromFirebase(String chosenUserId) async => await FirebaseFirestore.instance.collection("Tokens").doc(chosenUserId).get();

}