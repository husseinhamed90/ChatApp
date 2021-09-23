import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/Helpers/ResuableWidgets.dart';
import 'package:chatapp/Models/User.dart';
import 'package:chatapp/Network/remote/FirebaseApi.dart';
import 'package:chatapp/Network/remote/NotificationApi.dart';
import 'package:chatapp/Screens/ChatScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Screens/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("on background");


}
GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp();

  String token =await FirebaseMessaging.instance.getToken();
  print(token);
  // ignore: missing_return
  FirebaseMessaging.onBackgroundMessage((message) {

  });

   UserAccount messageSender;
   FirebaseMessaging.onMessageOpenedApp.listen((message) async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     await prefs.setString("openedMessage", message.data['comingMessageSender'].toString());
     String vv=(prefs.get('openedMessage') ?? "");
     Map valueMap = json.decode(vv);
     if(AuthCubit.get(navigatorKey.currentState.context).currentUser!=null){
       ChatRoomCubit.get(navigatorKey.currentState.context).setChosenUser(UserAccount.fromJson(valueMap));
       Navigator.push(
           navigatorKey.currentState.context,
           MaterialPageRoute(
             builder: (context) => ChatScreen(UserAccount.fromJson(valueMap).name,isFromNotification: true,),));
     }
   });

  FirebaseMessaging.onMessage.listen((message) async{
    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification.title}');
    }
    Fluttertoast.showToast(
        msg: "on background",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.green,
        fontSize: 16.0
    );
  });

  runApp(MyApp(messageSender));
}

class MyApp extends StatelessWidget {
  UserAccount comingMessage;
  MyApp(this.comingMessage);
  @override
  Widget build(BuildContext context) {
    FirebaseApiServices.init();
    NotificationApi.init();
    return MultiProvider(
      providers: [
        BlocProvider(create: (_) => AuthCubit(),),
        BlocProvider(create: (_) => ConversationsCubit(),),
        BlocProvider(create: (_) => ChatRoomCubit(),),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(
          textTheme: GoogleFonts.tajawalTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: Login(comingMessageSender: comingMessage,),
        debugShowCheckedModeBanner: false,
      )
    );
  }
}
