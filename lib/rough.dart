// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:xoxo_ecommerce/Authentication/Login.dart';
// import 'package:xoxo_ecommerce/models/signup.dart';
// import 'dart:io';
//
// import 'SellerPages/HomeScreen.dart';
//
// class Verification extends StatefulWidget {
//   final String phoneNumber;
//   final String name;
//   final String email;
//   final String password;
//   // final String Url;
//   final String role;
//   File? file;
//   dynamic pickfile;
//   // 1 is for seller
//   // 2 is for buyer
//   // 3 is for ryder
//   Verification({
//     required this.phoneNumber,
//     required this.name,
//     required this.email,
//     required this.password,
//     required this.role,
//     required this.file,
//     required this.pickfile,
//   });
//
//   @override
//   State<Verification> createState() => _VerificationState();
// }
//
// class _VerificationState extends State<Verification> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final TextEditingController _codeController = TextEditingController();
//   String _verificationId = "";
//   bool _isLoading = false;
//   final dref = FirebaseDatabase.instance.ref("User");
//   final storref = FirebaseStorage.instance;
//   String? url;
//
//   String? id;
//
//   @override
//   void initState() {
//     super.initState();
//     _verifyPhone();
//   }
//   Future<void> uploadImage(String id) async {
//     try {
//       if (widget.file != null || widget.pickfile != null) {
//         final imageRef = storref.ref()
//             .child("Images/${id}.jpg");
//         UploadTask uploadTask;
//         if (kIsWeb) {
//           final byte = await widget.pickfile.readAsBytes();
//           uploadTask = imageRef.putData(byte);
//         } else {
//           uploadTask = imageRef.putFile(widget.file!);
//         }
//
//         final snapshot = await uploadTask.whenComplete(() {
//           ScaffoldMessenger.of(context)
//               .showSnackBar(SnackBar(content: Text("Image Uploaded")));
//         });
//
//         url = await snapshot.ref.getDownloadURL();
//         print("Image URL: $url");
//       }
//     } catch (e) {
//       print("Error uploading image: $e");
//     }
//   }
//
//   void _verifyPhone() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     await _auth.verifyPhoneNumber(
//       phoneNumber: widget.phoneNumber,
//       verificationCompleted: (PhoneAuthCredential credential) async {
//         await _auth.signInWithCredential(credential);
//         _signUp();
//       },
//       verificationFailed: (FirebaseAuthException e) {
//         setState(() {
//           _isLoading = false;
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Verification failed. Please try again. $e')),
//
//         );
//         print("Error signing out: $e");
//       },
//       codeSent: (String verificationId, int? resendToken) {
//         setState(() {
//           _verificationId = verificationId;
//           _isLoading = false;
//         });
//       },
//       codeAutoRetrievalTimeout: (String verificationId) {
//         setState(() {
//           _verificationId = verificationId;
//         });
//       },
//     );
//   }
//
//   void _signInWithPhoneNumber() async {
//     setState(() {
//       _isLoading = true;
//     });
//
//     try {
//       final AuthCredential credential = PhoneAuthProvider.credential(
//         verificationId: _verificationId,
//         smsCode: _codeController.text,
//       );
//
//       final User? user = (await _auth.signInWithCredential(credential)).user;
//
//       if (user != null) {
//         _signUp();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Sign in failed')),
//         );
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   void _signUp() async {
//
//     try {
//       UserCredential userCredential =await _auth.createUserWithEmailAndPassword(
//         email: widget.email,
//         password: widget.password,
//       );
//       User? user = userCredential.user;
//       id = user?.uid;
//       await uploadImage(id!);
//       SignUp signUp = SignUp(widget.name, widget.email, widget.phoneNumber, widget.password, url!,id!,widget.role);
//       await dref.child(id!).set(signUp.tomap()).then((value) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Sign up successful')),
//         );
//       }).onError((error, stackTrace) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('error sigining up $error')),
//         );
//       });
//
//
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => Login()),
//       );
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'email-already-in-use') {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('The email address is already in use.')),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Sign up failed. Please try again.')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $e')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final width = MediaQuery.of(context).size.width;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Verification',
//           style: TextStyle(
//             fontSize: height * 0.05,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Ubuntu',
//           ),
//         ),
//         centerTitle: true,
//         toolbarHeight: height * 0.1,
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: width * 0.1),
//           child: Column(
//             children: [
//               Text(
//                 'A verification code has been sent to ${widget.phoneNumber}',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: height * 0.03),
//               ),
//               SizedBox(height: height * 0.02),
//               TextField(
//                 controller: _codeController,
//                 decoration: InputDecoration(labelText: "Verification Code"),
//               ),
//               SizedBox(height: height * 0.02),
//               _isLoading
//                   ? CircularProgressIndicator()
//                   : ElevatedButton(
//                 onPressed: ()async{
//
//                   _signInWithPhoneNumber();
//
//                 },
//                 child: Text('Verify'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// class Orders extends StatefulWidget {
//   final String uid;
//
//   Orders(this.uid);
//
//   @override
//   State<Orders> createState() => _OrdersState();
// }
//
// class _OrdersState extends State<Orders> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//     final oref = FirebaseDatabase.instance.ref('BuyerOrders');
//
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
//     Widget buildCircularProgressIndicator() {
//       return CircularProgressIndicator(
//         valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//       );
//     }
//
//     Future<void> _AcceptOrders(List<dynamic> list, int index) async {
//       // Ensure list is not empty and index is valid
//       if (list.isNotEmpty && index < list.length) {
//         String cid = list[index]['cid'];
//         String status = list[index]['status'].toString().toLowerCase();
//
//         // Debugging output
//         print("Accepting order with cid: $cid and status: $status");
//
//         if (status == 'false') {
//           // Query to find the order by cid
//           DataSnapshot snapshot = await oref.orderByChild('cid').equalTo(cid).get();
//
//           if (snapshot.exists) {
//             Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;
//
//             // Find the key for the order to update
//             String key = map1.keys.firstWhere((k) => map1[k]['cid'] == cid);
//
//             // print(key);
//             await oref.child(key).update({'status': 'true'}).then((value) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Order accepted. ')),
//               );
//             });
//           } else {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(content: Text('Order not found.')),
//             );
//           }
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Order already accepted.')),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Invalid order.')),
//         );
//       }
//     }
//
//
//     Future<void> _signOut(BuildContext context) async {
//       try {
//         await _auth.signOut().then((value) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => Login()), // Navigate to your login screen
//           );
//         });
//       } catch (e) {
//         print("Error signing out: $e");
//         // Handle sign out error
//       }
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
//               stream: oref.orderByChild('sid').equalTo(widget.uid).onValue,
//               builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
//                 if (!snapshot.hasData && !_noDataFound) {
//                   return Center(
//                     child: buildCircularProgressIndicator(),
//                   );
//                 } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
//                   Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
//                   if (map == null) {
//                     return Center(child: Text("No Product Found"));
//                   }
//                   List<dynamic> list = map.values.toList();
//
//                   return Column(
//                     children: [
//                       Expanded(
//                         child: ListView.builder(
//                           reverse:  true,
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
//                                   height: status == 'false' ?height * 0.17: height*0.15,
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       ListTile(
//                                           contentPadding: EdgeInsets.zero,
//                                           title: Text(
//                                             name!,
//                                             style: TextStyle(
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                           leading: CircleAvatar(
//                                             radius: 30,
//                                             backgroundImage: NetworkImage(img!),
//                                           ),
//                                           trailing: Padding(
//                                             padding: EdgeInsets.only(top: height * 0.01),
//                                             child: Column(
//                                               children: [
//                                                 Text('date is: $date'),
//                                                 Text('quantity is: $number'),
//                                               ],
//                                             ),
//                                           ),
//                                           subtitle: (status == 'false')
//                                               ? Text(
//                                             'Order Pending',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                             ),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
//                                           )
//                                               : (status=='true')? Text(
//                                             'Accepted',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                             ),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
//                                           ):Text(
//                                             'Delivered',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                             ),
//                                             maxLines: 1,
//                                             overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
//                                           )
//                                       ),
//                                       status == 'false'?
//                                       ElevatedButton(
//                                           onPressed: () async {
//                                             await _AcceptOrders(list,index);
//                                           },
//                                           child: Text('Accept')):(status=='true')?Text('Will be delivered in 10 to 15 days'):Text('delivered')
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
//                   return Center(child: Text("No Product Found"));
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











// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';
//
// import '../Authentication/Login.dart';
// import 'HomeScreen.dart';
//
// class Reports extends StatefulWidget {
//   final String uid;
//
//   Reports(this.uid);
//
//   @override
//   _ReportsState createState() => _ReportsState();
// }
//
// class _ReportsState extends State<Reports> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("BuyerOrders");
//
//   DateTime? _startDate;
//   DateTime? _endDate;
//
//   double? profitloss;
//   List<Map<dynamic, dynamic>> _filteredData = [];
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//
//     double _calculateTotal(List<dynamic> list) {
//       double total = 0;
//       for (var node in list) {
//         total += (double.parse(node['price']) - double.parse(node['buying'])) * int.parse(node['number']);
//       }
//       return total;
//     }
//
//     Future<void> _signOut(BuildContext context) async {
//       try {
//         await _auth.signOut().then((value) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => Login()), // Navigate to your login screen
//           );
//         });
//       } catch (e) {
//         print("Error signing out: $e");
//         // Handle sign out error
//       }
//     }
//
//     if (_filteredData.isNotEmpty) {
//       profitloss = _calculateTotal(_filteredData);
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Reports',
//           style: TextStyle(
//             fontSize: height * 0.03,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Ubuntu',
//           ),
//         ),
//         centerTitle: true,
//         toolbarHeight: height * 0.1,
//         actions: [
//           // Padding(
//           //   padding: EdgeInsets.symmetric(vertical: height * 0.02, horizontal: height * 0.01),
//           //   child: InkWell(
//           //     onTap: () {
//           //       _signOut(context);
//           //     },
//           //     child: Icon(Icons.logout, size: height * 0.03),
//           //   ),
//           // ),
//           PopupMenuButton(itemBuilder: (context) {
//             return [
//               PopupMenuItem(
//                 child: Icon(Icons.logout),
//                 onTap: () {
//                   _signOut(context);
//                 },
//               ),
//               PopupMenuItem(
//                 child: Icon(Icons.home),
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) {
//                     return HomeScreen(widget.uid);
//                   }));
//                 },
//               )
//             ];
//           }, iconSize: height * 0.04),
//
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: ListTile(
//                     title: Text(
//                       'Start Date: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Not selected'}',
//                       style: TextStyle(fontSize: height * 0.02),
//                     ),
//                     trailing: Icon(Icons.calendar_today, size: height * 0.03),
//                     onTap: () async {
//                       DateTime? pickedDate = await _selectDate(context, _startDate, DateTime.now());
//                       if (pickedDate != null && (_endDate == null || pickedDate.isBefore(_endDate!))) {
//                         setState(() {
//                           _startDate = pickedDate;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Start date cannot be after end date')),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   child: ListTile(
//                     title: Text(
//                       'End Date: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Not selected'}',
//                       style: TextStyle(fontSize: height * 0.02),
//                     ),
//                     trailing: Icon(Icons.calendar_today, size: height * 0.03),
//                     onTap: () async {
//                       DateTime? pickedDate = await _selectDate(context, _endDate, DateTime.now());
//                       if (pickedDate != null && (_startDate == null || pickedDate.isAfter(_startDate!))) {
//                         setState(() {
//                           _endDate = pickedDate;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('End date cannot be before start date')),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_startDate != null && _endDate != null) {
//                   _filterData();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Please select both start and end dates')),
//                   );
//                 }
//               },
//               child: Text('Filter Data'),
//             ),
//             if (profitloss != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   'Profit/Loss: $profitloss',
//                   style: TextStyle(fontSize: height * 0.025, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Container(
//                 height: height * 0.3,
//                 child: _buildChart(),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _filteredData.length,
//                 itemBuilder: (context, index) {
//                   String name = _filteredData[index]['name'].toString();
//                   String description = _filteredData[index]['description'].toString();
//                   String sellingPrice = _filteredData[index]['price'].toString();
//                   String img = _filteredData[index]['img'].toString();
//                   String number = _filteredData[index]['number'].toString();
//                   String status = _filteredData[index]['status'].toString().toLowerCase();
//                   String date = _filteredData[index]['date'].toString();
//                   double buying = double.parse(_filteredData[index]['buying'].toString());
//
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                         side: BorderSide(
//                           color: status == 'false' ? Colors.red : Colors.green, // Border color
//                           width: 3.0, // Border width
//                         ),
//                       ),
//                       elevation: 10,
//                       child: Container(
//                         padding: EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ListTile(
//                               contentPadding: EdgeInsets.zero,
//                               title: Text(
//                                 name,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: height * 0.02,
//                                 ),
//                               ),
//                               leading: CircleAvatar(
//                                 radius: height * 0.04,
//                                 backgroundImage: NetworkImage(img),
//                               ),
//                               trailing: Padding(
//                                 padding: const EdgeInsets.only(top: 10.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       'Date: $date',
//                                       style: TextStyle(color: Colors.black, fontSize: height * 0.015),
//                                     ),
//                                     Text(
//                                       'Quantity: $number',
//                                       style: TextStyle(color: Colors.black, fontSize: height * 0.015),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 description,
//                                 style: TextStyle(color: Colors.black, fontSize: height * 0.017,overflow: TextOverflow.ellipsis),
//                               ),
//                             ),
//                             Center(
//                               child: (status == 'deliver')
//                                   ? Text(
//                                 'Delivered',
//                                 style: TextStyle(
//                                   fontSize: height * 0.017,
//                                   color: status == 'false' ? Colors.red : Colors.green,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
//                               )
//                                   : Text('Pending', style: TextStyle(fontSize: height * 0.017)),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate, DateTime? maxDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: maxDate ?? DateTime(2101),
//     );
//     return picked;
//   }
//
//   void _filterData() async {
//     final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
//     final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);
//
//     _databaseRef.orderByChild("sid").equalTo(widget.uid).once().then((DatabaseEvent event) {
//       Map<dynamic, dynamic> orders = event.snapshot.value as Map<dynamic, dynamic>;
//       List<Map<dynamic, dynamic>> filteredOrders = [];
//
//       orders.forEach((key, value) {
//         String orderDateStr = value['date'].substring(0, value['date'].length - 4); // Remove the last 4 characters (time part)
//         if (orderDateStr.compareTo(startDateStr) >= 0 && orderDateStr.compareTo(endDateStr) <= 0) {
//           if (value['status'].toString().toLowerCase() == 'deliver') {
//             filteredOrders.add(value);
//           }
//         }
//       });
//
//       setState(() {
//         _filteredData = filteredOrders;
//       });
//     });
//   }
//
//   Widget _buildChart() {
//     if (_filteredData.isEmpty) {
//       return Container(); // Return empty container if there is no data
//     }
//
//     List<FlSpot> spots = [];
//     List<String> dates = [];
//
//     for (int i = 0; i < _filteredData.length; i++) {
//       double x = i.toDouble();
//       double y = (double.parse(_filteredData[i]['price']) - double.parse(_filteredData[i]['buying'])) * int.parse(_filteredData[i]['number']);
//       spots.add(FlSpot(x, y));
//       dates.add(_filteredData[i]['date'].substring(8, _filteredData[i]['date'].length - 8));
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SizedBox(
//         height: 200,
//         child: LineChart(
//           LineChartData(
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: true,
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(
//                   color: const Color(0xffe7e8ec),
//                   strokeWidth: 1,
//                 );
//               },
//               getDrawingVerticalLine: (value) {
//                 return FlLine(
//                   color: const Color(0xffe7e8ec),
//                   strokeWidth: 1,
//                 );
//               },
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(color: const Color(0xffe7e8ec), width: 1),
//             ),
//             lineBarsData: [
//               LineChartBarData(
//                 spots: spots,
//                 isCurved: true,
//                 barWidth: 2,
//                 color: Colors.blue,
//                 belowBarData: BarAreaData(show: false),
//                 dotData: FlDotData(show: false),
//               ),
//             ],
//             titlesData: FlTitlesData(
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) {
//                     return SideTitleWidget(
//                       axisSide: meta.axisSide,
//                       space: 4.0,
//                       child: Text(
//                         value.toString(),
//                         style: const TextStyle(fontSize: 10),
//                       ),
//                     );
//                   },
//                 ),
//                 axisNameWidget: Text(
//                   'Profit',
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                 ),
//                 axisNameSize: 20,
//               ),
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) {
//                     final index = value.toInt();
//                     if (index >= 0 && index < dates.length) {
//                       return SideTitleWidget(
//                         axisSide: meta.axisSide,
//                         space: 4.0,
//                         child: Text(
//                           dates[index],
//                           style: const TextStyle(fontSize: 10),
//                         ),
//                       );
//                     } else {
//                       return Container();
//                     }
//                   },
//                 ),
//                 axisNameWidget: Text(
//                   'Date',
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                 ),
//                 axisNameSize: 20,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




// if (status == 'false') {
// // Query to find the order by cid
// DataSnapshot snapshot = await oref.orderByChild('cid').equalTo(cid).get();
//
// if (snapshot.exists) {
// Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;
//
// // Find the key for the order to update
// String key = map1.keys.firstWhere((k) => map1[k]['cid'] == cid);
//
// await oref.child(key).update({'status': 'true'}).then((value) {
// ScaffoldMessenger.of(context).showSnackBar(
// const SnackBar(content: Text('Order accepted.')),
// );
// });
// } else {
// ScaffoldMessenger.of(context).showSnackBar(
// const SnackBar(content: Text('Order not found.')),
// );
// }
// } else {
// ScaffoldMessenger.of(context).showSnackBar(
// const SnackBar(content: Text('Order already accepted.')),
// );
// }



//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import '../Authentication/Login.dart';
// import 'HomeScreen.dart';
//
// class Reports extends StatefulWidget {
//   final String uid;
//
//   Reports(this.uid);
//
//   @override
//   _ReportsState createState() => _ReportsState();
// }
//
// class _ReportsState extends State<Reports> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("BuyerOrders");
//   final DatabaseReference _productRef = FirebaseDatabase.instance.ref("Products");
//   DateTime? _startDate;
//   DateTime? _endDate;
//   int totalLength = 0;
//
//   double? profitloss;
//   List<Map<dynamic, dynamic>> _filteredData = [];
//
//   @override
//   Widget build(BuildContext context) {
//     final height = MediaQuery.of(context).size.height;
//
//     Future<double> _calculateTotal(List<dynamic> list) async {
//       double total = 0;
//       setState(() {
//         totalLength = list.length;
//       });
//       for (var node in list) {
//         String pid = node['pid'];
//         double buyingPrice = 0;
//
//         await _productRef.child(pid).get().then((DataSnapshot snapshot) {
//           if (snapshot.exists) {
//             buyingPrice = double.parse(snapshot.child('buying').value.toString());
//           }
//         });
//
//         total += (double.parse(node['price']) - buyingPrice) * int.parse(node['number']);
//       }
//       return total;
//     }
//
//     Future<void> _signOut(BuildContext context) async {
//       try {
//         await _auth.signOut().then((value) {
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => Login()), // Navigate to your login screen
//           );
//         });
//       } catch (e) {
//         print("Error signing out: $e");
//         // Handle sign out error
//       }
//     }
//
//     if (_filteredData.isNotEmpty) {
//       _calculateTotal(_filteredData).then((value) {
//         setState(() {
//           profitloss = value;
//         });
//       });
//     }
//
//     Future<void> _generatePdf() async {
//       final pdf = pw.Document();
//       final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
//       final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);
//
//       pdf.addPage(
//         pw.Page(
//           build: (pw.Context context) {
//             return pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('XOXO Commerce', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//                 pw.SizedBox(height: 20),
//                 pw.Text('Reports', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
//                 pw.SizedBox(height: 10),
//                 pw.Text('Start Date: $startDateStr'),
//                 pw.Text('End Date: $endDateStr'),
//                 pw.SizedBox(height: 10),
//                 pw.Text('Total Orders: $totalLength'),
//                 pw.Text('Profit/Loss: $profitloss'),
//               ],
//             );
//           },
//         ),
//       );
//
//       final output = await getTemporaryDirectory();
//       final file = File("${output.path}/report.pdf");
//       await file.writeAsBytes(await pdf.save());
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('PDF generated!')),
//       );
//
//       // Display the PDF
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PdfViewerScreen(file)),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: Text(
//           'Reports',
//           style: TextStyle(
//             fontSize: height * 0.03,
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Ubuntu',
//           ),
//         ),
//         centerTitle: true,
//         toolbarHeight: height * 0.1,
//         actions: [
//           PopupMenuButton(itemBuilder: (context) {
//             return [
//               PopupMenuItem(
//                 child: Icon(Icons.logout),
//                 onTap: () {
//                   _signOut(context);
//                 },
//               ),
//               PopupMenuItem(
//                 child: Icon(Icons.home),
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) {
//                     return HomeScreen(widget.uid);
//                   }));
//                 },
//               )
//             ];
//           }, iconSize: height * 0.04),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 Expanded(
//                   child: ListTile(
//                     title: Text(
//                       'Start Date: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Not selected'}',
//                       style: TextStyle(fontSize: height * 0.02),
//                     ),
//                     trailing: Icon(Icons.calendar_today, size: height * 0.03),
//                     onTap: () async {
//                       DateTime? pickedDate = await _selectDate(context, _startDate, DateTime.now());
//                       if (pickedDate != null && (_endDate == null || pickedDate.isBefore(_endDate!))) {
//                         setState(() {
//                           _startDate = pickedDate;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('Start date cannot be after end date')),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//                 Expanded(
//                   child: ListTile(
//                     title: Text(
//                       'End Date: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Not selected'}',
//                       style: TextStyle(fontSize: height * 0.02),
//                     ),
//                     trailing: Icon(Icons.calendar_today, size: height * 0.03),
//                     onTap: () async {
//                       DateTime? pickedDate = await _selectDate(context, _endDate, DateTime.now());
//                       if (pickedDate != null && (_startDate == null || pickedDate.isAfter(_startDate!))) {
//                         setState(() {
//                           _endDate = pickedDate;
//                         });
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text('End date cannot be before start date')),
//                         );
//                       }
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (_startDate != null && _endDate != null) {
//                   _filterData();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text('Please select both start and end dates')),
//                   );
//                 }
//               },
//               child: Text('Filter Data'),
//             ),
//             if (_filteredData.isNotEmpty) ...[
//               ElevatedButton(
//                 onPressed: _generatePdf,
//                 child: Text('Generate PDF'),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   'Profit/Loss: $profitloss',
//                   style: TextStyle(fontSize: height * 0.025, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Container(
//                   height: height * 0.3,
//                   child: _buildChart(),
//                 ),
//               ),
//             ],
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _filteredData.length,
//                 itemBuilder: (context, index) {
//                   String name = _filteredData[index]['name'].toString();
//                   String description = _filteredData[index]['description'].toString();
//                   String sellingPrice = _filteredData[index]['price'].toString();
//                   String img = _filteredData[index]['img'].toString();
//                   String number = _filteredData[index]['number'].toString();
//                   String status = _filteredData[index]['status'].toString().toLowerCase();
//                   String date = _filteredData[index]['date'].toString();
//                   double buying = double.parse(_filteredData[index]['buying'].toString());
//
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
//                     child: Card(
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(15.0),
//                         side: BorderSide(
//                           color: status == 'false' ? Colors.red : Colors.green, // Border color
//                           width: 3.0, // Border width
//                         ),
//                       ),
//                       elevation: 10,
//                       child: Container(
//                         padding: EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             ListTile(
//                               contentPadding: EdgeInsets.zero,
//                               title: Text(
//                                 name,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: height * 0.02,
//                                 ),
//                               ),
//                               leading: CircleAvatar(
//                                 radius: height * 0.04,
//                                 backgroundImage: NetworkImage(img),
//                               ),
//                               trailing: Padding(
//                                 padding: const EdgeInsets.only(top: 10.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.end,
//                                   children: [
//                                     Text(
//                                       'Date: $date',
//                                       style: TextStyle(color: Colors.black, fontSize: height * 0.015),
//                                     ),
//                                     Text(
//                                       'Quantity: $number',
//                                       style: TextStyle(color: Colors.black, fontSize: height * 0.015),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               subtitle: Text(
//                                 description,
//                                 style: TextStyle(color: Colors.black, fontSize: height * 0.017, overflow: TextOverflow.ellipsis),
//                               ),
//                             ),
//                             Center(
//                               child: (status == 'deliver')
//                                   ? Text(
//                                 'Delivered',
//                                 style: TextStyle(
//                                   fontSize: height * 0.017,
//                                   color: status == 'false' ? Colors.red : Colors.green,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
//                               )
//                                   : Text('Pending', style: TextStyle(fontSize: height * 0.017)),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate, DateTime? maxDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: initialDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: maxDate ?? DateTime(2101),
//     );
//     return picked;
//   }
//
//   void _filterData() async {
//     final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
//     final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);
//
//     _databaseRef.orderByChild("sid").equalTo(widget.uid).once().then((DatabaseEvent event) {
//       Map<dynamic, dynamic> orders = event.snapshot.value as Map<dynamic, dynamic>;
//       List<Map<dynamic, dynamic>> filteredOrders = [];
//
//       orders.forEach((key, value) {
//         String orderDateStr = value['date'].substring(0, value['date'].length - 4); // Remove the last 4 characters (time part)
//         if (orderDateStr.compareTo(startDateStr) >= 0 && orderDateStr.compareTo(endDateStr) <= 0) {
//           if (value['status'].toString().toLowerCase() == 'deliver') {
//             filteredOrders.add(value);
//           }
//         }
//       });
//
//       setState(() {
//         _filteredData = filteredOrders;
//       });
//     });
//   }
//
//   Widget _buildChart() {
//     if (_filteredData.isEmpty) {
//       return Container(); // Return empty container if there is no data
//     }
//
//     List<FlSpot> spots = [];
//     List<String> dates = [];
//
//     for (int i = 0; i < _filteredData.length; i++) {
//       double x = i.toDouble();
//       double y = (double.parse(_filteredData[i]['price']) - double.parse(_filteredData[i]['buying'])) * int.parse(_filteredData[i]['number']);
//       spots.add(FlSpot(x, y));
//       dates.add(_filteredData[i]['date'].substring(8, _filteredData[i]['date'].length - 8));
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SizedBox(
//         height: MediaQuery.of(context).size.height * 0.3,
//         child: LineChart(
//           LineChartData(
//             gridData: FlGridData(
//               show: true,
//               drawVerticalLine: true,
//               getDrawingHorizontalLine: (value) {
//                 return FlLine(
//                   color: const Color(0xffe7e8ec),
//                   strokeWidth: 1,
//                 );
//               },
//               getDrawingVerticalLine: (value) {
//                 return FlLine(
//                   color: const Color(0xffe7e8ec),
//                   strokeWidth: 1,
//                 );
//               },
//             ),
//             borderData: FlBorderData(
//               show: true,
//               border: Border.all(color: const Color(0xffe7e8ec), width: 1),
//             ),
//             lineBarsData: [
//               LineChartBarData(
//                 spots: spots,
//                 isCurved: true,
//                 barWidth: 2,
//                 color: Colors.blue,
//                 belowBarData: BarAreaData(show: false),
//                 dotData: FlDotData(show: false),
//               ),
//             ],
//             titlesData: FlTitlesData(
//               leftTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) {
//                     return SideTitleWidget(
//                       axisSide: meta.axisSide,
//                       space: 4.0,
//                       child: Text(
//                         value.toString(),
//                         style: const TextStyle(fontSize: 10),
//                       ),
//                     );
//                   },
//                 ),
//                 axisNameWidget: Text(
//                   'Profit',
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                 ),
//                 axisNameSize: 20,
//               ),
//               bottomTitles: AxisTitles(
//                 sideTitles: SideTitles(
//                   showTitles: true,
//                   reservedSize: 40,
//                   getTitlesWidget: (value, meta) {
//                     final index = value.toInt();
//                     if (index >= 0 && index < dates.length) {
//                       return SideTitleWidget(
//                         axisSide: meta.axisSide,
//                         space: 4.0,
//                         child: Text(
//                           dates[index],
//                           style: const TextStyle(fontSize: 10),
//                         ),
//                       );
//                     } else {
//                       return Container();
//                     }
//                   },
//                 ),
//                 axisNameWidget: Text(
//                   'Date',
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//                 ),
//                 axisNameSize: 20,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class PdfViewerScreen extends StatelessWidget {
//   final File pdfFile;
//
//   PdfViewerScreen(this.pdfFile);
//
//   @override
//   Widget build(BuildContext context) {
//     // Implement your PDF viewer logic here, you can use a package like 'flutter_pdfview' or 'advance_pdf_viewer'
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('PDF Viewer'),
//       ),
//       body: Center(
//         child: Text('Display the PDF here using a suitable package'),
//       ),
//     );
//   }
// }
