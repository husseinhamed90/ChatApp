import 'dart:convert';

import 'package:chatapp/Models/Massage.dart';
import 'package:chatapp/Models/User.dart';

class conversation {
  String lastMassage="now you can chat with this person";
  user firstPerson;
  user secondPerson;
  String istyping="false";
  conversation.fromJson(Map<String, dynamic> json) {
    lastMassage = json['lastMassage'];
    firstPerson =user.fromJson(json['firstPerson']);
    secondPerson =user.fromJson(json['secondPerson']);
    istyping=json['istyping'];
  }


  conversation(this.firstPerson, this.secondPerson);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstPerson']=firstPerson.toJson();
    data['secondPerson']=secondPerson.toJson();
    data['lastMassage']=lastMassage;
    data['istyping']=istyping;
    return data;
  }
}
