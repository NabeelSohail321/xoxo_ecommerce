import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:xoxo_ecommerce/models/cart.dart';
import '../Authentication/Login.dart';

class viewProduct extends StatefulWidget {
  String uid, pid;

  viewProduct(this.uid, this.pid);

  @override
  State<viewProduct> createState() => _viewProductState();
}

class _viewProductState extends State<viewProduct> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final dref = FirebaseDatabase.instance.ref("Products");
  final cref = FirebaseDatabase.instance.ref('Cart');
  String? title;
  String? description;
  String? price;
  String? quantity;
  String? img;
  String? sid;
  int selectedQuantity = 1; // Default quantity
  String? buying;

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
            (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign out error
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
          Expanded(
            child: StreamBuilder(
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
                } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
                  if (map == null) {
                    return Center(child: Text("No Product Found"));
                  }
                  List<dynamic>? list = [];
                  list.clear();
                  list = map.values.toList();

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      title = list![index]['name'];
                      description = list[index]['description'];
                      price = list[index]['selling'];
                      quantity = list[index]['quantity'];
                      img = list[index]['img'].toString();
                      sid = list[index]['uid'].toString();
                      buying = list[index]['buying'].toString();

                      return Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 120,
                              backgroundImage: NetworkImage(img!) as ImageProvider,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 28.0),
                              child: Text(
                                title!,
                                style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Ubuntu'),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 28.0),
                              child: Text(
                                description!,
                                style: TextStyle(
                                    fontSize: 20, fontFamily: 'Ubuntu'),
                              ),
                            ),
                            Text('Price : $price'),
                            Text('Available Quantity : $quantity'),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove),
                                    onPressed: () {
                                      setState(() {
                                        if (selectedQuantity > 1) {
                                          selectedQuantity--;
                                        }
                                      });
                                    },
                                  ),
                                  Text(
                                    '$selectedQuantity',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add),
                                    onPressed: () {
                                      setState(() {
                                        if (selectedQuantity < int.parse(quantity!)) {
                                          selectedQuantity++;
                                        }
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async {
            cref.child(widget.uid).child(widget.pid).once().then((DatabaseEvent event) async {
              if (event.snapshot.exists) {
                // Product already in the cart, update the quantity
                // Map<dynamic, dynamic> cartData = event.snapshot.value as Map<dynamic, dynamic>;
                // int currentNumber = int.parse(cartData['number']);
                // int newNumber = currentNumber + selectedQuantity;
                //
                // if (newNumber <= int.parse(quantity!)) {
                //   await cref.child('${widget.uid}/${widget.pid}').update({'number': newNumber.toString()}).then((_) {
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       SnackBar(content: Text('Cart Updated')),
                //     );
                //   });
                // } else {
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     SnackBar(content: Text('Not enough quantity available')),
                //   );
                // }


                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Product Already in the Cart')),
                );
              } else {
                // Product not in the cart, add it
                if (selectedQuantity <= int.parse(quantity!)) {
                  String id = cref.push().key.toString();
                  cart Cart = cart(
                      id,
                      widget.pid,
                      widget.uid,
                      title!,
                      description!,
                      price!,
                      sid!,
                      img!,
                      selectedQuantity.toString(),
                      formattedDate,
                      buying!
                  );
                  await cref.child(widget.uid).child(widget.pid).set(Cart.tomap()).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Added to Cart')),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Not enough quantity available')),
                  );
                }
              }
            });
          },
          child: Icon(
            Icons.add_shopping_cart,
            size: 40,
          ),
          tooltip: 'Add to cart',
        ),
      ),
    );
  }
}
