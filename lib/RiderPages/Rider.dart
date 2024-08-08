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
      print("Delivering order with cid: $cid and status: $status");

      if (status == 'true') {
        // Query to find the order by cid
        DataSnapshot snapshot = await oref.orderByChild('cid').equalTo(cid).get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;

          // Find the key for the order to update
          String key = map1.keys.firstWhere((k) => map1[k]['cid'] == cid);

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
              stream: oref.orderByChild('status').equalTo(status1).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData && !_noDataFound) {
                  return Center(
                    child: buildCircularProgressIndicator(),
                  );
                } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
                  if (map == null) {
                    return Center(child: Text("No Orders Found"));
                  }
                  List<dynamic> list = map.values.toList();

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            name = list[index]['name'].toString();
                            description = list[index]['description'].toString();
                            price = list[index]['price'].toString();
                            img = list[index]['img'].toString();
                            number = list[index]['number'].toString();
                            status = list[index]['status'].toString().toLowerCase();
                            date = list[index]['date'];
                            cid = list[index]['cid'];

                            // print(list);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                              child: Card(
                                elevation: 10,
                                child: Container(

                                  height: status == 'true' ?height * 0.17: height*0.15,
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                          padding: EdgeInsets.only(top: height * 0.01),
                                          child: Column(
                                            children: [
                                              Text('date is: $date'),
                                              Text('quantity is: $number'),
                                            ],
                                          ),
                                        ),
                                        subtitle: (status == 'true')
                                            ? Text(
                                          'Order Pending',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
                                        )
                                            : Text(
                                          'Delivered',
                                          style: TextStyle(
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
                                        ),
                                      ),
                                      status == 'true'?
                                      ElevatedButton(
                                          onPressed: () async {
                                            await _AcceptOrders(list,index);
                                          },
                                          child: Text('Deliver ?')):Text('Delivered to Customer')
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
