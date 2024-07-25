import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Authentication/Login.dart';

class BuyerOrders extends StatefulWidget {
  String uid;


  BuyerOrders(this.uid);

  @override
  State<BuyerOrders> createState() => _BuyerOrdersState();
}

class _BuyerOrdersState extends State<BuyerOrders> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final oref = FirebaseDatabase.instance.ref('BuyerOrders');

    String? name ;
    String? description;
    String? img ;
    String? number ;
    String? price;
    bool _noDataFound = false;
    String? status;
    String? date;

    Widget buildCircularProgressIndicator() {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      );
    }



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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Order List",
                  style: TextStyle(
                    fontSize: height * 0.03,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Ubuntu',
                  ),
                ),
              ),
              Icon(Icons.shopping_cart, size: height * 0.03),
            ],
          ),

          Expanded(
            child: StreamBuilder(
              stream: oref.orderByChild('uid').equalTo(widget.uid).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData && !_noDataFound) {
                  return Center(
                    child: buildCircularProgressIndicator(),
                  );
                } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
                  if (map == null) {
                    return Center(child: Text("No Product Found"));
                  }
                  List<dynamic> list = map.values.toList();


                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          reverse: true,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            name = list[index]['name'].toString();
                            description = list[index]['description'].toString();
                            price = list[index]['price'].toString();
                            img = list[index]['img'].toString();
                            number = list[index]['number'].toString();
                            status = list[index]['status'].toString().toLowerCase();
                            date= list[index]['date'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                  side: BorderSide(
                                    color: status=='false'? Colors.red:Colors.green, // Border color
                                    width: 3.0, // Border width
                                  ),
                                ),
                                elevation: 10,
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      ListTile(

                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                          name!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(img!),
                                        ),
                                        trailing: Padding(
                                          padding: const EdgeInsets.only(top: 10.0),
                                          child: Column(
                                            children: [
                                              Text('Date is: $date',style: TextStyle(color: Colors.black)),
                                              Text('Quantity is: $number',style: TextStyle(color: Colors.black))
                                            ],
                                          ),
                                        ),
                                        subtitle: Text(description!,style: TextStyle(color: Colors.black),)
                                      ),
                                      (status == 'false')? Center(
                                        child: Text(
                                          'Order Pending',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
                                        ),
                                      ):(status=='true')? Center(
                                        child: Text(
                                          'Deliver in 10 to 15 days',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
                                        ),
                                      ): Center(
                                        child: Text(
                                          'Order Delivered',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Center(child: Text("No Product Found"));
                }
              },
            ),
          ),

        ],
      ),

    );
  }
}
