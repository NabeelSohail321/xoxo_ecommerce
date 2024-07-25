import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../Authentication/Login.dart';

class cart extends StatefulWidget {
  final String uid;

  cart(this.uid);

  @override
  State<cart> createState() => _cartState();
}

class _cartState extends State<cart> {
  final cref = FirebaseDatabase.instance.ref('Cart');
  final oref = FirebaseDatabase.instance.ref('BuyerOrders');
  final pref = FirebaseDatabase.instance.ref('Products');

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _noDataFound = false;
  double? calculatedTotal;
  String? name;
  String? description;
  String? img;
  String? number;
  String? price;
  String? pid;
  String? date;

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

  double _calculateTotal(List<dynamic> list) {
    double total = 0;
    for (var node in list) {
      total += double.parse(node['price']) * int.parse(node['number']);
    }
    return total;
  }

  Future<void> _updateQuantity(String number, String pid) async {
    DataSnapshot snapshot = await pref.orderByChild('pid').equalTo(pid).get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;
      List<dynamic> list1 = map1.values.toList();

      for (var item in list1) {
        String quantity = item['quantity'].toString();
        if ((int.parse(quantity) - int.parse(number)) > 0) {
          await pref.child(pid).update({
            'quantity': (int.parse(quantity) - int.parse(number)).toString()
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quantity updated.')),
          );
        }
      }
    }
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
                child: Text(
                  "Cart",
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
              stream: cref.child(widget.uid).orderByChild('uid').equalTo(widget.uid).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData && !_noDataFound) {
                  return Center(
                    child: buildCircularProgressIndicator(),
                  );
                } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  if (map == null) {
                    return Center(child: Text("No Product Found"));
                  }
                  List<dynamic> list = map.values.toList();

                  calculatedTotal = _calculateTotal(list);

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
                            date = list[index]['date'];
                            pid = list[index]['pid'];

                            _updateQuantity(number!, pid!);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                              child: Card(
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
                                              Text('Date: $date'),
                                              Text('Quantity: $number')
                                            ],
                                          ),
                                        ),
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
                          },
                        ),
                      ),
                      Center(
                        child: Text(
                          'Total Bill: ${calculatedTotal}',
                          style: TextStyle(fontSize: height * 0.03, fontWeight: FontWeight.bold),
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
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () async {
            final DatabaseService dbService = DatabaseService();
            dbService.moveData('Cart/${widget.uid}', 'BuyerOrders', {'status': 'false'}).then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order placed successfully')),
              );
            });
          },
          child: Icon(Icons.check, size: height * 0.05),
        ),
      ),
    );
  }

  Widget buildCircularProgressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    );
  }
}

class DatabaseService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> moveData(String sourcePath, String destinationPath, Map<dynamic, dynamic> additionalData) async {
    try {
      // Step 1: Read the data from the source reference
      DataSnapshot sourceSnapshot = await _dbRef.child(sourcePath).get();

      if (sourceSnapshot.exists) {
        Map<dynamic, dynamic> sourceData = Map<dynamic, dynamic>.from(sourceSnapshot.value as dynamic);

        // Step 2: Check if the destination path exists
        DataSnapshot destinationSnapshot = await _dbRef.child(destinationPath).get();

        Map<dynamic, dynamic> destinationData = {};
        if (destinationSnapshot.exists) {
          // Destination exists, get existing data
          destinationData = Map<dynamic, dynamic>.from(destinationSnapshot.value as dynamic);
        }

        // Step 3: Append source data to destination with unique key
        sourceData.forEach((key, sourceProduct) async {
          // Generate a new unique key in the destination path
          String newUniqueKey = _dbRef.child(destinationPath).push().key!;

          // Prepare the product data with additional information
          Map<dynamic, dynamic> productData = Map<dynamic, dynamic>.from(sourceProduct);
          productData.addAll(additionalData);

          // If the product already exists in the destination, update the quantity
          if (destinationData.containsKey(key)) {
            Map<dynamic, dynamic> destinationProduct = Map<dynamic, dynamic>.from(destinationData[key] as dynamic);
            int sourceQuantity = (sourceProduct['quantity'] as int?) ?? 0; // Use default 0 if null
            int destinationQuantity = (destinationProduct['quantity'] as int?) ?? 0; // Use default 0 if null
            destinationProduct['quantity'] = destinationQuantity + sourceQuantity;

            // Update product data with the new quantity
            productData['quantity'] = destinationProduct['quantity'];
          }

          // Append the product data with the new unique key
          destinationData[newUniqueKey] = productData;
        });

        // Step 4: Write the updated data to the destination reference
        await _dbRef.child(destinationPath).set(destinationData);

        // Step 5: Optionally, delete the data from the source reference (if necessary)
        await _dbRef.child(sourcePath).remove();

        print('Data moved and quantities updated successfully from $sourcePath to $destinationPath');
      } else {
        print('No data found at $sourcePath');
      }
    } catch (e) {
      print('Failed to move data: $e');
    }
  }
}
