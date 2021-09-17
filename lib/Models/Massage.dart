class Massage{

  String senderId;
  String massage;
  String dateOfMassage;
  String timeStamp;


  Massage(this.massage, this.dateOfMassage, this.timeStamp,this.senderId);

  Massage.fromJson(Map<String, dynamic> json) {
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