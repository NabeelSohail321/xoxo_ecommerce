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
    final oref = FirebaseDatabase.instance.ref('orders');

    Widget buildCircularProgressIndicator() {
      return CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      );
    }

    Future<void> _signOut(BuildContext context) async {
      try {
        await _auth.signOut();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Login()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        print("Error signing out: $e");
      }
    }

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
              stream: oref.orderByChild('uid').equalTo(widget.uid).onValue,
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
                                ordersList[index]['status']=='false'? Text("status: Pending"):ordersList[index]['status']=='deliver'? Text("status: delivered"):Text("status: will be delivered in 7 working days")
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
