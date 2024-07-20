

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:xoxo_ecommerce/models/cart.dart';

import '../Login.dart';

class viewProduct extends StatefulWidget {
  String uid,pid;


  viewProduct(this.uid,this.pid);

  @override
  State<viewProduct> createState() => _viewProductState();
}

class _viewProductState extends State<viewProduct> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final dref = FirebaseDatabase.instance.ref("Products");
  final cref = FirebaseDatabase.instance.ref('Cart');
  String? title;
  String? description;
  String? price ;
  String? quantity ;
  String? img;
  String? sid;
  int number =0 ;


  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut().then((value) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Login()), // Navigate to your login screen
        );

      });
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign out error
    }
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text(
          'xoxo',
          style: TextStyle(
            fontSize: height * 0.1,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu',
          ),
        ),
        centerTitle: true,
        toolbarHeight: height * 0.2,
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: height * 0.08, horizontal: height * 0.01),
            child: InkWell(
              onTap: () {
                _signOut(context);
              },
              child: Icon(Icons.logout, size: height * 0.06),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(child: StreamBuilder(
            stream: dref.orderByChild('pid').equalTo(widget.pid).onValue,
            builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                    backgroundColor: Colors.grey[200],
                    strokeWidth: 4.0,
                  ),
                );
              }else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
                if (map == null) {
                  return Center(child: Text("No Product Found"));
                }
                List<dynamic>? list = [];
                list.clear();
                list = map.values.toList();

                return ListView.builder(
                  itemCount:list.length ,
                  itemBuilder: (context, index) {

                     title = list![index]['name'];
                     description = list[index]['description'];
                     price = list[index]['selling'];
                     quantity = list[index]['quantity'];
                     img = list[index]['img'].toString();
                     sid = list[index]['uid'].toString();


                   return Center(
                     child: Column(
                        children: [
                          CircleAvatar(
                            radius: 120,
                            backgroundImage: NetworkImage(img!) as ImageProvider,
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 28.0),
                            child: Text(title!,style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,fontFamily: 'Ubuntu'),),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 28.0),
                            child: Text(description!,style: TextStyle(fontSize: 20,fontFamily: 'Ubuntu'),),
                          ),
                          Text('price : $price'),
                          Text('Quantity : $quantity')
                        ],
                      ),
                   );
                },
                );
              } else {
                return Container();
              }


    },))
        ],
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async{


            if(int.tryParse(quantity!)! > number) {
              setState(() {
                number=number+1;
              });
              String id = cref
                  .push()
                  .key
                  .toString();
              cart Cart = cart(
                  id,
                  widget.pid,
                  widget.uid,
                  title!,
                  description!,
                  price!,
                  sid!,
                  img!,
                  number.toString()
              );
              await cref.child(widget.uid).child(widget.pid).set(Cart.tomap()).then((
                  value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Cart Updated')),
                );
              });
            }
            else{
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Not have enough Quantity')),
              );
            }
          },child: Icon(Icons.add_shopping_cart, size: 40,),tooltip: 'add to cart',
        ),
      ),
    );
  }
}
