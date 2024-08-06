import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Authentication/Login.dart';
import 'HomeScreen.dart';

class OrderPending extends StatefulWidget {
  final String uid;

  OrderPending(this.uid);

  @override
  State<OrderPending> createState() => _OrderPendingState();
}

class _OrderPendingState extends State<OrderPending> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final oref = FirebaseDatabase.instance.ref('BuyerOrders');

    Widget buildCircularProgressIndicator() {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      );
    }

    Future<void> _AcceptOrders(List<dynamic> list, int index) async {
      // Ensure list is not empty and index is valid
      if (list.isNotEmpty && index < list.length) {
        String cid = list[index]['cid'];
        String status = list[index]['status'].toString().toLowerCase();

        // Debugging output
        print("Accepting order with cid: $cid and status: $status");

        if (status == 'false') {
          // Query to find the order by cid
          DataSnapshot snapshot = await oref.orderByChild('cid').equalTo(cid).get();

          if (snapshot.exists) {
            Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;

            // Find the key for the order to update
            String key = map1.keys.firstWhere((k) => map1[k]['cid'] == cid);

            await oref.child(key).update({'status': 'true'}).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order accepted.')),
              );
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order not found.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order already accepted.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid order.')),
        );
      }
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
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical: height * 0.08, horizontal: height * 0.01),
          //   child: InkWell(
          //     onTap: () {
          //       _signOut(context);
          //     },
          //     child: Icon(Icons.logout, size: height * 0.06),
          //   ),
          // ),
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: Icon(Icons.logout),
                onTap: () {
                  _signOut(context);
                },
              ),
              PopupMenuItem(
                child: Icon(Icons.home),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return HomeScreen(widget.uid);
                  }));
                },
              )
            ];
          }, iconSize: height * 0.04),

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
                  "Pending Order List",
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
              stream: oref.orderByChild('sid').equalTo(widget.uid).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: buildCircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
                  List<dynamic> list = map.values.toList();
                  List<dynamic> pendingList = list.where((element) => element['status'].toString().toLowerCase() == 'false').toList();

                  if (pendingList.isEmpty) {
                    return Center(child: Text("No Product Found"));
                  }

                  return ListView.builder(
                    // reverse: true,
                    itemCount: pendingList.length,
                    itemBuilder: (context, index) {
                      String name = pendingList[index]['name'].toString();
                      String description = pendingList[index]['description'].toString();
                      String price = pendingList[index]['price'].toString();
                      String img = pendingList[index]['img'].toString();
                      String number = pendingList[index]['number'].toString();
                      String status = pendingList[index]['status'].toString().toLowerCase();
                      String date = pendingList[index]['date'];
                      String cid = pendingList[index]['cid'];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                        child: Card(
                          elevation: 10,
                          child: Container(
                            height: height * 0.17,
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(img),
                                  ),
                                  trailing: Padding(
                                    padding: EdgeInsets.only(top: height * 0.01),
                                    child: Column(
                                      children: [
                                        Text('date is: $date'),
                                        Text('quantity is: $number'),
                                      ],
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Order Pending',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _AcceptOrders(pendingList, index);
                                  },
                                  child: Text('Accept'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
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
