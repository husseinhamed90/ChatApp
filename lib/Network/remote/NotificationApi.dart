import 'package:chatapp/Constants.dart';
import 'package:chatapp/Models/Message.dart';
import 'package:chatapp/Models/User.dart';
import 'package:dio/dio.dart';

class NotificationApi {
  static Dio dio;

  static init() {
    dio = Dio();
  }

  static Future sendNotification({Message message,String receiverToken,UserAccount currentAccount}) async {

    await dio.post(apiPath,
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
        options: Options(contentType: "application/json", method: "POST", headers: {
          "Authorization": "key=$authorizationKey"
        })
    );
  }
}
