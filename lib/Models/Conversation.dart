import 'dart:convert';

import 'package:chatapp/Models/Massage.dart';
import 'package:chatapp/Models/User.dart';

class conversation {
  String conversationId;
  String lastMassage="now you can chat with this person";
  String id;
  user firstPerson;
  user secondPerson;
  String istyping="false";
  List<Massage> massages=[];
  conversation.fromJson(Map<String, dynamic> json) {
    lastMassage = json['lastMassage'];
    firstPerson =user.fromJson(json['firstPerson']);
    secondPerson =user.fromJson(json['secondPerson']);
    id=json['id'];
    List<Massage>map=[];
    json['Messages'].forEach((element) {
      map.add(Massage.fromJson(element));
    });
    conversationId=json['conversationsID'];
    massages=map;
  //  massages=json['Messages'].map((e) => Massage.fromJson(e));
    istyping=json['istyping'];
  }


  conversation(this.firstPerson, this.secondPerson);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstPerson']=firstPerson.toJson();
    data['secondPerson']=secondPerson.toJson();
    data['lastMassage']=lastMassage;
    data['istyping']=istyping;
    data['id']=id;
    data['conversationsID']=conversationId;
    List<Map<String,dynamic>>map=[{}];
    massages.forEach((element) {
      map.add(element.toJson());
    });
    data['Messages']=map;
    return data;
  }
}
