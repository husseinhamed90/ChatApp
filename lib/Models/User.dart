

class user{
  String name;
  String password;
  String usertype;
  String id;
  String isfirsttime;
  String isonline;
  String location;




  user(this.name, this.password, this.usertype,this.id,[this.isfirsttime="true",this.isonline="false"]);

  user.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    password = json['password'];
    usertype =json['usertype'];
    id=json['id'];
    isfirsttime=json['isfirsttime'];
    isonline=json['isonline'];
    location=json['location'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['password'] = this.password;
    data['usertype']=this.usertype;
    data['id']=this.id;
    data['isfirsttime']=this.isfirsttime;
    data['isonline']=this.isonline;
    data['location']=this.location;
    return data;
  }

}