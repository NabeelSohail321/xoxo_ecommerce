import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:xoxo_ecommerce/SellerPages/HomeScreen.dart';
import 'package:xoxo_ecommerce/SellerPages/OrderDelivered.dart';
import 'package:xoxo_ecommerce/SellerPages/OrderPending.dart';
import '../Authentication/Login.dart';

class Orders extends StatefulWidget {
  final String uid;

  Orders(this.uid);

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  int orderNumber = 0;
  int pendingNumber = 0;

  @override
  void initState() {
    super.initState();
    _fetchOrderNumbers(); // Fetch order numbers when the widget is first built
  }

  @override
  Widget build(BuildContext context) {
    final oref = FirebaseDatabase.instance.ref('BuyerOrders');
    final height = MediaQuery.of(context).size.height;
    final FirebaseAuth _auth = FirebaseAuth.instance;

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
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical: height * 0.08, horizontal: height * 0.01),
          //   child: InkWell(
          //     onTap: () {
          //       _signOut(context);
          //     },
          //     child: Icon(Icons.logout, size: height * 0.06),
          //   ),
          // )
        ],
      ),
      body: Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            padding: EdgeInsets.all(10.0),
            shrinkWrap: true,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return OrderPending(widget.uid);
                  }));
                },
                child: DashboardCard(
                  title: 'Pending Orders',
                  icon: Icons.shopping_bag,
                  number: pendingNumber.toString(),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return OrderDelivered(widget.uid);
                  }));
                },
                child: DashboardCard(
                  title: 'Orders Delivered',
                  icon: Icons.list_alt,
                  number: orderNumber.toString(),
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: oref.orderByChild('sid').equalTo(widget.uid).onValue,
              builder: (BuildContext context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator()); // Show loading indicator while waiting
                } else if (snapshot.hasData) {
                  Map<dynamic, dynamic>? map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>?;
                  if (map == null) {
                    return Center(child: Text("No Data Found")); // Handle case with no data
                  }

                  List<dynamic> list = [];
                  list.clear();
                  list=map.values.toList();

                  int tempOrderNumber = 0;
                  int tempPendingNumber = 0;

                  list.forEach((order) {
                    String status = order['status'].toString().toLowerCase();
                    if (status == 'false') {
                      tempPendingNumber++;
                    } else if (status == 'deliver') {
                      tempOrderNumber++;
                    }
                  });

                  if (orderNumber != tempOrderNumber || pendingNumber != tempPendingNumber) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        orderNumber = tempOrderNumber;
                        pendingNumber = tempPendingNumber;
                      });
                    });
                  }

                  return Container(); // Replace with your content or additional UI components
                } else {
                  return Center(child: Text("Error loading data")); // Handle unexpected error
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _fetchOrderNumbers() async {
    final oref = FirebaseDatabase.instance.ref('BuyerOrders');
    final snapshot = await oref.orderByChild('sid').equalTo(widget.uid).once();
    Map<dynamic, dynamic>? map = snapshot.snapshot.value as Map<dynamic, dynamic>?;
    if (map != null) {
      List<dynamic> list = map.values.toList();

      int tempOrderNumber = 0;
      int tempPendingNumber = 0;

      list.forEach((order) {
        String status = order['status'].toString().toLowerCase();
        if (status == 'false') {
          tempPendingNumber++;
        } else if (status == 'deliver') {
          tempOrderNumber++;
        }
      });

      setState(() {
        orderNumber = tempOrderNumber;
        pendingNumber = tempPendingNumber;
      });
    }
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String number;

  DashboardCard({required this.title, required this.icon, required this.number});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 50.0,
              color: Colors.blue,
            ),
            SizedBox(height: 10.0),
            Text(
              title,
              style: TextStyle(fontSize: 18.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.0),
            Text(
              number,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
