class Product{
  String name, description, quantity,img_url,uid,buying_price,selling_price;


  Product(this.name, this.description, this.quantity, this.img_url, this.uid,
      this.buying_price, this.selling_price);

  Map<String, dynamic> tomap(){
    return{
      "name": name,
      "description": description,
      "quantity": quantity,
      'img':img_url,
      'uid': uid,
      'buying': buying_price,
      'selling': selling_price
    };
  }
}