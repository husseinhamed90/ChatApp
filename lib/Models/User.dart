

class UserAccount{
  String name;
  String password;
  String userType;
  String id;
  String isfirsttime;
  String isonline;
  String location;
  String imagepath="https://www.leisureopportunities.co.uk/images/imagesX/HIGH799405_746782.jpg";




  UserAccount(this.name, this.password, this.userType,this.id,[this.isfirsttime="true",this.isonline="false"]);

  UserAccount.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    password = json['password'];
    userType =json['usertype'];
    id=json['id'];
    isfirsttime=json['isfirsttime'];
    imagepath =json['image'];
    isonline=json['isonline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['password'] = this.password;
    data['usertype']=this.userType;
    data['id']=this.id;
    data['image']=this.imagepath;
    data['isfirsttime']=this.isfirsttime;
    data['isonline']=this.isonline;
    return data;
  }

}