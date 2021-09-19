class Message{

  String senderId;
  String massage;
  String dateOfMassage;
  String timeStamp;


  Message(this.massage, this.dateOfMassage, this.timeStamp,this.senderId);

  Message.fromJson(Map<String, dynamic> json) {
    massage= json["massage"];
    dateOfMassage= json["dateOfMassage"];
    timeStamp =json["timeStamp"];
    senderId=json['senderId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['massage']=massage;
    data['dateOfMassage']=dateOfMassage;
    data['timeStamp']=timeStamp;
    data['senderId']=senderId;
    return data;
  }

}