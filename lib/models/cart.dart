class cart {
  String cid,pid,uid,name,description,price,sid;

  cart(this.cid, this.pid, this.uid, this.name, this.description, this.price, this.sid);

  Map<String, dynamic> tomap(){
    return{
      'cid': cid,
      'pid':pid,
      'uid': uid,
      'name': name,
      'description': description,
      'price':price,
      'sid': sid
    };
  }
}