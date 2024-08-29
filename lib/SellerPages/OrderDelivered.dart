import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Authentication/Login.dart';
import 'HomeScreen.dart';

class OrderDelivered extends StatefulWidget {
  final String uid;

  OrderDelivered(this.uid);

  @override
  State<OrderDelivered> createState() => _OrderDeliveredState();
}

class _OrderDeliveredState extends State<OrderDelivered> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  String? phone;
  DateTime? selectedDate;

  final TextEditingController _phoneController = TextEditingController();

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
            (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      print("Error signing out: $e");
      // Handle sign out error
    }
  }

  Future<void> _changeDate(String cid) async {
    if (selectedDate != null) {
      // Format the date with both date and time
      final formattedDate = DateFormat('yyyy-MM-dd – HH:mm').format(selectedDate!);
      final oref = FirebaseDatabase.instance.ref('BuyerOrders');
      print(cid);
      await oref.child(cid).update({'date': formattedDate}).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Date Updated')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update date: $error')),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(selectedDate ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<String?> _findKeyForCid(String cid) async {
    final ref = FirebaseDatabase.instance.ref('BuyerOrders');
    final snapshot = await ref.orderByChild('cid').equalTo(cid).once();

    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      final key = data.keys.first; // Get the first key from the snapshot
      return key;
    }
    return null; // Return null if no matching key is found
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final oref = FirebaseDatabase.instance.ref('BuyerOrders');

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
          PopupMenuButton(
            itemBuilder: (context) {
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
            },
            iconSize: height * 0.04,
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
                  "Order Delivered",
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
          SizedBox(height: 15),
          Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: height * 0.05),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black12,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black12,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter your phone number';
                      //   } else if (!RegExp(r'^\+92\d{10}$').hasMatch(value)) {
                      //     return 'Please enter a valid phone number in the format +92 3XXXXXXXXX';
                      //   }
                      //   return null;
                      // },
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          phone = _phoneController.text;
                        });
                      }
                    },
                    icon: Icon(Icons.search_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        phone = null;
                        _phoneController.clear();
                      });
                    },
                    icon: Icon(Icons.cancel_rounded),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: StreamBuilder(
              stream: oref.orderByChild('sid').equalTo(widget.uid).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: buildCircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  List<dynamic> list = map.values.toList();
                  List<dynamic> pendingList = list.where((element) => element['status'].toString().toLowerCase() == 'deliver').toList();
                  List<dynamic> searchList = phone == null
                      ? pendingList
                      : pendingList.where((element) => element['phone'].toString().contains(phone as Pattern)).toList();

                  if (searchList.isEmpty) {
                    return Center(child: Text("No Product Found"));
                  }

                  return ListView.builder(
                    itemCount: searchList.length,
                    itemBuilder: (context, index) {
                      var order = searchList[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                        child: Card(
                          elevation: 10,
                          child: Container(
                            height: phone != null ? height * 0.17 : height * 0.12,
                            padding: EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    order['name'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(order['img'].toString()),
                                  ),
                                  trailing: Padding(
                                    padding: EdgeInsets.only(top: height * 0.01),
                                    child: Column(
                                      children: [
                                        Text('Date: ${order['date']}'),
                                        Text('Quantity: ${order['number']}'),
                                      ],
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Order Delivered\nPhone number: ${order['phone']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (phone != null)
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await _selectDate(context);
                                        if (selectedDate != null) {
                                          final cid = order['cid'];
                                          final key = await _findKeyForCid(cid);
                                          if (key != null) {
                                            await _changeDate(key); // Use the found key here
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Key not found for cid $cid')),
                                            );
                                          }
                                        }
                                      },
                                      child: Text('Change Date'),
                                    ),
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
