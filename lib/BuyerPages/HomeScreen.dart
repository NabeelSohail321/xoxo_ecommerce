import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xoxo_ecommerce/BuyerPages/Cart.dart';
import 'package:xoxo_ecommerce/BuyerPages/DisplayProducts.dart';
import 'package:xoxo_ecommerce/SellerPages/Product_Management.dart';
import 'package:xoxo_ecommerce/SellerPages/Profile.dart';

import '../Login.dart';

class Homescreenb extends StatefulWidget {
  String uid;


  Homescreenb(this.uid);

  @override
  State<Homescreenb> createState() => _HomescreenbState();
}

class _HomescreenbState extends State<Homescreenb> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()), // Navigate to your login screen
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
              padding:  EdgeInsets.symmetric(vertical: height* 0.08, horizontal: height* 0.01 ),
              child: InkWell(onTap: (){
                _signOut(context);
              },
                  child: Icon(Icons.logout, size: height*0.06,))
          )
        ],
      ),


      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth < 600) {
            // For mobile layout
            return MobileLayout(widget.uid);
          } else {
            // For web layout
            return WebLayout(widget.uid);
          }
        },
      ),


    );
  }
}


class MobileLayout extends StatefulWidget {
  String uid;

  MobileLayout(this.uid);

  @override
  State<MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<MobileLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(10.0),
        children: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return Display(widget.uid);
              }));
            },
            child: DashboardCard(
              title: 'Products',
              icon: Icons.shopping_bag,
            ),
          ),
          InkWell(
            onTap: () {

              Navigator.push(context, MaterialPageRoute(builder: (context){
                return cart(widget.uid);
              }));
            },
            child: DashboardCard(
              title: 'Cart',
              icon: Icons.add_shopping_cart,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return Profile(widget.uid);
              }));

            },
            child: DashboardCard(
              title: 'Profile',
              icon: Icons.person,
            ),
          ),
          InkWell(
            onTap: () {

            },
            child: DashboardCard(
              title: 'Orders',
              icon: Icons.list,
            ),
          ),
        ],
      ),
    );
  }
}


class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;

  DashboardCard({required this.title, required this.icon});

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
          ],
        ),
      ),
    );
  }
}


class WebLayout extends StatefulWidget {
  String uid;

  WebLayout(this.uid);

  @override
  State<WebLayout> createState() => _WebLayoutState();
}

class _WebLayoutState extends State<WebLayout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GridView.count(
        crossAxisCount: 4,
        padding: EdgeInsets.all(20.0),
        children: [
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return Display(widget.uid);
              }));
            },
            child: DashboardCard(
              title: 'Products',
              icon: Icons.shopping_bag,
            ),
          ),
          InkWell(
            onTap: () {

            },
            child: DashboardCard(
              title: 'Cart',
              icon: Icons.add_shopping_cart,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return Profile(widget.uid);
              }));

            },
            child: DashboardCard(
              title: 'Profile',
              icon: Icons.person,
            ),
          ),
          InkWell(
            onTap: () {

            },
            child: DashboardCard(
              title: 'Orders',
              icon: Icons.list,
            ),
          ),
        ],
      ),
    );
  }
}
