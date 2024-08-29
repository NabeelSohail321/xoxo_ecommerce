import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Authentication/Login.dart';

class Rider extends StatefulWidget {
  const Rider({super.key});

  @override
  State<Rider> createState() => _RiderState();
}

class _RiderState extends State<Rider> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final oref = FirebaseDatabase.instance.ref('orders');



  Widget buildCircularProgressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    );
  }


  Future<void> _AcceptOrders(List<dynamic> list, int index) async {
    // Ensure list is not empty and index is valid
    if (list.isNotEmpty && index < list.length) {
      String cid = list[index]['cartId'];
      String status = list[index]['status'].toString().toLowerCase();

      // Debugging output
      print("Delivering order with cid: $cid and status: $status");

      if (status == 'false') {
        // Query to find the order by cid
        DataSnapshot snapshot = await oref.orderByChild('cartId').equalTo(cid).get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;

          // Find the key for the order to update
          String key = map1.keys.firstWhere((k) => map1[k]['cartId'] == cid);

          // print(key);
          await oref.child(key).update({'status': 'deliver'}).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order Delivered. ')),
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
    final width = MediaQuery.of(context).size.width;

    String status1 = 'true';
    String? name;
    String? description;
    String? img;
    String? number;
    String? price;
    bool _noDataFound = false;
    String? status;
    String? date;
    String? cid;
    void _showItemsDialog(List<dynamic> itemsList) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Order Items"),
            content: SingleChildScrollView(
              child: Column(
                children: itemsList.map((item) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item['img']),
                    ),
                    title: Text(item['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Description: ${item['description']}"),
                        Text("Price: ${item['price']}"),
                        Text("Quantity: ${item['number']}"),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
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
              stream: oref.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: buildCircularProgressIndicator(),
                  );
                } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> ordersMap = snapshot.data!.snapshot.value as dynamic;
                  if (ordersMap == null) {
                    return Center(child: Text("No Orders Found"));
                  }
                  List<dynamic> ordersList = ordersMap.values.toList();

                  return ListView.builder(
                    // reverse: true,
                    itemCount: ordersList.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                            side: BorderSide(
                              color: ordersList[index]['status']=='deliver'? Colors.blue:  Colors.red, // Border color
                              width: 3.0, // Border width
                            ),
                          ),
                          elevation: 10,
                          child: ListTile(
                            title: Text(
                              "Order ID: ${ordersList[index]['cartId']}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              children: [
                                Text("Order Date: ${ordersList[index]['date']}"),
                                Text("Total Bill: ${ordersList[index]['totalBill']}" ),
                                ordersList[index]['status']=='false'? Text("status: Pending"):ordersList[index]['status']=='deliver'? Text("status: delivered"):Text("status: will be delivered in 7 working days"),
                              ordersList[index]['status']=='false'?
                                ElevatedButton(
                                    onPressed: () async {
                                      await _AcceptOrders(ordersList,index);
                                    },
                                    child: Text('Deliver ?')):Text('Delivered to Customer')
                              ],
                            ),

                            onTap: () {
                              // Extract items from the order and display in dialog
                              Map<dynamic, dynamic> itemsMap = ordersList[index]['items'];
                              List<dynamic> itemsList = itemsMap.values.toList();
                              _showItemsDialog(itemsList);
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: Text("No Orders Found"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
