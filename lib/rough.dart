// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:firebase_database/firebase_database.dart';
// // // import 'package:firebase_storage/firebase_storage.dart';
// // // import 'package:flutter/foundation.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:xoxo_ecommerce/Authentication/Login.dart';
// // // import 'package:xoxo_ecommerce/models/signup.dart';
// // // import 'dart:io';
// // //
// // // import 'SellerPages/HomeScreen.dart';
// // //
// // // class Verification extends StatefulWidget {
// // //   final String phoneNumber;
// // //   final String name;
// // //   final String email;
// // //   final String password;
// // //   // final String Url;
// // //   final String role;
// // //   File? file;
// // //   dynamic pickfile;
// // //   // 1 is for seller
// // //   // 2 is for buyer
// // //   // 3 is for ryder
// // //   Verification({
// // //     required this.phoneNumber,
// // //     required this.name,
// // //     required this.email,
// // //     required this.password,
// // //     required this.role,
// // //     required this.file,
// // //     required this.pickfile,
// // //   });
// // //
// // //   @override
// // //   State<Verification> createState() => _VerificationState();
// // // }
// // //
// // // class _VerificationState extends State<Verification> {
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //   final TextEditingController _codeController = TextEditingController();
// // //   String _verificationId = "";
// // //   bool _isLoading = false;
// // //   final dref = FirebaseDatabase.instance.ref("User");
// // //   final storref = FirebaseStorage.instance;
// // //   String? url;
// // //
// // //   String? id;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _verifyPhone();
// // //   }
// // //   Future<void> uploadImage(String id) async {
// // //     try {
// // //       if (widget.file != null || widget.pickfile != null) {
// // //         final imageRef = storref.ref()
// // //             .child("Images/${id}.jpg");
// // //         UploadTask uploadTask;
// // //         if (kIsWeb) {
// // //           final byte = await widget.pickfile.readAsBytes();
// // //           uploadTask = imageRef.putData(byte);
// // //         } else {
// // //           uploadTask = imageRef.putFile(widget.file!);
// // //         }
// // //
// // //         final snapshot = await uploadTask.whenComplete(() {
// // //           ScaffoldMessenger.of(context)
// // //               .showSnackBar(SnackBar(content: Text("Image Uploaded")));
// // //         });
// // //
// // //         url = await snapshot.ref.getDownloadURL();
// // //         print("Image URL: $url");
// // //       }
// // //     } catch (e) {
// // //       print("Error uploading image: $e");
// // //     }
// // //   }
// // //
// // //   void _verifyPhone() async {
// // //     setState(() {
// // //       _isLoading = true;
// // //     });
// // //
// // //     await _auth.verifyPhoneNumber(
// // //       phoneNumber: widget.phoneNumber,
// // //       verificationCompleted: (PhoneAuthCredential credential) async {
// // //         await _auth.signInWithCredential(credential);
// // //         _signUp();
// // //       },
// // //       verificationFailed: (FirebaseAuthException e) {
// // //         setState(() {
// // //           _isLoading = false;
// // //         });
// // //
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('Verification failed. Please try again. $e')),
// // //
// // //         );
// // //         print("Error signing out: $e");
// // //       },
// // //       codeSent: (String verificationId, int? resendToken) {
// // //         setState(() {
// // //           _verificationId = verificationId;
// // //           _isLoading = false;
// // //         });
// // //       },
// // //       codeAutoRetrievalTimeout: (String verificationId) {
// // //         setState(() {
// // //           _verificationId = verificationId;
// // //         });
// // //       },
// // //     );
// // //   }
// // //
// // //   void _signInWithPhoneNumber() async {
// // //     setState(() {
// // //       _isLoading = true;
// // //     });
// // //
// // //     try {
// // //       final AuthCredential credential = PhoneAuthProvider.credential(
// // //         verificationId: _verificationId,
// // //         smsCode: _codeController.text,
// // //       );
// // //
// // //       final User? user = (await _auth.signInWithCredential(credential)).user;
// // //
// // //       if (user != null) {
// // //         _signUp();
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('Sign in failed')),
// // //         );
// // //         setState(() {
// // //           _isLoading = false;
// // //         });
// // //       }
// // //     } catch (e) {
// // //       setState(() {
// // //         _isLoading = false;
// // //       });
// // //
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Error: $e')),
// // //       );
// // //     }
// // //   }
// // //
// // //   void _signUp() async {
// // //
// // //     try {
// // //       UserCredential userCredential =await _auth.createUserWithEmailAndPassword(
// // //         email: widget.email,
// // //         password: widget.password,
// // //       );
// // //       User? user = userCredential.user;
// // //       id = user?.uid;
// // //       await uploadImage(id!);
// // //       SignUp signUp = SignUp(widget.name, widget.email, widget.phoneNumber, widget.password, url!,id!,widget.role);
// // //       await dref.child(id!).set(signUp.tomap()).then((value) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('Sign up successful')),
// // //         );
// // //       }).onError((error, stackTrace) {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('error sigining up $error')),
// // //         );
// // //       });
// // //
// // //
// // //
// // //       Navigator.pushReplacement(
// // //         context,
// // //         MaterialPageRoute(builder: (context) => Login()),
// // //       );
// // //     } on FirebaseAuthException catch (e) {
// // //       if (e.code == 'email-already-in-use') {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('The email address is already in use.')),
// // //         );
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           SnackBar(content: Text('Sign up failed. Please try again.')),
// // //         );
// // //       }
// // //     } catch (e) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Error: $e')),
// // //       );
// // //     }
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final height = MediaQuery.of(context).size.height;
// // //     final width = MediaQuery.of(context).size.width;
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text(
// // //           'Verification',
// // //           style: TextStyle(
// // //             fontSize: height * 0.05,
// // //             fontWeight: FontWeight.bold,
// // //             fontFamily: 'Ubuntu',
// // //           ),
// // //         ),
// // //         centerTitle: true,
// // //         toolbarHeight: height * 0.1,
// // //       ),
// // //       body: SingleChildScrollView(
// // //         child: Container(
// // //           padding: EdgeInsets.symmetric(horizontal: width * 0.1),
// // //           child: Column(
// // //             children: [
// // //               Text(
// // //                 'A verification code has been sent to ${widget.phoneNumber}',
// // //                 textAlign: TextAlign.center,
// // //                 style: TextStyle(fontSize: height * 0.03),
// // //               ),
// // //               SizedBox(height: height * 0.02),
// // //               TextField(
// // //                 controller: _codeController,
// // //                 decoration: InputDecoration(labelText: "Verification Code"),
// // //               ),
// // //               SizedBox(height: height * 0.02),
// // //               _isLoading
// // //                   ? CircularProgressIndicator()
// // //                   : ElevatedButton(
// // //                 onPressed: ()async{
// // //
// // //                   _signInWithPhoneNumber();
// // //
// // //                 },
// // //                 child: Text('Verify'),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// // // class Orders extends StatefulWidget {
// // //   final String uid;
// // //
// // //   Orders(this.uid);
// // //
// // //   @override
// // //   State<Orders> createState() => _OrdersState();
// // // }
// // //
// // // class _OrdersState extends State<Orders> {
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final height = MediaQuery.of(context).size.height;
// // //     final oref = FirebaseDatabase.instance.ref('BuyerOrders');
// // //
// // //     String? name;
// // //     String? description;
// // //     String? img;
// // //     String? number;
// // //     String? price;
// // //     bool _noDataFound = false;
// // //     String? status;
// // //     String? date;
// // //     String? cid;
// // //
// // //     Widget buildCircularProgressIndicator() {
// // //       return CircularProgressIndicator(
// // //         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
// // //       );
// // //     }
// // //
// // //     Future<void> _AcceptOrders(List<dynamic> list, int index) async {
// // //       // Ensure list is not empty and index is valid
// // //       if (list.isNotEmpty && index < list.length) {
// // //         String cid = list[index]['cid'];
// // //         String status = list[index]['status'].toString().toLowerCase();
// // //
// // //         // Debugging output
// // //         print("Accepting order with cid: $cid and status: $status");
// // //
// // //         if (status == 'false') {
// // //           // Query to find the order by cid
// // //           DataSnapshot snapshot = await oref.orderByChild('cid').equalTo(cid).get();
// // //
// // //           if (snapshot.exists) {
// // //             Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;
// // //
// // //             // Find the key for the order to update
// // //             String key = map1.keys.firstWhere((k) => map1[k]['cid'] == cid);
// // //
// // //             // print(key);
// // //             await oref.child(key).update({'status': 'true'}).then((value) {
// // //               ScaffoldMessenger.of(context).showSnackBar(
// // //                 const SnackBar(content: Text('Order accepted. ')),
// // //               );
// // //             });
// // //           } else {
// // //             ScaffoldMessenger.of(context).showSnackBar(
// // //               const SnackBar(content: Text('Order not found.')),
// // //             );
// // //           }
// // //         } else {
// // //           ScaffoldMessenger.of(context).showSnackBar(
// // //             const SnackBar(content: Text('Order already accepted.')),
// // //           );
// // //         }
// // //       } else {
// // //         ScaffoldMessenger.of(context).showSnackBar(
// // //           const SnackBar(content: Text('Invalid order.')),
// // //         );
// // //       }
// // //     }
// // //
// // //
// // //     Future<void> _signOut(BuildContext context) async {
// // //       try {
// // //         await _auth.signOut().then((value) {
// // //           Navigator.pushReplacement(
// // //             context,
// // //             MaterialPageRoute(builder: (context) => Login()), // Navigate to your login screen
// // //           );
// // //         });
// // //       } catch (e) {
// // //         print("Error signing out: $e");
// // //         // Handle sign out error
// // //       }
// // //     }
// // //
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         automaticallyImplyLeading: false,
// // //         title: Text(
// // //           'xoxo',
// // //           style: TextStyle(
// // //             fontSize: height * 0.1,
// // //             fontWeight: FontWeight.bold,
// // //             fontFamily: 'Ubuntu',
// // //           ),
// // //         ),
// // //         centerTitle: true,
// // //         toolbarHeight: height * 0.2,
// // //         actions: [
// // //           Padding(
// // //             padding: EdgeInsets.symmetric(vertical: height * 0.08, horizontal: height * 0.01),
// // //             child: InkWell(
// // //               onTap: () {
// // //                 _signOut(context);
// // //               },
// // //               child: Icon(Icons.logout, size: height * 0.06),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //       body: Column(
// // //         children: [
// // //           Row(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Padding(
// // //                 padding: EdgeInsets.symmetric(horizontal: 8.0),
// // //                 child: Text(
// // //                   "Order List",
// // //                   style: TextStyle(
// // //                     fontSize: height * 0.03,
// // //                     fontWeight: FontWeight.bold,
// // //                     fontFamily: 'Ubuntu',
// // //                   ),
// // //                 ),
// // //               ),
// // //               Icon(Icons.shopping_cart, size: height * 0.03),
// // //             ],
// // //           ),
// // //           Expanded(
// // //             child: StreamBuilder(
// // //               stream: oref.orderByChild('sid').equalTo(widget.uid).onValue,
// // //               builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
// // //                 if (!snapshot.hasData && !_noDataFound) {
// // //                   return Center(
// // //                     child: buildCircularProgressIndicator(),
// // //                   );
// // //                 } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
// // //                   Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
// // //                   if (map == null) {
// // //                     return Center(child: Text("No Product Found"));
// // //                   }
// // //                   List<dynamic> list = map.values.toList();
// // //
// // //                   return Column(
// // //                     children: [
// // //                       Expanded(
// // //                         child: ListView.builder(
// // //                           reverse:  true,
// // //                           itemCount: list.length,
// // //                           itemBuilder: (context, index) {
// // //                             name = list[index]['name'].toString();
// // //                             description = list[index]['description'].toString();
// // //                             price = list[index]['price'].toString();
// // //                             img = list[index]['img'].toString();
// // //                             number = list[index]['number'].toString();
// // //                             status = list[index]['status'].toString().toLowerCase();
// // //                             date = list[index]['date'];
// // //                             cid = list[index]['cid'];
// // //
// // //                             // print(list);
// // //                             return Padding(
// // //                               padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
// // //                               child: Card(
// // //                                 elevation: 10,
// // //                                 child: Container(
// // //
// // //                                   height: status == 'false' ?height * 0.17: height*0.15,
// // //                                   padding: EdgeInsets.all(8.0),
// // //                                   child: Column(
// // //                                     crossAxisAlignment: CrossAxisAlignment.center,
// // //                                     children: [
// // //                                       ListTile(
// // //                                           contentPadding: EdgeInsets.zero,
// // //                                           title: Text(
// // //                                             name!,
// // //                                             style: TextStyle(
// // //                                               fontWeight: FontWeight.bold,
// // //                                             ),
// // //                                           ),
// // //                                           leading: CircleAvatar(
// // //                                             radius: 30,
// // //                                             backgroundImage: NetworkImage(img!),
// // //                                           ),
// // //                                           trailing: Padding(
// // //                                             padding: EdgeInsets.only(top: height * 0.01),
// // //                                             child: Column(
// // //                                               children: [
// // //                                                 Text('date is: $date'),
// // //                                                 Text('quantity is: $number'),
// // //                                               ],
// // //                                             ),
// // //                                           ),
// // //                                           subtitle: (status == 'false')
// // //                                               ? Text(
// // //                                             'Order Pending',
// // //                                             style: TextStyle(
// // //                                               fontSize: 14,
// // //                                             ),
// // //                                             maxLines: 1,
// // //                                             overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
// // //                                           )
// // //                                               : (status=='true')? Text(
// // //                                             'Accepted',
// // //                                             style: TextStyle(
// // //                                               fontSize: 14,
// // //                                             ),
// // //                                             maxLines: 1,
// // //                                             overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
// // //                                           ):Text(
// // //                                             'Delivered',
// // //                                             style: TextStyle(
// // //                                               fontSize: 14,
// // //                                             ),
// // //                                             maxLines: 1,
// // //                                             overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
// // //                                           )
// // //                                       ),
// // //                                       status == 'false'?
// // //                                       ElevatedButton(
// // //                                           onPressed: () async {
// // //                                             await _AcceptOrders(list,index);
// // //                                           },
// // //                                           child: Text('Accept')):(status=='true')?Text('Will be delivered in 10 to 15 days'):Text('delivered')
// // //                                     ],
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             );
// // //                           },
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   );
// // //                 } else {
// // //                   return Center(child: Text("No Product Found"));
// // //                 }
// // //               },
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// //
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:firebase_database/firebase_database.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:fl_chart/fl_chart.dart';
// // //
// // // import '../Authentication/Login.dart';
// // // import 'HomeScreen.dart';
// // //
// // // class Reports extends StatefulWidget {
// // //   final String uid;
// // //
// // //   Reports(this.uid);
// // //
// // //   @override
// // //   _ReportsState createState() => _ReportsState();
// // // }
// // //
// // // class _ReportsState extends State<Reports> {
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("BuyerOrders");
// // //
// // //   DateTime? _startDate;
// // //   DateTime? _endDate;
// // //
// // //   double? profitloss;
// // //   List<Map<dynamic, dynamic>> _filteredData = [];
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final height = MediaQuery.of(context).size.height;
// // //
// // //     double _calculateTotal(List<dynamic> list) {
// // //       double total = 0;
// // //       for (var node in list) {
// // //         total += (double.parse(node['price']) - double.parse(node['buying'])) * int.parse(node['number']);
// // //       }
// // //       return total;
// // //     }
// // //
// // //     Future<void> _signOut(BuildContext context) async {
// // //       try {
// // //         await _auth.signOut().then((value) {
// // //           Navigator.pushReplacement(
// // //             context,
// // //             MaterialPageRoute(builder: (context) => Login()), // Navigate to your login screen
// // //           );
// // //         });
// // //       } catch (e) {
// // //         print("Error signing out: $e");
// // //         // Handle sign out error
// // //       }
// // //     }
// // //
// // //     if (_filteredData.isNotEmpty) {
// // //       profitloss = _calculateTotal(_filteredData);
// // //     }
// // //
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         automaticallyImplyLeading: false,
// // //         title: Text(
// // //           'Reports',
// // //           style: TextStyle(
// // //             fontSize: height * 0.03,
// // //             fontWeight: FontWeight.bold,
// // //             fontFamily: 'Ubuntu',
// // //           ),
// // //         ),
// // //         centerTitle: true,
// // //         toolbarHeight: height * 0.1,
// // //         actions: [
// // //           // Padding(
// // //           //   padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: height * 0.01),
// // //           //   child: InkWell(
// // //           //     onTap: () {
// // //           //       _signOut(context);
// // //           //     },
// // //           //     child: Icon(Icons.logout, size: height * 0.03),
// // //           //   ),
// // //           // ),
// // //           PopupMenuButton(itemBuilder: (context) {
// // //             return [
// // //               PopupMenuItem(
// // //                 child: Icon(Icons.logout),
// // //                 onTap: () {
// // //                   _signOut(context);
// // //                 },
// // //               ),
// // //               PopupMenuItem(
// // //                 child: Icon(Icons.home),
// // //                 onTap: () {
// // //                   Navigator.push(context, MaterialPageRoute(builder: (context) {
// // //                     return HomeScreen(widget.uid);
// // //                   }));
// // //                 },
// // //               )
// // //             ];
// // //           }, iconSize: height * 0.04),
// // //
// // //         ],
// // //       ),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(8.0),
// // //         child: Column(
// // //           children: [
// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: ListTile(
// // //                     title: Text(
// // //                       'Start Date: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Not selected'}',
// // //                       style: TextStyle(fontSize: height * 0.02),
// // //                     ),
// // //                     trailing: Icon(Icons.calendar_today, size: height * 0.03),
// // //                     onTap: () async {
// // //                       DateTime? pickedDate = await _selectDate(context, _startDate, DateTime.now());
// // //                       if (pickedDate != null && (_endDate == null || pickedDate.isBefore(_endDate!))) {
// // //                         setState(() {
// // //                           _startDate = pickedDate;
// // //                         });
// // //                       } else {
// // //                         ScaffoldMessenger.of(context).showSnackBar(
// // //                           SnackBar(content: Text('Start date cannot be after end date')),
// // //                         );
// // //                       }
// // //                     },
// // //                   ),
// // //                 ),
// // //                 Expanded(
// // //                   child: ListTile(
// // //                     title: Text(
// // //                       'End Date: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Not selected'}',
// // //                       style: TextStyle(fontSize: height * 0.02),
// // //                     ),
// // //                     trailing: Icon(Icons.calendar_today, size: height * 0.03),
// // //                     onTap: () async {
// // //                       DateTime? pickedDate = await _selectDate(context, _endDate, DateTime.now());
// // //                       if (pickedDate != null && (_startDate == null || pickedDate.isAfter(_startDate!))) {
// // //                         setState(() {
// // //                           _endDate = pickedDate;
// // //                         });
// // //                       } else {
// // //                         ScaffoldMessenger.of(context).showSnackBar(
// // //                           SnackBar(content: Text('End date cannot be before start date')),
// // //                         );
// // //                       }
// // //                     },
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             ElevatedButton(
// // //               onPressed: () {
// // //                 if (_startDate != null && _endDate != null) {
// // //                   _filterData();
// // //                 } else {
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     SnackBar(content: Text('Please select both start and end dates')),
// // //                   );
// // //                 }
// // //               },
// // //               child: Text('Filter Data'),
// // //             ),
// // //             if (profitloss != null)
// // //               Padding(
// // //                 padding: const EdgeInsets.all(8.0),
// // //                 child: Text(
// // //                   'Profit/Loss: $profitloss',
// // //                   style: TextStyle(fontSize: height * 0.025, fontWeight: FontWeight.bold),
// // //                 ),
// // //               ),
// // //             Padding(
// // //               padding: const EdgeInsets.all(8.0),
// // //               child: Container(
// // //                 height: height * 0.3,
// // //                 child: _buildChart(),
// // //               ),
// // //             ),
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: _filteredData.length,
// // //                 itemBuilder: (context, index) {
// // //                   String name = _filteredData[index]['name'].toString();
// // //                   String description = _filteredData[index]['description'].toString();
// // //                   String sellingPrice = _filteredData[index]['price'].toString();
// // //                   String img = _filteredData[index]['img'].toString();
// // //                   String number = _filteredData[index]['number'].toString();
// // //                   String status = _filteredData[index]['status'].toString().toLowerCase();
// // //                   String date = _filteredData[index]['date'].toString();
// // //                   double buying = double.parse(_filteredData[index]['buying'].toString());
// // //
// // //                   return Padding(
// // //                     padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
// // //                     child: Card(
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(15.0),
// // //                         side: BorderSide(
// // //                           color: status == 'false' ? Colors.red : Colors.green, // Border color
// // //                           width: 3.0, // Border width
// // //                         ),
// // //                       ),
// // //                       elevation: 10,
// // //                       child: Container(
// // //                         padding: EdgeInsets.all(8.0),
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             ListTile(
// // //                               contentPadding: EdgeInsets.zero,
// // //                               title: Text(
// // //                                 name,
// // //                                 style: TextStyle(
// // //                                   fontWeight: FontWeight.bold,
// // //                                   fontSize: height * 0.02,
// // //                                 ),
// // //                               ),
// // //                               leading: CircleAvatar(
// // //                                 radius: height * 0.04,
// // //                                 backgroundImage: NetworkImage(img),
// // //                               ),
// // //                               trailing: Padding(
// // //                                 padding: const EdgeInsets.only(top: 10.0),
// // //                                 child: Column(
// // //                                   crossAxisAlignment: CrossAxisAlignment.end,
// // //                                   children: [
// // //                                     Text(
// // //                                       'Date: $date',
// // //                                       style: TextStyle(color: Colors.black, fontSize: height * 0.015),
// // //                                     ),
// // //                                     Text(
// // //                                       'Quantity: $number',
// // //                                       style: TextStyle(color: Colors.black, fontSize: height * 0.015),
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                               subtitle: Text(
// // //                                 description,
// // //                                 style: TextStyle(color: Colors.black, fontSize: height * 0.017,overflow: TextOverflow.ellipsis),
// // //                               ),
// // //                             ),
// // //                             Center(
// // //                               child: (status == 'deliver')
// // //                                   ? Text(
// // //                                 'Delivered',
// // //                                 style: TextStyle(
// // //                                   fontSize: height * 0.017,
// // //                                   color: status == 'false' ? Colors.red : Colors.green,
// // //                                 ),
// // //                                 maxLines: 1,
// // //                                 overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
// // //                               )
// // //                                   : Text('Pending', style: TextStyle(fontSize: height * 0.017)),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate, DateTime? maxDate) async {
// // //     final DateTime? picked = await showDatePicker(
// // //       context: context,
// // //       initialDate: initialDate ?? DateTime.now(),
// // //       firstDate: DateTime(2000),
// // //       lastDate: maxDate ?? DateTime(2101),
// // //     );
// // //     return picked;
// // //   }
// // //
// // //   void _filterData() async {
// // //     final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
// // //     final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);
// // //
// // //     _databaseRef.orderByChild("sid").equalTo(widget.uid).once().then((DatabaseEvent event) {
// // //       Map<dynamic, dynamic> orders = event.snapshot.value as Map<dynamic, dynamic>;
// // //       List<Map<dynamic, dynamic>> filteredOrders = [];
// // //
// // //       orders.forEach((key, value) {
// // //         String orderDateStr = value['date'].substring(0, value['date'].length - 4); // Remove the last 4 characters (time part)
// // //         if (orderDateStr.compareTo(startDateStr) >= 0 && orderDateStr.compareTo(endDateStr) <= 0) {
// // //           if (value['status'].toString().toLowerCase() == 'deliver') {
// // //             filteredOrders.add(value);
// // //           }
// // //         }
// // //       });
// // //
// // //       setState(() {
// // //         _filteredData = filteredOrders;
// // //       });
// // //     });
// // //   }
// // //
// // //   Widget _buildChart() {
// // //     if (_filteredData.isEmpty) {
// // //       return Container(); // Return empty container if there is no data
// // //     }
// // //
// // //     List<FlSpot> spots = [];
// // //     List<String> dates = [];
// // //
// // //     for (int i = 0; i < _filteredData.length; i++) {
// // //       double x = i.toDouble();
// // //       double y = (double.parse(_filteredData[i]['price']) - double.parse(_filteredData[i]['buying'])) * int.parse(_filteredData[i]['number']);
// // //       spots.add(FlSpot(x, y));
// // //       dates.add(_filteredData[i]['date'].substring(8, _filteredData[i]['date'].length - 8));
// // //     }
// // //
// // //     return Padding(
// // //       padding: const EdgeInsets.all(8.0),
// // //       child: SizedBox(
// // //         height: 200,
// // //         child: LineChart(
// // //           LineChartData(
// // //             gridData: FlGridData(
// // //               show: true,
// // //               drawVerticalLine: true,
// // //               getDrawingHorizontalLine: (value) {
// // //                 return FlLine(
// // //                   color: const Color(0xffe7e8ec),
// // //                   strokeWidth: 1,
// // //                 );
// // //               },
// // //               getDrawingVerticalLine: (value) {
// // //                 return FlLine(
// // //                   color: const Color(0xffe7e8ec),
// // //                   strokeWidth: 1,
// // //                 );
// // //               },
// // //             ),
// // //             borderData: FlBorderData(
// // //               show: true,
// // //               border: Border.all(color: const Color(0xffe7e8ec), width: 1),
// // //             ),
// // //             lineBarsData: [
// // //               LineChartBarData(
// // //                 spots: spots,
// // //                 isCurved: true,
// // //                 barWidth: 2,
// // //                 color: Colors.blue,
// // //                 belowBarData: BarAreaData(show: false),
// // //                 dotData: FlDotData(show: false),
// // //               ),
// // //             ],
// // //             titlesData: FlTitlesData(
// // //               leftTitles: AxisTitles(
// // //                 sideTitles: SideTitles(
// // //                   showTitles: true,
// // //                   reservedSize: 40,
// // //                   getTitlesWidget: (value, meta) {
// // //                     return SideTitleWidget(
// // //                       axisSide: meta.axisSide,
// // //                       space: 4.0,
// // //                       child: Text(
// // //                         value.toString(),
// // //                         style: const TextStyle(fontSize: 10),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //                 axisNameWidget: Text(
// // //                   'Profit',
// // //                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
// // //                 ),
// // //                 axisNameSize: 20,
// // //               ),
// // //               bottomTitles: AxisTitles(
// // //                 sideTitles: SideTitles(
// // //                   showTitles: true,
// // //                   reservedSize: 40,
// // //                   getTitlesWidget: (value, meta) {
// // //                     final index = value.toInt();
// // //                     if (index >= 0 && index < dates.length) {
// // //                       return SideTitleWidget(
// // //                         axisSide: meta.axisSide,
// // //                         space: 4.0,
// // //                         child: Text(
// // //                           dates[index],
// // //                           style: const TextStyle(fontSize: 10),
// // //                         ),
// // //                       );
// // //                     } else {
// // //                       return Container();
// // //                     }
// // //                   },
// // //                 ),
// // //                 axisNameWidget: Text(
// // //                   'Date',
// // //                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
// // //                 ),
// // //                 axisNameSize: 20,
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// //
// //
// // // if (status == 'false') {
// // // // Query to find the order by cid
// // // DataSnapshot snapshot = await oref.orderByChild('cid').equalTo(cid).get();
// // //
// // // if (snapshot.exists) {
// // // Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;
// // //
// // // // Find the key for the order to update
// // // String key = map1.keys.firstWhere((k) => map1[k]['cid'] == cid);
// // //
// // // await oref.child(key).update({'status': 'true'}).then((value) {
// // // ScaffoldMessenger.of(context).showSnackBar(
// // // const SnackBar(content: Text('Order accepted.')),
// // // );
// // // });
// // // } else {
// // // ScaffoldMessenger.of(context).showSnackBar(
// // // const SnackBar(content: Text('Order not found.')),
// // // );
// // // }
// // // } else {
// // // ScaffoldMessenger.of(context).showSnackBar(
// // // const SnackBar(content: Text('Order already accepted.')),
// // // );
// // // }
// //
// //
// //
// // //
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:firebase_database/firebase_database.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:intl/intl.dart';
// // // import 'package:fl_chart/fl_chart.dart';
// // // import 'package:pdf/widgets.dart' as pw;
// // // import 'package:pdf/pdf.dart';
// // // import 'dart:io';
// // // import 'package:path_provider/path_provider.dart';
// // // import '../Authentication/Login.dart';
// // // import 'HomeScreen.dart';
// // //
// // // class Reports extends StatefulWidget {
// // //   final String uid;
// // //
// // //   Reports(this.uid);
// // //
// // //   @override
// // //   _ReportsState createState() => _ReportsState();
// // // }
// // //
// // // class _ReportsState extends State<Reports> {
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("BuyerOrders");
// // //   final DatabaseReference _productRef = FirebaseDatabase.instance.ref("Products");
// // //   DateTime? _startDate;
// // //   DateTime? _endDate;
// // //   int totalLength = 0;
// // //
// // //   double? profitloss;
// // //   List<Map<dynamic, dynamic>> _filteredData = [];
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final height = MediaQuery.of(context).size.height;
// // //
// // //     Future<double> _calculateTotal(List<dynamic> list) async {
// // //       double total = 0;
// // //       setState(() {
// // //         totalLength = list.length;
// // //       });
// // //       for (var node in list) {
// // //         String pid = node['pid'];
// // //         double buyingPrice = 0;
// // //
// // //         await _productRef.child(pid).get().then((DataSnapshot snapshot) {
// // //           if (snapshot.exists) {
// // //             buyingPrice = double.parse(snapshot.child('buying').value.toString());
// // //           }
// // //         });
// // //
// // //         total += (double.parse(node['price']) - buyingPrice) * int.parse(node['number']);
// // //       }
// // //       return total;
// // //     }
// // //
// // //     Future<void> _signOut(BuildContext context) async {
// // //       try {
// // //         await _auth.signOut().then((value) {
// // //           Navigator.pushReplacement(
// // //             context,
// // //             MaterialPageRoute(builder: (context) => Login()), // Navigate to your login screen
// // //           );
// // //         });
// // //       } catch (e) {
// // //         print("Error signing out: $e");
// // //         // Handle sign out error
// // //       }
// // //     }
// // //
// // //     if (_filteredData.isNotEmpty) {
// // //       _calculateTotal(_filteredData).then((value) {
// // //         setState(() {
// // //           profitloss = value;
// // //         });
// // //       });
// // //     }
// // //
// // //     Future<void> _generatePdf() async {
// // //       final pdf = pw.Document();
// // //       final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
// // //       final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);
// // //
// // //       pdf.addPage(
// // //         pw.Page(
// // //           build: (pw.Context context) {
// // //             return pw.Column(
// // //               crossAxisAlignment: pw.CrossAxisAlignment.start,
// // //               children: [
// // //                 pw.Text('XOXO Commerce', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
// // //                 pw.SizedBox(height: 20),
// // //                 pw.Text('Reports', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
// // //                 pw.SizedBox(height: 10),
// // //                 pw.Text('Start Date: $startDateStr'),
// // //                 pw.Text('End Date: $endDateStr'),
// // //                 pw.SizedBox(height: 10),
// // //                 pw.Text('Total Orders: $totalLength'),
// // //                 pw.Text('Profit/Loss: $profitloss'),
// // //               ],
// // //             );
// // //           },
// // //         ),
// // //       );
// // //
// // //       final output = await getTemporaryDirectory();
// // //       final file = File("${output.path}/report.pdf");
// // //       await file.writeAsBytes(await pdf.save());
// // //
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('PDF generated!')),
// // //       );
// // //
// // //       // Display the PDF
// // //       Navigator.push(
// // //         context,
// // //         MaterialPageRoute(builder: (context) => PdfViewerScreen(file)),
// // //       );
// // //     }
// // //
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         automaticallyImplyLeading: false,
// // //         title: Text(
// // //           'Reports',
// // //           style: TextStyle(
// // //             fontSize: height * 0.03,
// // //             fontWeight: FontWeight.bold,
// // //             fontFamily: 'Ubuntu',
// // //           ),
// // //         ),
// // //         centerTitle: true,
// // //         toolbarHeight: height * 0.1,
// // //         actions: [
// // //           PopupMenuButton(itemBuilder: (context) {
// // //             return [
// // //               PopupMenuItem(
// // //                 child: Icon(Icons.logout),
// // //                 onTap: () {
// // //                   _signOut(context);
// // //                 },
// // //               ),
// // //               PopupMenuItem(
// // //                 child: Icon(Icons.home),
// // //                 onTap: () {
// // //                   Navigator.push(context, MaterialPageRoute(builder: (context) {
// // //                     return HomeScreen(widget.uid);
// // //                   }));
// // //                 },
// // //               )
// // //             ];
// // //           }, iconSize: height * 0.04),
// // //         ],
// // //       ),
// // //       body: Padding(
// // //         padding: const EdgeInsets.all(8.0),
// // //         child: Column(
// // //           children: [
// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: ListTile(
// // //                     title: Text(
// // //                       'Start Date: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Not selected'}',
// // //                       style: TextStyle(fontSize: height * 0.02),
// // //                     ),
// // //                     trailing: Icon(Icons.calendar_today, size: height * 0.03),
// // //                     onTap: () async {
// // //                       DateTime? pickedDate = await _selectDate(context, _startDate, DateTime.now());
// // //                       if (pickedDate != null && (_endDate == null || pickedDate.isBefore(_endDate!))) {
// // //                         setState(() {
// // //                           _startDate = pickedDate;
// // //                         });
// // //                       } else {
// // //                         ScaffoldMessenger.of(context).showSnackBar(
// // //                           SnackBar(content: Text('Start date cannot be after end date')),
// // //                         );
// // //                       }
// // //                     },
// // //                   ),
// // //                 ),
// // //                 Expanded(
// // //                   child: ListTile(
// // //                     title: Text(
// // //                       'End Date: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Not selected'}',
// // //                       style: TextStyle(fontSize: height * 0.02),
// // //                     ),
// // //                     trailing: Icon(Icons.calendar_today, size: height * 0.03),
// // //                     onTap: () async {
// // //                       DateTime? pickedDate = await _selectDate(context, _endDate, DateTime.now());
// // //                       if (pickedDate != null && (_startDate == null || pickedDate.isAfter(_startDate!))) {
// // //                         setState(() {
// // //                           _endDate = pickedDate;
// // //                         });
// // //                       } else {
// // //                         ScaffoldMessenger.of(context).showSnackBar(
// // //                           SnackBar(content: Text('End date cannot be before start date')),
// // //                         );
// // //                       }
// // //                     },
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //             ElevatedButton(
// // //               onPressed: () {
// // //                 if (_startDate != null && _endDate != null) {
// // //                   _filterData();
// // //                 } else {
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     SnackBar(content: Text('Please select both start and end dates')),
// // //                   );
// // //                 }
// // //               },
// // //               child: Text('Filter Data'),
// // //             ),
// // //             if (_filteredData.isNotEmpty) ...[
// // //               ElevatedButton(
// // //                 onPressed: _generatePdf,
// // //                 child: Text('Generate PDF'),
// // //               ),
// // //               Padding(
// // //                 padding: const EdgeInsets.all(8.0),
// // //                 child: Text(
// // //                   'Profit/Loss: $profitloss',
// // //                   style: TextStyle(fontSize: height * 0.025, fontWeight: FontWeight.bold),
// // //                 ),
// // //               ),
// // //               Padding(
// // //                 padding: const EdgeInsets.all(8.0),
// // //                 child: Container(
// // //                   height: height * 0.3,
// // //                   child: _buildChart(),
// // //                 ),
// // //               ),
// // //             ],
// // //             Expanded(
// // //               child: ListView.builder(
// // //                 itemCount: _filteredData.length,
// // //                 itemBuilder: (context, index) {
// // //                   String name = _filteredData[index]['name'].toString();
// // //                   String description = _filteredData[index]['description'].toString();
// // //                   String sellingPrice = _filteredData[index]['price'].toString();
// // //                   String img = _filteredData[index]['img'].toString();
// // //                   String number = _filteredData[index]['number'].toString();
// // //                   String status = _filteredData[index]['status'].toString().toLowerCase();
// // //                   String date = _filteredData[index]['date'].toString();
// // //                   double buying = double.parse(_filteredData[index]['buying'].toString());
// // //
// // //                   return Padding(
// // //                     padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
// // //                     child: Card(
// // //                       shape: RoundedRectangleBorder(
// // //                         borderRadius: BorderRadius.circular(15.0),
// // //                         side: BorderSide(
// // //                           color: status == 'false' ? Colors.red : Colors.green, // Border color
// // //                           width: 3.0, // Border width
// // //                         ),
// // //                       ),
// // //                       elevation: 10,
// // //                       child: Container(
// // //                         padding: EdgeInsets.all(8.0),
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             ListTile(
// // //                               contentPadding: EdgeInsets.zero,
// // //                               title: Text(
// // //                                 name,
// // //                                 style: TextStyle(
// // //                                   fontWeight: FontWeight.bold,
// // //                                   fontSize: height * 0.02,
// // //                                 ),
// // //                               ),
// // //                               leading: CircleAvatar(
// // //                                 radius: height * 0.04,
// // //                                 backgroundImage: NetworkImage(img),
// // //                               ),
// // //                               trailing: Padding(
// // //                                 padding: const EdgeInsets.only(top: 10.0),
// // //                                 child: Column(
// // //                                   crossAxisAlignment: CrossAxisAlignment.end,
// // //                                   children: [
// // //                                     Text(
// // //                                       'Date: $date',
// // //                                       style: TextStyle(color: Colors.black, fontSize: height * 0.015),
// // //                                     ),
// // //                                     Text(
// // //                                       'Quantity: $number',
// // //                                       style: TextStyle(color: Colors.black, fontSize: height * 0.015),
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                               subtitle: Text(
// // //                                 description,
// // //                                 style: TextStyle(color: Colors.black, fontSize: height * 0.017, overflow: TextOverflow.ellipsis),
// // //                               ),
// // //                             ),
// // //                             Center(
// // //                               child: (status == 'deliver')
// // //                                   ? Text(
// // //                                 'Delivered',
// // //                                 style: TextStyle(
// // //                                   fontSize: height * 0.017,
// // //                                   color: status == 'false' ? Colors.red : Colors.green,
// // //                                 ),
// // //                                 maxLines: 1,
// // //                                 overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
// // //                               )
// // //                                   : Text('Pending', style: TextStyle(fontSize: height * 0.017)),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate, DateTime? maxDate) async {
// // //     final DateTime? picked = await showDatePicker(
// // //       context: context,
// // //       initialDate: initialDate ?? DateTime.now(),
// // //       firstDate: DateTime(2000),
// // //       lastDate: maxDate ?? DateTime(2101),
// // //     );
// // //     return picked;
// // //   }
// // //
// // //   void _filterData() async {
// // //     final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
// // //     final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);
// // //
// // //     _databaseRef.orderByChild("sid").equalTo(widget.uid).once().then((DatabaseEvent event) {
// // //       Map<dynamic, dynamic> orders = event.snapshot.value as Map<dynamic, dynamic>;
// // //       List<Map<dynamic, dynamic>> filteredOrders = [];
// // //
// // //       orders.forEach((key, value) {
// // //         String orderDateStr = value['date'].substring(0, value['date'].length - 4); // Remove the last 4 characters (time part)
// // //         if (orderDateStr.compareTo(startDateStr) >= 0 && orderDateStr.compareTo(endDateStr) <= 0) {
// // //           if (value['status'].toString().toLowerCase() == 'deliver') {
// // //             filteredOrders.add(value);
// // //           }
// // //         }
// // //       });
// // //
// // //       setState(() {
// // //         _filteredData = filteredOrders;
// // //       });
// // //     });
// // //   }
// // //
// // //   Widget _buildChart() {
// // //     if (_filteredData.isEmpty) {
// // //       return Container(); // Return empty container if there is no data
// // //     }
// // //
// // //     List<FlSpot> spots = [];
// // //     List<String> dates = [];
// // //
// // //     for (int i = 0; i < _filteredData.length; i++) {
// // //       double x = i.toDouble();
// // //       double y = (double.parse(_filteredData[i]['price']) - double.parse(_filteredData[i]['buying'])) * int.parse(_filteredData[i]['number']);
// // //       spots.add(FlSpot(x, y));
// // //       dates.add(_filteredData[i]['date'].substring(8, _filteredData[i]['date'].length - 8));
// // //     }
// // //
// // //     return Padding(
// // //       padding: const EdgeInsets.all(8.0),
// // //       child: SizedBox(
// // //         height: MediaQuery.of(context).size.height * 0.3,
// // //         child: LineChart(
// // //           LineChartData(
// // //             gridData: FlGridData(
// // //               show: true,
// // //               drawVerticalLine: true,
// // //               getDrawingHorizontalLine: (value) {
// // //                 return FlLine(
// // //                   color: const Color(0xffe7e8ec),
// // //                   strokeWidth: 1,
// // //                 );
// // //               },
// // //               getDrawingVerticalLine: (value) {
// // //                 return FlLine(
// // //                   color: const Color(0xffe7e8ec),
// // //                   strokeWidth: 1,
// // //                 );
// // //               },
// // //             ),
// // //             borderData: FlBorderData(
// // //               show: true,
// // //               border: Border.all(color: const Color(0xffe7e8ec), width: 1),
// // //             ),
// // //             lineBarsData: [
// // //               LineChartBarData(
// // //                 spots: spots,
// // //                 isCurved: true,
// // //                 barWidth: 2,
// // //                 color: Colors.blue,
// // //                 belowBarData: BarAreaData(show: false),
// // //                 dotData: FlDotData(show: false),
// // //               ),
// // //             ],
// // //             titlesData: FlTitlesData(
// // //               leftTitles: AxisTitles(
// // //                 sideTitles: SideTitles(
// // //                   showTitles: true,
// // //                   reservedSize: 40,
// // //                   getTitlesWidget: (value, meta) {
// // //                     return SideTitleWidget(
// // //                       axisSide: meta.axisSide,
// // //                       space: 4.0,
// // //                       child: Text(
// // //                         value.toString(),
// // //                         style: const TextStyle(fontSize: 10),
// // //                       ),
// // //                     );
// // //                   },
// // //                 ),
// // //                 axisNameWidget: Text(
// // //                   'Profit',
// // //                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
// // //                 ),
// // //                 axisNameSize: 20,
// // //               ),
// // //               bottomTitles: AxisTitles(
// // //                 sideTitles: SideTitles(
// // //                   showTitles: true,
// // //                   reservedSize: 40,
// // //                   getTitlesWidget: (value, meta) {
// // //                     final index = value.toInt();
// // //                     if (index >= 0 && index < dates.length) {
// // //                       return SideTitleWidget(
// // //                         axisSide: meta.axisSide,
// // //                         space: 4.0,
// // //                         child: Text(
// // //                           dates[index],
// // //                           style: const TextStyle(fontSize: 10),
// // //                         ),
// // //                       );
// // //                     } else {
// // //                       return Container();
// // //                     }
// // //                   },
// // //                 ),
// // //                 axisNameWidget: Text(
// // //                   'Date',
// // //                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
// // //                 ),
// // //                 axisNameSize: 20,
// // //               ),
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class PdfViewerScreen extends StatelessWidget {
// // //   final File pdfFile;
// // //
// // //   PdfViewerScreen(this.pdfFile);
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     // Implement your PDF viewer logic here, you can use a package like 'flutter_pdfview' or 'advance_pdf_viewer'
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text('PDF Viewer'),
// // //       ),
// // //       body: Center(
// // //         child: Text('Display the PDF here using a suitable package'),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// //
// // import 'dart:async';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_database/firebase_database.dart';
// // import 'package:flutter/material.dart';
// // import 'package:geolocator/geolocator.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// // import 'package:intl/intl.dart';
// // import '../Authentication/Login.dart';
// //
// // class cart extends StatefulWidget {
// //   final String uid;
// //
// //   cart(this.uid);
// //
// //   @override
// //   State<cart> createState() => _cartState();
// // }
// //
// // class _cartState extends State<cart> {
// //   final cref = FirebaseDatabase.instance.ref('Cart');
// //   final oref = FirebaseDatabase.instance.ref('BuyerOrders');
// //   final pref = FirebaseDatabase.instance.ref('Products');
// //   final userRef = FirebaseDatabase.instance.ref('User');
// //   String? phone;
// //   double deliveryCharges=0;
// //   late LatLng _userPosition;
// //   LatLng _wareHousePosition = LatLng(32.09378, 74.18540);
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //   bool _noDataFound = false;
// //   double? calculatedTotal;
// //   double? subtotal;
// //   String? name;
// //   String? description;
// //   String? img;
// //   String? number;
// //   String? price;
// //   String? pid;
// //   String? date;
// //   double distance=0;
// //
// //   List<Map<String, String>> quantity = [];
// //
// //   Future<void> _signOut(BuildContext context) async {
// //     try {
// //       await _auth.signOut();
// //       Navigator.pushAndRemoveUntil(
// //         context,
// //         MaterialPageRoute(builder: (context) => Login()),
// //             (Route<dynamic> route) => false, // Remove all previous routes
// //       );
// //     } catch (e) {
// //       print("Error signing out: $e");
// //       // Handle sign out error
// //     }
// //   }
// //
// //   Future<String?> getUserPhone(String userId) async {
// //     final snapshot = await userRef.child(userId).get();
// //     if (snapshot.exists) {
// //       final data = snapshot.value as Map<dynamic, dynamic>;
// //       return data['phone'] as String?;
// //     }
// //     return null;
// //   }
// //
// //   Future<void> _calculatedeliveryCharges(String uid) async {
// //     try {
// //       final snapshot = await userRef.child(uid).get();
// //       if (snapshot.exists) {
// //         Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;
// //
// //         // Check and parse latitude and longitude as double
// //         double latitude = map['latitude'] is double
// //             ? map['latitude']
// //             : double.tryParse(map['latitude'].toString()) ?? 0.0;
// //         double longitude = map['longitude'] is double
// //             ? map['longitude']
// //             : double.tryParse(map['longitude'].toString()) ?? 0.0;
// //
// //         setState(() {
// //           _userPosition = LatLng(latitude, longitude);
// //         });
// //
// //         setState(() {
// //           distance = Geolocator.distanceBetween(
// //             _userPosition.latitude,
// //             _userPosition.longitude,
// //             _wareHousePosition.latitude,
// //             _wareHousePosition.longitude,
// //           );
// //         });
// //
// //         if (distance >= 3000) {
// //           setState(() {
// //             deliveryCharges += ((distance-3000) / 1000) * 100;
// //           });
// //         }
// //       } else {
// //         print("User data not found.");
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('User data not found')),
// //         );
// //       }
// //     } catch (e) {
// //       print("Failed to calculate delivery charges: $e");
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Error calculating delivery charges: $e')),
// //       );
// //     }
// //   }
// //
// //   double _calculateTotal(List<dynamic> list) {
// //     double total = 0;
// //     for (var node in list) {
// //       total += double.parse(node['price']) * int.parse(node['number']);
// //     }
// //     total=total+deliveryCharges;
// //
// //     return total;
// //   }
// //   double _calculatesubTotal(List<dynamic> list) {
// //     double total = 0;
// //     for (var node in list) {
// //       total += double.parse(node['price']) * int.parse(node['number']);
// //     }
// //
// //
// //     return total;
// //   }
// //
// //   Future<void> _updateQuantity(String number, String pid) async {
// //     DataSnapshot snapshot = await pref.child(pid).get();
// //
// //     if (snapshot.exists) {
// //       Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;
// //
// //       String quantity = map1['quantity'].toString();
// //       if ((int.parse(quantity) - int.parse(number)) > 0) {
// //         await pref.child(pid).update({
// //           'quantity': (int.parse(quantity) - int.parse(number)).toString()
// //         });
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('Quantity updated.')),
// //         );
// //       }
// //     }
// //   }
// //
// //   Future<void> _removeFromCart(String uid, String pid) async {
// //     await cref.child(uid).child(pid).remove();
// //     setState(() {
// //       quantity.removeWhere((item) => item['pid'] == pid);
// //     });
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       const SnackBar(content: Text('Product removed from cart.')),
// //     );
// //   }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _calculatedeliveryCharges(widget.uid);
// //     getUserPhone(widget.uid).then((fetchedPhone) {
// //       setState(() {
// //         phone = fetchedPhone;
// //       });
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final height = MediaQuery.of(context).size.height;
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         automaticallyImplyLeading: false,
// //         title: Text(
// //           'xoxo',
// //           style: TextStyle(
// //             fontSize: height * 0.1,
// //             fontWeight: FontWeight.bold,
// //             fontFamily: 'Ubuntu',
// //           ),
// //         ),
// //         centerTitle: true,
// //         toolbarHeight: height * 0.2,
// //         actions: [
// //           Padding(
// //             padding: EdgeInsets.symmetric(vertical: height * 0.08, horizontal: height * 0.01),
// //             child: InkWell(
// //               onTap: () {
// //                 _signOut(context);
// //               },
// //               child: Icon(Icons.logout, size: height * 0.06),
// //             ),
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 8.0),
// //                 child: Text(
// //                   "Cart",
// //                   style: TextStyle(
// //                     fontSize: height * 0.03,
// //                     fontWeight: FontWeight.bold,
// //                     fontFamily: 'Ubuntu',
// //                   ),
// //                 ),
// //               ),
// //               Icon(Icons.shopping_cart, size: height * 0.03),
// //             ],
// //           ),
// //           Expanded(
// //             child: StreamBuilder(
// //               stream: cref.child(widget.uid).onValue,
// //               builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
// //                 if (!snapshot.hasData) {
// //                   return Center(
// //                     child: buildCircularProgressIndicator(),
// //                   );
// //                 } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
// //                   Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
// //                   if (map == null) {
// //                     return Center(child: Text("No Product Found"));
// //                   }
// //                   List<dynamic> list = map.values.toList();
// //
// //                   calculatedTotal = _calculateTotal(list);
// //                   subtotal= _calculatesubTotal(list);
// //
// //                   quantity = list.map((item) {
// //                     return {
// //                       'number': item['number'].toString(),
// //                       'pid': item['pid'].toString(),
// //                     };
// //                   }).toList();
// //
// //                   return Column(
// //                     children: [
// //                       Expanded(
// //                         child: ListView.builder(
// //                           itemCount: list.length,
// //                           itemBuilder: (context, index) {
// //                             name = list[index]['name'].toString();
// //                             description = list[index]['description'].toString();
// //                             price = list[index]['price'].toString();
// //                             img = list[index]['img'].toString();
// //                             number = list[index]['number'].toString();
// //                             date = list[index]['date'];
// //                             pid = list[index]['pid'];
// //
// //                             return Padding(
// //                               padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
// //                               child: Card(
// //                                 elevation: 10,
// //                                 child: Container(
// //                                   padding: EdgeInsets.all(8.0),
// //                                   child: Column(
// //                                     crossAxisAlignment: CrossAxisAlignment.start,
// //                                     children: [
// //                                       ListTile(
// //                                         contentPadding: EdgeInsets.zero,
// //                                         title: Text(
// //                                           name!,
// //                                           style: TextStyle(
// //                                             fontWeight: FontWeight.bold,
// //                                           ),
// //                                         ),
// //                                         leading: CircleAvatar(
// //                                           radius: 30,
// //                                           backgroundImage: NetworkImage(img!),
// //                                         ),
// //                                         trailing: Padding(
// //                                           padding: const EdgeInsets.only(top: 10.0),
// //                                           child: Column(
// //                                             children: [
// //                                               Text('Date: $date'),
// //                                               Text('Quantity: $number'),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                         subtitle: Text(
// //                                           description!,
// //                                           style: TextStyle(
// //                                             fontSize: 14,
// //                                           ),
// //                                           maxLines: 1,
// //                                           overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
// //                                         ),
// //                                       ),
// //                                       Center(
// //                                         child: IconButton(
// //                                           icon: Icon(Icons.delete),
// //                                           onPressed: () {
// //                                             _removeFromCart(widget.uid, pid!);
// //                                           },
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ),
// //                             );
// //                           },
// //                         ),
// //                       ),
// //                       Center(
// //                         child: Text(
// //                           'Sub Total: ${subtotal?.toStringAsFixed(2)}',
// //                           style: TextStyle(fontSize: height * 0.03, fontWeight: FontWeight.bold),
// //                         ),
// //                       ),
// //                       Center(
// //                         child: Text(
// //                           'Delivery charges: ${deliveryCharges?.toStringAsFixed(2)}',
// //                           style: TextStyle(fontSize: height * 0.03, fontWeight: FontWeight.bold),
// //                         ),
// //                       ),
// //                       Center(
// //                         child: Text(
// //                           'Total Bill: ${calculatedTotal?.toStringAsFixed(2)}',
// //                           style: TextStyle(fontSize: height * 0.03, fontWeight: FontWeight.bold),
// //                         ),
// //                       ),
// //
// //                     ],
// //                   );
// //                 } else {
// //                   return Center(child: Text("No Product Found"));
// //                 }
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //       floatingActionButton: SizedBox(
// //         height: 70,
// //         width: 70,
// //         child: FloatingActionButton(
// //           onPressed: () async {
// //             for (var item in quantity) {
// //               await _updateQuantity(item['number']!, item['pid']!);
// //             }
// //
// //             final DatabaseService dbService = DatabaseService();
// //             dbService.moveData(
// //                 'Cart/${widget.uid}',
// //                 'BuyerOrders',
// //                 {'status': 'false', 'phone': phone},
// //                 subtotal!,
// //                 deliveryCharges,
// //                 date!,
// //                 widget.uid
// //             ).then((value) {
// //               ScaffoldMessenger.of(context).showSnackBar(
// //                 const SnackBar(content: Text('Order placed successfully')),
// //               );
// //             });
// //           },
// //           child: Icon(Icons.check, size: height * 0.05),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget buildCircularProgressIndicator() {
// //     return CircularProgressIndicator(
// //       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
// //     );
// //   }
// // }
// //
// // class DatabaseService {
// //   final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
// //   String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
// //
// //   Future<void> moveData(String sourcePath, String destinationPath, Map<dynamic, dynamic> additionalData, double subtotal, double deliveryCharges, String date, String uid) async {
// //     try {
// //       // Step 1: Read the data from the source reference
// //       DataSnapshot sourceSnapshot = await _dbRef.child(sourcePath).get();
// //
// //       if (sourceSnapshot.exists) {
// //         Map<dynamic, dynamic> sourceData = Map<dynamic, dynamic>.from(sourceSnapshot.value as dynamic);
// //
// //         // Generate a unique cart ID for this order
// //         String cartId = _dbRef.child(destinationPath).push().key!;
// //
// //         // Step 2: Prepare the order data with additional information
// //         Map<dynamic, dynamic> orderData = {
// //           'cartId': cartId,
// //           'items': sourceData,
// //           'subtotal': subtotal,
// //           'deliveryCharges': deliveryCharges,
// //           'totalBill': subtotal + deliveryCharges,
// //           'date': date,
// //           'uid': uid,
// //           ...additionalData,
// //         };
// //
// //         // Step 3: Write the order data to the destination reference with the cart ID as the key
// //         await _dbRef.child('$destinationPath/$cartId').set(orderData);
// //
// //         // Step 4: Optionally, delete the data from the source reference (if necessary)
// //         await _dbRef.child(sourcePath).remove();
// //
// //         print('Data moved and order created successfully from $sourcePath to $destinationPath with Cart ID: $cartId');
// //       } else {
// //         print('No data found at $sourcePath');
// //       }
// //     } catch (e) {
// //       print('Failed to move data: $e');
// //     }
// //   }
// // }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:firebase_database/firebase_database.dart';
// // import 'package:geolocator/geolocator.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// // // import 'package:myfirstmainproject/orderslist.dart';
// // // import 'components.dart';
// //
// // class CheckoutPage extends StatefulWidget {
// //   @override
// //   _CheckoutPageState createState() => _CheckoutPageState();
// // }
// //
// // class _CheckoutPageState extends State<CheckoutPage> with SingleTickerProviderStateMixin {
// //   final DatabaseReference _userRef = FirebaseDatabase.instance.ref("users");
// //   final DatabaseReference _adminRef = FirebaseDatabase.instance.ref("admin");
// //   final DatabaseReference _riderRef = FirebaseDatabase.instance.ref("riders");
// //   final DatabaseReference _cartRef = FirebaseDatabase.instance.ref("cart");
// //   final DatabaseReference _ordersRef = FirebaseDatabase.instance.ref("orders");
// //   final DatabaseReference _feedbackRef = FirebaseDatabase.instance.ref("Feedback");
// //   late User currentUser;
// //   Map<String, dynamic>? userData;
// //   Map<String, dynamic>? cartItems;
// //   bool isAdmin = false;
// //   bool isRider = false;
// //   double? distanceToShop;
// //   double? deliveryCharges;
// //   late AnimationController _controller;
// //   late ScrollController _scrollController;
// //   late double _scrollPosition;
// //   final String _newsText = "Per Km delivery charges cost 200rs above a radius of 1km from the shop.";
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     currentUser = FirebaseAuth.instance.currentUser!;
// //     determineUserRole();
// //     _scrollController = ScrollController();
// //     _scrollPosition = 0.0;
// //
// //     _controller = AnimationController(
// //       duration: const Duration(seconds: 10), // Duration for one full scroll
// //       vsync: this,
// //     )..repeat();
// //
// //     _controller.addListener(() {
// //       setState(() {
// //         _scrollPosition = _scrollController.offset + 1;
// //         if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
// //           _scrollPosition = 0.0;
// //           _scrollController.jumpTo(_scrollPosition);
// //         } else {
// //           _scrollController.jumpTo(_scrollPosition);
// //         }
// //       });
// //     });
// //
// //   }
// //
// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     _scrollController.dispose();
// //     super.dispose();
// //   }
// //
// //   double calculateDistance(double startLatitude, double startLongitude, double endLatitude, double endLongitude) {
// //     return Geolocator.distanceBetween(startLatitude, startLongitude, endLatitude, endLongitude);
// //   }
// //
// //   Future<void> calculateDistanceToShop() async {
// //     final shopLatitude = 32.15043;
// //     final shopLongitude = 74.18722;
// //
// //     double userLatitude = 0.0;
// //     double userLongitude = 0.0;
// //
// //     try {
// //       final userRef = isAdmin ? _adminRef : isRider ? _riderRef : _userRef;
// //       final snapshot = await userRef.child(currentUser.uid).once();
// //
// //       if (snapshot.snapshot.value != null) {
// //         final userData = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
// //         userLatitude = double.parse(userData['latitude'].toString());
// //         userLongitude = double.parse(userData['longitude'].toString());
// //       }
// //
// //       double distanceInMeters = calculateDistance(userLatitude, userLongitude, shopLatitude, shopLongitude);
// //
// //       setState(() {
// //         distanceToShop = distanceInMeters / 1000; // Convert meters to kilometers
// //       });
// //
// //       print('Distance from shop: ${distanceToShop} km');
// //     } catch (e) {
// //       print('Error calculating distance: $e');
// //     }
// //   }
// //
// //   double calculateDeliveryCharges(){
// //     double subdistance = distanceToShop! - 1;
// //     return (subdistance * 200);
// //   }
// //
// //   Future<void> determineUserRole() async {
// //     try {
// //       final adminSnapshot = await _adminRef.child(currentUser.uid).once();
// //       final riderSnapshot = await _riderRef.child(currentUser.uid).once();
// //
// //       if (adminSnapshot.snapshot.value != null) {
// //         setState(() {
// //           isAdmin = true;
// //           isRider = false;
// //         });
// //       } else if (riderSnapshot.snapshot.value != null) {
// //         setState(() {
// //           isAdmin = false;
// //           isRider = true;
// //         });
// //       } else {
// //         setState(() {
// //           isAdmin = false;
// //           isRider = false;
// //         });
// //       }
// //
// //       fetchUserData();
// //       fetchCartItems();
// //       await calculateDistanceToShop(); // Calculate the distance after fetching user data
// //
// //     } catch (e) {
// //       print('Error determining user role: $e');
// //     }
// //   }
// //
// //   Future<void> fetchUserData() async {
// //     final userRef = isAdmin
// //         ? _adminRef
// //         : isRider
// //         ? _riderRef
// //         : _userRef;
// //
// //     try {
// //       final snapshot = await userRef.child(currentUser.uid).once();
// //       if (snapshot.snapshot.value != null) {
// //         setState(() {
// //           userData = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
// //         });
// //       }
// //     } catch (e) {
// //       print('Error fetching user data: $e');
// //     }
// //   }
// //
// //   Future<void> fetchCartItems() async {
// //     final userCartRef = _cartRef;
// //     final snapshot = await userCartRef.once();
// //     if (snapshot.snapshot.value != null) {
// //       setState(() {
// //         cartItems = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
// //       });
// //     } else {
// //       setState(() {
// //         cartItems = {};
// //       });
// //     }
// //   }
// //
// //   double calculateTotalBalance() {
// //     double total = 0.0;
// //     if (cartItems != null) {
// //       cartItems!.forEach((key, item) {
// //         final rate = double.tryParse(item['rate'] as String? ?? '0') ?? 0;
// //         final quantity = item['quantity'] as int? ?? 0;
// //         total += rate * quantity;
// //       });
// //     }
// //     return total;
// //   }
// //
// //
// //
// //   Future<void> placeOrder() async {
// //     if (cartItems != null) {
// //       try {
// //         // Fetch existing orders
// //         List<Map<String, dynamic>> existingOrders = await fetchExistingOrders();
// //
// //         // Calculate the total balance (subtotal) and delivery charges
// //         double subtotal = calculateTotalBalance();
// //         double charges = deliveryCharges ?? 0.0; // Default to 0.0 if deliveryCharges is null
// //         double total = subtotal + charges;
// //
// //         // Create a new order
// //         String newOrderId = _ordersRef.push().key.toString();
// //         final newOrder = {
// //           'orderId': newOrderId,
// //           'items': cartItems,
// //           'userId': currentUser.uid,
// //           'subtotal': subtotal, // Store subtotal separately
// //           'deliveryCharges': charges, // Store delivery charges separately
// //           'total': total, // Total includes subtotal and delivery charges
// //           'status': 'Pending',
// //           'timestamp': DateTime.now().toIso8601String(),
// //         };
// //
// //         // Add the new order to the list
// //         existingOrders.add(newOrder);
// //
// //         // Merge all orders including the new one
// //         List<Map<String, dynamic>> mergedOrders = mergeOrders(existingOrders);
// //
// //         // Update Firebase with merged orders
// //         await updateMergedOrders(mergedOrders);
// //
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order placed successfully!")));
// //
// //         // Optionally, clear the cart after placing the order
// //         await _cartRef.remove();
// //
// //         // Show feedback dialog
// //         showFeedbackDialog(newOrderId);
// //
// //       } catch (error) {
// //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error placing order: $error")));
// //       }
// //     }
// //   }
// //
// //
// //   void showFeedbackDialog(String orderId) {
// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         double rating = 0.0;
// //         TextEditingController feedbackController = TextEditingController();
// //
// //         return AlertDialog(
// //           title: Text('Rate your items'),
// //           content: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               RatingBar.builder(
// //                 initialRating: 0,
// //                 minRating: 1,
// //                 direction: Axis.horizontal,
// //                 allowHalfRating: true,
// //                 itemCount: 5,
// //                 itemBuilder: (context, _) => Icon(
// //                   Icons.star,
// //                   color: Colors.amber,
// //                 ),
// //                 onRatingUpdate: (newRating) {
// //                   rating = newRating;
// //                 },
// //               ),
// //               SizedBox(height: 10),
// //               TextField(
// //                 controller: feedbackController,
// //                 decoration: InputDecoration(hintText: 'Leave your feedback'),
// //               ),
// //             ],
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () {
// //                 Navigator.pushAndRemoveUntil(
// //                   context,
// //                   MaterialPageRoute(builder: (context) => CustomerOrdersPage(comingFromCheckoutPage: true)),
// //                       (route) => false,
// //                 );
// //               },
// //               child: Text('Cancel'),
// //             ),
// //             TextButton(
// //               onPressed: () async {
// //                 final feedback = feedbackController.text;
// //                 await saveFeedback(orderId, rating, feedback,currentUser.uid);
// //                 Navigator.of(context).pop();
// //
// //                 // Navigate to CustomerOrdersPage after feedback
// //                 Navigator.pushAndRemoveUntil(
// //                   context,
// //                   MaterialPageRoute(builder: (context) => CustomerOrdersPage(comingFromCheckoutPage: true)),
// //                       (route) => false,
// //                 );
// //               },
// //               child: Text('Submit'),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //
// //   Future<void> saveFeedback(String orderId, double rating, String feedback,String userId) async {
// //     if (cartItems != null) {
// //       cartItems!.forEach((key, item) async {
// //         final itemId = item['itemId'];
// //         final adminId = item['adminId'] as String? ?? 'unknownAdminId';
// //         final feedbackData = {
// //           'orderId': orderId,
// //           'itemId': itemId,
// //           'adminId': adminId,
// //           'rating': rating,
// //           'feedback': feedback,
// //           'timestamp': DateTime.now().toIso8601String(),
// //           'userId': userId
// //         };
// //
// //         await _feedbackRef.push().set(feedbackData);
// //       });
// //     }
// //   }
// //
// //   Future<List<Map<String, dynamic>>> fetchExistingOrders() async {
// //     final snapshot = await _ordersRef.orderByChild('userId').equalTo(currentUser.uid).once();
// //     if (snapshot.snapshot.value != null) {
// //       List<Map<String, dynamic>> orders = [];
// //       snapshot.snapshot.children.forEach((doc) {
// //         orders.add(Map<String, dynamic>.from(doc.value as Map));
// //       });
// //       return orders;
// //     }
// //     return [];
// //   }
// //
// //   List<Map<String, dynamic>> mergeOrders(List<Map<String, dynamic>> orders) {
// //     List<Map<String, dynamic>> mergedOrders = [];
// //
// //     for (var order in orders) {
// //       if (mergedOrders.isEmpty) {
// //         mergedOrders.add(order);
// //       } else {
// //         DateTime currentOrderTime = DateTime.parse(order['timestamp']);
// //         bool merged = false;
// //
// //         for (var mergedOrder in mergedOrders) {
// //           DateTime lastOrderTime = DateTime.parse(mergedOrder['timestamp']);
// //
// //           if (currentOrderTime.difference(lastOrderTime).inMinutes < 5) {
// //             // Merge logic: Combine items and quantities
// //             mergedOrder['items'].addAll(order['items']);
// //
// //             // Update totals
// //             double existingTotal = mergedOrder['total'] as double;
// //             double currentSubtotal = order['subtotal'] as double;
// //             double currentTotal = order['total'] as double;
// //
// //             mergedOrder['total'] = existingTotal + currentSubtotal; // Add subtotal to existing total
// //             mergedOrder['timestamp'] = DateTime.now().toIso8601String(); // Update timestamp
// //
// //             merged = true;
// //             break;
// //           }
// //         }
// //
// //         if (!merged) {
// //           mergedOrders.add(order);
// //         }
// //       }
// //     }
// //
// //     return mergedOrders;
// //   }
// //
// //   Future<void> updateMergedOrders(List<Map<String, dynamic>> mergedOrders) async {
// //     try {
// //       // Clear existing orders for the user
// //       final existingOrders = await fetchExistingOrders();
// //       for (var order in existingOrders) {
// //         await _ordersRef.child(order['orderId']).remove();
// //       }
// //
// //       // Add merged orders to Firebase
// //       for (var order in mergedOrders) {
// //         await _ordersRef.child(order['orderId']).set(order);
// //       }
// //     } catch (error) {
// //       print('Error updating merged orders: $error');
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: CustomAppBar.customAppBar("Checkout"),
// //       body: userData != null && cartItems != null
// //           ? Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: SingleChildScrollView(
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               Align(
// //                 alignment: Alignment.bottomCenter,
// //                 child: Container(
// //                   height: 30.0,
// //                   child: ListView.builder(
// //                     scrollDirection: Axis.horizontal,
// //                     controller: _scrollController,
// //                     physics: NeverScrollableScrollPhysics(),
// //                     itemBuilder: (context, index) {
// //                       return Row(
// //                         children: [
// //                           Text(
// //                             _newsText,
// //                             style: TextStyle(
// //                               color: Colors.red,
// //                               fontSize: 15,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                           SizedBox(width: 20), // Space between repeats
// //                         ],
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ),
// //               Text(
// //                 'Profile Information:',
// //                 style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold),
// //               ),
// //               SizedBox(height: 10),
// //               Text('Role: ${isAdmin ? 'Admin' : isRider ? 'Rider' : 'Buyer'}'), // Display Role
// //               Text('Name: ${userData!['name']}'),
// //               Text('Email: ${userData!['email']}'),
// //               Text('Phone: ${userData!['phone']}'),
// //               Text('Address: ${userData!['address']}'),
// //               Text('Zip Code: ${userData!['zip_code']}'),
// //               if (distanceToShop != null)
// //                 Text('Distance to Shop: ${distanceToShop!.toStringAsFixed(2)} km'), // Display distance
// //               SizedBox(height: 20),
// //               Text(
// //                 'Cart Items:',
// //                 style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold),
// //               ),
// //               SizedBox(height: 10),
// //               ...cartItems!.entries.map((entry) {
// //                 final item = entry.value;
// //                 final name = item['name'] as String? ?? 'No Name';
// //                 final imageUrl = item['imageUrl'] as String? ?? '';
// //                 final category = item['category'] as String? ?? 'No Category';
// //                 final rate = item['rate'] as String? ?? 'No Rate';
// //                 final quantity = item['quantity'] as int? ?? 0;
// //                 final description = item['description'] as String? ?? 'No description';
// //                 deliveryCharges = calculateDeliveryCharges();
// //                 return Card(
// //                   margin: EdgeInsets.symmetric(vertical: 8.0),
// //                   child: ListTile(
// //                     leading: CircleAvatar(
// //                       backgroundImage: NetworkImage(imageUrl),
// //                     ),
// //                     title: Text("Name: $name", style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold)),
// //                     subtitle: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Text("Category: $category", style: GoogleFonts.lora(fontSize: 14)),
// //                         Text("Rate: $rate", style: GoogleFonts.lora(fontSize: 14)),
// //                         Text("Quantity: $quantity", style: GoogleFonts.lora(fontSize: 14)),
// //                         Text("Description: $description", style: GoogleFonts.lora(fontSize: 14)),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               }).toList(),
// //               SizedBox(height: 20),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     'SUB TOTAL',
// //                     style: GoogleFonts.lora(fontSize: 15, fontWeight: FontWeight.bold),
// //                   ),
// //                   Text(
// //                     'Rs. ${calculateTotalBalance().toStringAsFixed(2)}',
// //                     style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 20,),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     'DELIVERY CHARGES ',
// //                     style: GoogleFonts.lora(fontSize: 15, fontWeight: FontWeight.bold),
// //                   ),
// //                   Text(
// //                     'Rs.${deliveryCharges?.toStringAsFixed(2)} ',
// //                     style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 20),
// //               Row(
// //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                 children: [
// //                   Text(
// //                     'TOTAL BALANCE',
// //                     style: GoogleFonts.lora(fontSize: 20, fontWeight: FontWeight.bold),
// //                   ),
// //                   Text(
// //                     'Rs. ${(deliveryCharges! + calculateTotalBalance()).toStringAsFixed(2)}',
// //                     style: GoogleFonts.lora(fontSize: 30, fontWeight: FontWeight.bold),
// //                   ),
// //                 ],
// //               ),
// //               SizedBox(height: 30),
// //               Center(
// //                 child: ElevatedButton(
// //                   onPressed: () {
// //                     placeOrder(); // Trigger order placement
// //                   },
// //                   child: Text("Complete Checkout", style: NewCustomTextStyles.newcustomTextStyle),
// //                   style: ElevatedButton.styleFrom(
// //                     foregroundColor: Colors.white,
// //                     backgroundColor: Color(0xFFe6b67e),
// //                     minimumSize: Size(double.infinity, 50),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       )
// //           : Center(child: CircularProgressIndicator()),
// //     );
// //   }
// // }
//
//
//
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
//
// import '../Authentication/Login.dart';
//
// class Rider extends StatefulWidget {
//   const Rider({super.key});
//
//   @override
//   State<Rider> createState() => _RiderState();
// }
//
// class _RiderState extends State<Rider> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final oref = FirebaseDatabase.instance.ref('orders');
//
//
//
//   Widget buildCircularProgressIndicator() {
//     return CircularProgressIndicator(
//       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//     );
//   }
//
//
//   Future<void> _AcceptOrders(List<dynamic> list, int index) async {
//     // Ensure list is not empty and index is valid
//     if (list.isNotEmpty && index < list.length) {
//       String cid = list[index]['cid'];
//       String status = list[index]['status'].toString().toLowerCase();
//
//       // Debugging output
//       print("Delivering order with cid: $cid and status: $status");
//
//       if (status == 'true') {
//         // Query to find the order by cid
//         DataSnapshot snapshot = await oref.orderByChild('cid').equalTo(cid).get();
//
//         if (snapshot.exists) {
//           Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;
//
//           // Find the key for the order to update
//           String key = map1.keys.firstWhere((k) => map1[k]['cid'] == cid);
//
//           // print(key);
//           await oref.child(key).update({'status': 'deliver'}).then((value) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Order Delivered. ')),
//             );
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Order not found.')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Order already accepted.')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid order.')),
//       );
//     }
//   }
//
//
//
//   Future<void> _signOut(BuildContext context) async {
//     try {
//       await _auth.signOut();
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => Login()),
//             (Route<dynamic> route) => false, // Remove all previous routes
//       );
//     } catch (e) {
//       print("Error signing out: $e");
//       // Handle sign out error
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     String status1 = 'true';
//     String? name;
//     String? description;
//     String? img;
//     String? number;
//     String? price;
//     bool _noDataFound = false;
//     String? status;
//     String? date;
//     String? cid;
//     void _showItemsDialog(List<dynamic> itemsList) {
//       showDialog(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: Text("Order Items"),
//             content: SingleChildScrollView(
//               child: Column(
//                 children: itemsList.map((item) {
//                   return ListTile(
//                     leading: CircleAvatar(
//                       backgroundImage: NetworkImage(item['img']),
//                     ),
//                     title: Text(item['name']),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("Description: ${item['description']}"),
//                         Text("Price: ${item['price']}"),
//                         Text("Quantity: ${item['number']}"),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//             actions: [
//               TextButton(
//                 child: Text("Close"),
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           'xoxo',
//           style: TextStyle(
//             fontSize: height * 0.1,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Ubuntu',
//           ),
//         ),
//         centerTitle: true,
//         toolbarHeight: height * 0.2,
//         actions: [
//           Padding(
//             padding: EdgeInsets.symmetric(vertical: height * 0.08, horizontal: height * 0.01),
//             child: InkWell(
//               onTap: () {
//                 _signOut(context);
//               },
//               child: Icon(Icons.logout, size: height * 0.06),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Text(
//                   "Order List",
//                   style: TextStyle(
//                     fontSize: height * 0.03,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Ubuntu',
//                   ),
//                 ),
//               ),
//               Icon(Icons.shopping_cart, size: height * 0.03),
//             ],
//           ),
//           Expanded(
//             child: StreamBuilder(
//               stream: oref.onValue,
//               builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//                 if (!snapshot.hasData) {
//                   return Center(
//                     child: buildCircularProgressIndicator(),
//                   );
//                 } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
//                   Map<dynamic, dynamic> ordersMap = snapshot.data!.snapshot.value as dynamic;
//                   if (ordersMap == null) {
//                     return Center(child: Text("No Orders Found"));
//                   }
//                   List<dynamic> ordersList = ordersMap.values.toList();
//
//                   return ListView.builder(
//                     // reverse: true,
//                     itemCount: ordersList.length,
//                     itemBuilder: (context, index) {
//                       return Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
//                         child: Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(15.0),
//                             side: BorderSide(
//                               color: ordersList[index]['status']=='deliver'? Colors.blue:  Colors.red, // Border color
//                               width: 3.0, // Border width
//                             ),
//                           ),
//                           elevation: 10,
//                           child: ListTile(
//                             title: Text(
//                               "Order ID: ${ordersList[index]['cartId']}",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             subtitle: Column(
//                               children: [
//                                 Text("Order Date: ${ordersList[index]['date']}"),
//                                 Text("Total Bill: ${ordersList[index]['totalBill']}" ),
//                                 ordersList[index]['status']=='false'? Text("status: Pending"):ordersList[index]['status']=='deliver'? Text("status: delivered"):Text("status: will be delivered in 7 working days")
//                               ],
//                             ),
//
//                             onTap: () {
//                               // Extract items from the order and display in dialog
//                               Map<dynamic, dynamic> itemsMap = ordersList[index]['items'];
//                               List<dynamic> itemsList = itemsMap.values.toList();
//                               _showItemsDialog(itemsList);
//                             },
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 } else {
//                   return Center(child: Text("No Orders Found"));
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
//
// import '../Authentication/Login.dart';
//
// class Rider extends StatefulWidget {
//   const Rider({super.key});
//
//   @override
//   State<Rider> createState() => _RiderState();
// }
//
// class _RiderState extends State<Rider> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final oref = FirebaseDatabase.instance.ref('BuyerOrders');
//
//
//
//   Widget buildCircularProgressIndicator() {
//     return CircularProgressIndicator(
//       valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//     );
//   }
//
//
//   Future<void> _AcceptOrders(List<dynamic> list, int index) async {
//     // Ensure list is not empty and index is valid
//     if (list.isNotEmpty && index < list.length) {
//       String cid = list[index]['cid'];
//       String status = list[index]['status'].toString().toLowerCase();
//
//       // Debugging output
//       print("Delivering order with cid: $cid and status: $status");
//
//       if (status == 'true') {
//         // Query to find the order by cid
//         DataSnapshot snapshot = await oref.orderByChild('cid').equalTo(cid).get();
//
//         if (snapshot.exists) {
//           Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;
//
//           // Find the key for the order to update
//           String key = map1.keys.firstWhere((k) => map1[k]['cid'] == cid);
//
//           // print(key);
//           await oref.child(key).update({'status': 'deliver'}).then((value) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Order Delivered. ')),
//             );
//           });
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Order not found.')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Order already accepted.')),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Invalid order.')),
//       );
//     }
//   }
//
//
//
//   Future<void> _signOut(BuildContext context) async {
//     try {
//       await _auth.signOut();
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (context) => Login()),
//             (Route<dynamic> route) => false, // Remove all previous routes
//       );
//     } catch (e) {
//       print("Error signing out: $e");
//       // Handle sign out error
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//
//     String status1 = 'false';
//     String? name;
//     String? description;
//     String? img;
//     String? number;
//     String? price;
//     bool _noDataFound = false;
//     String? status;
//     String? date;
//     String? cid;
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           'xoxo',
//           style: TextStyle(
//             fontSize: height * 0.1,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Ubuntu',
//           ),
//         ),
//         centerTitle: true,
//         toolbarHeight: height * 0.2,
//         actions: [
//           Padding(
//               padding:  EdgeInsets.symmetric(vertical: height* 0.08, horizontal: height* 0.01 ),
//               child: InkWell(onTap: (){
//                 _signOut(context);
//               },
//                   child: Icon(Icons.logout, size: height*0.06,))
//           )
//         ],
//       ),
//
//       body: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Text(
//                   "Order List",
//                   style: TextStyle(
//                     fontSize: height * 0.03,
//                     fontWeight: FontWeight.bold,
//                     fontFamily: 'Ubuntu',
//                   ),
//                 ),
//               ),
//               Icon(Icons.shopping_cart, size: height * 0.03),
//             ],
//           ),
//
//
//           Expanded(
//             child: StreamBuilder(
//               stream: oref.orderByChild('status').equalTo(status1).onValue,
//               builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//                 if (!snapshot.hasData && !_noDataFound) {
//                   return Center(
//                     child: buildCircularProgressIndicator(),
//                   );
//                 } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
//                   Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
//                   if (map == null) {
//                     return Center(child: Text("No Orders Found"));
//                   }
//                   List<dynamic> list = map.values.toList();
//
//                   return Column(
//                     children: [
//                       Expanded(
//                         child: ListView.builder(
//                           itemCount: list.length,
//                           itemBuilder: (context, index) {
//                             name = list[index]['name'].toString();
//                             description = list[index]['description'].toString();
//                             price = list[index]['price'].toString();
//                             img = list[index]['img'].toString();
//                             number = list[index]['number'].toString();
//                             status = list[index]['status'].toString().toLowerCase();
//                             date = list[index]['date'];
//                             cid = list[index]['cid'];
//
//                             // print(list);
//                             return Padding(
//                               padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
//                               child: Card(
//                                 elevation: 10,
//                                 child: Container(
//
//                                   height: status == 'true' ?height * 0.17: height*0.15,
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       ListTile(
//                                         contentPadding: EdgeInsets.zero,
//                                         title: Text(
//                                           name!,
//                                           style: TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         leading: CircleAvatar(
//                                           radius: 30,
//                                           backgroundImage: NetworkImage(img!),
//                                         ),
//                                         trailing: Padding(
//                                           padding: EdgeInsets.only(top: height * 0.01),
//                                           child: Column(
//                                             children: [
//                                               Text('date is: $date'),
//                                               Text('quantity is: $number'),
//                                             ],
//                                           ),
//                                         ),
//                                         subtitle: (status == 'true')
//                                             ? Text(
//                                           'Order Pending',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
//                                         )
//                                             : Text(
//                                           'Delivered',
//                                           style: TextStyle(
//                                             fontSize: 14,
//                                           ),
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
//                                         ),
//                                       ),
//                                       status == 'true'?
//                                       ElevatedButton(
//                                           onPressed: () async {
//                                             await _AcceptOrders(list,index);
//                                           },
//                                           child: Text('Deliver ?')):Text('Delivered to Customer')
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   );
//                 } else {
//                   return Center(child: Text("No Orders Found"));
//                 }
//               },
//             ),
//           ),
//
//         ],
//       ),
//     );
//   }
// }
//
