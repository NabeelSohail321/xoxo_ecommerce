import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xoxo_ecommerce/SellerPages/FeedBack.dart';
import 'package:xoxo_ecommerce/SellerPages/Orders.dart';
import 'package:xoxo_ecommerce/SellerPages/Product_Management.dart';
import 'package:xoxo_ecommerce/SellerPages/Profile.dart';
import 'package:xoxo_ecommerce/SellerPages/Reports.dart';

import '../Authentication/Login.dart';

class HomeScreen extends StatefulWidget {
  String uid;


  HomeScreen(this.uid);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                return ProductsPage(widget.uid);
              }));
            },
            child: DashboardCard(
              title: 'Product Management',
              icon: Icons.shopping_bag,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Orders(widget.uid);
              },));

            },
            child: DashboardCard(
              title: 'Orders',
              icon: Icons.list_alt,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return FeedBack(widget.uid);
              }));

            },
            child: DashboardCard(
              title: 'Feedback',
              icon: Icons.feedback,
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
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return Reports(widget.uid);
              }));

              
            },
            child: DashboardCard(
              title: 'Reports',
              icon: Icons.bar_chart,
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
                return ProductsPage(widget.uid);
              }));

            },
            child: DashboardCard(
              title: 'Product Management',
              icon: Icons.shopping_bag,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Orders(widget.uid);
              },));
            },
            child: DashboardCard(
              title: 'Orders',
              icon: Icons.list_alt,
            ),
          ),
          InkWell(
            onTap: () {

            },
            child: DashboardCard(
              title: 'Feedback',
              icon: Icons.feedback,
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return ProductsPage(widget.uid);
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
              title: 'Reports',
              icon: Icons.bar_chart,
            ),
          ),
        ],
      ),
    );
  }
}
