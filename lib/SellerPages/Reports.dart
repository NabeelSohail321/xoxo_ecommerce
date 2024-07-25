import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Login.dart';

class Reports extends StatefulWidget {
  final String uid;

  Reports(this.uid);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("BuyerOrders");

  DateTime? _startDate;
  DateTime? _endDate;

  List<Map<dynamic, dynamic>> _filteredData = [];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

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
            children: [
              Expanded(
                child: ListTile(
                  title: Text('Start Date: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Not selected'}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? pickedDate = await _selectDate(context, _startDate, DateTime.now());
                    if (pickedDate != null && (_endDate == null || pickedDate.isBefore(_endDate!))) {
                      setState(() {
                        _startDate = pickedDate;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Start date cannot be after end date')),
                      );
                    }
                  },
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text('End Date: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Not selected'}'),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    DateTime? pickedDate = await _selectDate(context, _endDate, DateTime.now());
                    if (pickedDate != null && (_startDate == null || pickedDate.isAfter(_startDate!))) {
                      setState(() {
                        _endDate = pickedDate;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('End date cannot be before start date')),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              if (_startDate != null && _endDate != null) {
                _filterData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select both start and end dates')),
                );
              }
            },
            child: Text('Filter Data'),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _filteredData.length,
              itemBuilder: (context, index) {
                String name = _filteredData[index]['name'].toString();
                String description = _filteredData[index]['description'].toString();
                String price = _filteredData[index]['price'].toString();
                String img = _filteredData[index]['img'].toString();
                String number = _filteredData[index]['number'].toString();
                String status = _filteredData[index]['status'].toString().toLowerCase();
                String date = _filteredData[index]['date'].toString();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(
                        color: status == 'false' ? Colors.red : Colors.green, // Border color
                        width: 3.0, // Border width
                      ),
                    ),
                    elevation: 10,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(img),
                            ),
                            trailing: Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Date: $date',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  Text(
                                    'Quantity: $number',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                            subtitle: Text(
                              description,
                              style: TextStyle(color: Colors.black, fontSize: 14),
                            ),
                          ),
                          Center(
                            child: Text(
                              status == 'false' ? 'Order Pending' : 'Deliver in 10 to 15 days',
                              style: TextStyle(
                                fontSize: 14,
                                color: status == 'false' ? Colors.red : Colors.green,
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
        ],
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate, DateTime? maxDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: maxDate ?? DateTime(2101),
    );
    return picked;
  }

  void _filterData() async {
    final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
    final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);

    _databaseRef.orderByChild("sid").equalTo(widget.uid).once().then((DatabaseEvent event) {
      Map<dynamic, dynamic> orders = event.snapshot.value as Map<dynamic, dynamic>;
      List<Map<dynamic, dynamic>> filteredOrders = [];

      orders.forEach((key, value) {
        String orderDateStr = value['date'].substring(0, value['date'].length - 4); // Remove the last 4 characters (time part)
        if (orderDateStr.compareTo(startDateStr) >= 0 && orderDateStr.compareTo(endDateStr) <= 0) {
          if (value['status'].toString().toLowerCase() == 'true') {
            filteredOrders.add(value);
          }
        }
      });

      setState(() {
        _filteredData = filteredOrders;
      });
    });
  }
}
