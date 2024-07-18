class SignUp{
  String name, email, phone, password, img_url, uid;
  String role;

  SignUp(this.name, this.email, this.phone, this.password, this.img_url, this.uid, this.role);
  Map<String, dynamic> tomap(){
    return{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'img':img_url,
      'uid': uid,
      'role': role
    };
  }
}