import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Login.dart';

class cart extends StatefulWidget {
  String uid;

  cart(this.uid);

  @override
  State<cart> createState() => _cartState();
}

class _cartState extends State<cart> {
  final cref = FirebaseDatabase.instance.ref('Cart');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _noDataFound = false;
  double num = 0;
  String? name;
  String? description;
  String? price;
  String? img;
  String? number;



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

  Future<void> _total() async{
    setState(() {
      num=num+((double.tryParse(number!)!)*(double.tryParse(price!)!));
    });
  }


  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
                child: Text("Cart",style: TextStyle(
                  fontSize: height * 0.03,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                ),),
              ),
              Icon(Icons.shopping_cart,size: height*0.03,),
            ],
          ),
Expanded(child: StreamBuilder(
  stream: cref.child(widget.uid).orderByChild('uid').equalTo(widget.uid).onValue,
  builder: (context, AsyncSnapshot<DatabaseEvent> snapshot){
    if(!snapshot.hasData && !_noDataFound){
    return Center(
    child: buildCircularProgressIndicator(),
    );
    } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
    Map<dynamic,dynamic> map=snapshot.data!.snapshot.value as dynamic;
    if (map == null) {
    return Center(child: Text("No Product Found"));
    }
    List<dynamic>? list=[];
    list.clear();
    list=map.values.toList();

    return ListView.builder(itemCount: list.length,
        itemBuilder: ((context, index) {
           name = list![index]['name'].toString();
           description = list[index]['description'].toString();
           price = list[index]['price'].toString();
           img = list[index]['img'].toString();
           number = list[index]['number'];
          _total();

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
            child: Card(
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(8.0),
                // constraints: BoxConstraints(minHeight: 60),
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
                      trailing: Text(number!),
                      subtitle: Text(
                        description!,
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
    }));


    }else {
      return Center(child: Text("No Product Found"));
    }
    },
)),
          Center(child: Text('Total Bill: $num'))
        ],

      ),
    );
  }
    Widget buildCircularProgressIndicator() {
    return CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    );
    }

  }
