import 'package:chatapp/AuthCubit/AuthCubit.dart';
import 'package:chatapp/ChatRoomCubit/ChatRoomCubit.dart';
import 'package:chatapp/ConversationsCubit/ConversationsCubit.dart';
import 'package:chatapp/Helpers/ResuableWidgets.dart';
import 'package:chatapp/Models/User.dart';
import 'package:chatapp/Network/local/SharedPreferencesStorage.dart';
import 'package:chatapp/Network/remote/FirebaseApi.dart';
import 'package:chatapp/Network/remote/NotificationApi.dart';
import 'package:chatapp/Screens/ChatScreen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Screens/Login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp();
  await SharedPreferencesStorage.init();
  FirebaseApiServices.init();
  NotificationApi.init();
  await SharedPreferencesStorage.setDeviceTokenIfNotStoredInLocalStorage();
  await listenForComingMessages();
  runApp(MyApp());
}

Future<void> listenForComingMessages() async {
    FirebaseMessaging.onMessageOpenedApp.listen((message) async{
    await SharedPreferencesStorage.setLastOpenedMessageFromNotification(message);
    if(AuthCubit.get(navigatorKey.currentState.context).currentUser!=null){
      openChatWhenAppInRecentAppsMenu();
    }
  });
}

void openChatWhenAppInRecentAppsMenu() {
  String openedMessage = SharedPreferencesStorage.getOpenedMessageFromSharedPreferences();
  Map openedMessageMap = json.decode(openedMessage);
  ChatRoomCubit.get(navigatorKey.currentState.context).setChosenUser(UserAccount.fromJson(openedMessageMap));
  Navigator.push(navigatorKey.currentState.context, MaterialPageRoute( builder: (context) => ChatScreen(UserAccount.fromJson(openedMessageMap).name,isFromNotification: true,),));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

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
        home: Login(),
        debugShowCheckedModeBanner: false,
      )
    );
  }
}
