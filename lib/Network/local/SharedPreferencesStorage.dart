import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesStorage{
  static SharedPreferences prefs;

  static init()async{
    print("init shared");
    prefs=  await SharedPreferences.getInstance();
  }

  static Future<void> setDeviceTokenIfNotStoredInLocalStorage() async {
    if((prefs.get('deviceToken') ?? "")==""){
      String deviceToken =await FirebaseMessaging.instance.getToken();
      await prefs.setString("deviceToken", deviceToken);
    }
  }
  static Future<void> setOpenedMessageFromNotification(RemoteMessage message) async {
    await prefs.setString("openedMessage", message.data['comingMessageSender'].toString());
  }

  static String getOpenedMessageFromSharedPreferences() {
    String openedMessage=(prefs.get('openedMessage') ?? "");
    return openedMessage;
  }
  static String getDeviceTokenFromSharedPreferences() {
    return prefs.get('deviceToken') ?? "";
  }

}