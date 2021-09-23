import 'package:chatapp/Models/Message.dart';
import 'package:chatapp/Models/User.dart';
import 'package:dio/dio.dart';

class NotificationApi {
  static Dio dio;
  static init() {
    print("init");
    dio = Dio();
  }
  //d8PmO8uvTmKg_aSNjukCcT:APA91bHjFFtLXE7HGvOy49QWw0dt3BBd2AvSMuciRbSif3MoTRo7f4YS2pXGZU-ubQf1kYFxdrhrrB3LcS0fJJ_rWA8BukqvjndtN7alAHn32lJkwWmphkhj1uRFL41u2YN9HxLC1qEP
  static Future sendNotification({Message message,String receiverToken,UserAccount currentAccount}) async {
    String url = "https://fcm.googleapis.com/fcm/send";
    await dio.post(url,
        data: {
          "priority": "high",
          "to": receiverToken,
          "notification": {
            "title": currentAccount.name,
            "body": message.massage,
            "mutable_content": true,
            "sound": "Tri-tone"
          },
          "data": {
            "click_action": "FLUTTER_NOTIFICATION_CLICK",
            "id":currentAccount.id,
            "Message": message.toJson(),
            "comingMessageSender":currentAccount.toJson()
          }
        },
        options:
            Options(contentType: "application/json", method: "POST", headers: {
          "Authorization": "key=AAAAq3qeCXg:APA91bEnMcAf8oyjIShlcPEQQ-zYRHTotkwv_pOhxvKjil9LtrO17djiaa9fM5EEeibortXpxH4XUz6kxN4waaprvNgxV4s33zNLu0R74R-wiG5-jGTkuJKkb2wbQTR3OS3sM-3z5eCA"
        }));
  }
}
