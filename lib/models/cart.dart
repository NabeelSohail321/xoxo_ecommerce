class cart {
  String cid,pid,uid,name,description,price,sid,img,number, date,buying;

  cart(this.cid, this.pid, this.uid, this.name, this.description, this.price, this.sid,this.img,this.number,this.date,this.buying);

  Map<String, dynamic> tomap(){
    return{
      'cid': cid,
      'pid':pid,
      'uid': uid,
      'name': name,
      'description': description,
      'price':price,
      'sid': sid,
      'img': img,
      'number': number,
      'date':date,
      'buying': buying
    };
  }
}