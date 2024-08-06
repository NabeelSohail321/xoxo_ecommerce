class Product{
  String name, description, quantity,img_url,uid,buying_price,selling_price,pid, category;


  Product(this.name, this.description, this.quantity, this.img_url, this.uid,
      this.buying_price, this.selling_price, this.pid, this.category);

  Map<String, dynamic> tomap(){
    return{
      "name": name,
      "description": description,
      "quantity": quantity,
      'img':img_url,
      'uid': uid,
      'buying': buying_price,
      'selling': selling_price,
      'pid': pid,
      'category': category
    };
  }
}