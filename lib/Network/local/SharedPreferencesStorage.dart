import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStorage{

  static SharedPreferences prefs;

  static init()async{
    prefs=  await SharedPreferences.getInstance();
  }

  static Future<void> setDeviceTokenIfNotStoredInLocalStorage() async {
    if((prefs.get('deviceToken') ?? "")==""){
      String deviceToken =await FirebaseMessaging.instance.getToken();
      await prefs.setString("deviceToken", deviceToken);
    }
  }
  static Future<void> setLastOpenedMessageFromNotification(RemoteMessage message) async {
    await prefs.setString("openedMessage", message.data['comingMessageSender'].toString());
  }

  static String getOpenedMessageFromSharedPreferences() {
    return (prefs.get('openedMessage') ?? "");
  }

  static String getDeviceTokenFromSharedPreferences() {
    return prefs.get('deviceToken') ?? "";
  }
  static  Future<void> resetOpenedMessageInSharedPreferences() async {
    await prefs.setString("openedMessage","");
  }
}