import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart' hide Card;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../Authentication/Login.dart';
import '../Components/payment.dart';
import '../Components/textfield.dart';

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
  final userRef = FirebaseDatabase.instance.ref('User');
  final OrderRef = FirebaseDatabase.instance.ref('orders');
  String? phone;
  double deliveryCharges=0;
  late LatLng _userPosition;
  LatLng _wareHousePosition = LatLng(32.09378, 74.18540);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _noDataFound = false;
  double? calculatedTotal;
  double? subtotal;
  String? name;
  String? description;
  String? img;
  String? number;
  String? price;
  String? pid;
  String? date;
  double distance=0;


  TextEditingController amountController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  final formkey1 = GlobalKey<FormState>();
  final formkey2 = GlobalKey<FormState>();
  final formkey3 = GlobalKey<FormState>();
  final formkey4 = GlobalKey<FormState>();
  final formkey5 = GlobalKey<FormState>();
  final formkey6 = GlobalKey<FormState>();
  List<String> currencyList = <String>[
    'USD',
    'INR',
    'EUR',
    'JPY',
    'GBP',
    'AED'
  ];
  String selectedCurrency = 'USD';
  bool hasDonated = false;

  Future<void> initPaymentSheet() async {
    try {
      // 1. create payment intent on the server
      final data = await cretaePaymentIntent(
          amount: (int.parse(amountController.text)*100).toString(),
          currency: selectedCurrency,
          name: nameController.text,
          address: addressController.text,
          pin: pincodeController.text,
          city: cityController.text,
          state: stateController.text,
          country: countryController.text);
      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Set to true for custom flow
          customFlow: false,
          // Main params
          merchantDisplayName: 'Nabeel',
          paymentIntentClientSecret: data['client_secret'],
          // Customer keys
          customerEphemeralKeySecret: data['ephemeralKey'],
          customerId: data['id'],
          // Extra options

          style: ThemeMode.dark,
        ),
      );
      setState(() {

      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      rethrow;
    }
  }


  Future<void> paymentDialogue() async{
    return showDialog(
        context: context,
        builder: (BuildContext bcontext) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                scrollable: true,
                content: Column(
                  children: [
                    // Image(
                    //   image: AssetImage("assets/image.jpg"),
                    //   height: 300,
                    //   width: double.infinity,
                    //   fit: BoxFit.cover,
                    // ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Support us with your donations",
                                style:
                                TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 6,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: ReusableTextField(
                                        formkey: formkey,
                                        controller: amountController,
                                        isNumber: true,
                                        title: "Donation Amount",
                                        hint: "Any amount you like"),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  DropdownMenu<String>(
                                    inputDecorationTheme: InputDecorationTheme(
                                        contentPadding: EdgeInsets.symmetric(
                                            vertical: 20, horizontal: 0),
                                        enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey.shade600,
                                          ),
                                        )
                                    ),
                                    initialSelection: currencyList.first,
                                    onSelected: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        selectedCurrency = value!;
                                      });
                                    },
                                    dropdownMenuEntries: currencyList
                                        .map<DropdownMenuEntry<String>>((String value) {
                                      return DropdownMenuEntry<String>(
                                          value: value, label: value);
                                    }).toList(),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ReusableTextField(
                                formkey: formkey1,
                                title: "Name",
                                hint: "Ex. John Doe",
                                controller: nameController,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ReusableTextField(
                                formkey: formkey2,
                                title: "Address Line",
                                hint: "Ex. 123 Main St",
                                controller: addressController,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: ReusableTextField(
                                        formkey: formkey3,
                                        title: "City",
                                        hint: "Ex. New Delhi",
                                        controller: cityController,
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      flex: 5,
                                      child: ReusableTextField(
                                        formkey: formkey4,
                                        title: "State (Short code)",
                                        hint: "Ex. DL for Delhi",
                                        controller: stateController,
                                      )),
                                ],
                              ),

                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: ReusableTextField(
                                        formkey: formkey5,
                                        title: "Country (Short Code)",
                                        hint: "Ex. IN for India",
                                        controller: countryController,
                                      )),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                      flex: 5,
                                      child: ReusableTextField(
                                        formkey: formkey6,
                                        title: "Pincode",
                                        hint: "Ex. 123456",
                                        controller: pincodeController,
                                        isNumber: true,
                                      )),
                                ],
                              ),
                              SizedBox(
                                height: 12,
                              ),
                              SizedBox(
                                height: 50,
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blueAccent.shade400),
                                  child: Text(
                                    "Proceed to Pay",
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                  onPressed: () async {
                                    if (formkey.currentState!.validate() &&
                                        formkey1.currentState!.validate() &&
                                        formkey2.currentState!.validate() &&
                                        formkey3.currentState!.validate() &&
                                        formkey4.currentState!.validate() &&
                                        formkey5.currentState!.validate() &&
                                        formkey6.currentState!.validate()) {
                                      await initPaymentSheet();

                                      try{
                                        await Stripe.instance.presentPaymentSheet();

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            "Payment Done",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.green,
                                        ));


                                        setState(() {
                                          hasDonated=true;
                                        });
                                        nameController.clear();
                                        addressController.clear();
                                        cityController.clear();
                                        stateController.clear();
                                        countryController.clear();
                                        pincodeController.clear();
                                        Navigator.pop(context);

                                      }catch(e){
                                        print("payment sheet failed");
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            "Payment Failed",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ));
                                      }

                                    }
                                  },
                                ),
                              )
                            ])),
                  ],
                )
              );
            },
          );
        },
      );
  }


  List<Map<String, String>> quantity = [];

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

  Future<String?> getUserPhone(String userId) async {
    final snapshot = await userRef.child(userId).get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data['phone'] as String?;
    }
    return null;
  }

  Future<void> _calculatedeliveryCharges(String uid) async {
    try {
      final snapshot = await userRef.child(uid).get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> map = snapshot.value as Map<dynamic, dynamic>;

        // Check and parse latitude and longitude as double
        double latitude = map['latitude'] is double
            ? map['latitude']
            : double.tryParse(map['latitude'].toString()) ?? 0.0;
        double longitude = map['longitude'] is double
            ? map['longitude']
            : double.tryParse(map['longitude'].toString()) ?? 0.0;

        setState(() {
          _userPosition = LatLng(latitude, longitude);
        });

        setState(() {
          distance = Geolocator.distanceBetween(
            _userPosition.latitude,
            _userPosition.longitude,
            _wareHousePosition.latitude,
            _wareHousePosition.longitude,
          );
        });

        if (distance >= 3000) {
          setState(() {
            deliveryCharges += ((distance-3000) / 1000) * 100;
          });
        }
      } else {
        print("User data not found.");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User data not found')),
        );
      }
    } catch (e) {
      print("Failed to calculate delivery charges: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error calculating delivery charges: $e')),
      );
    }
  }

  double _calculateTotal(List<dynamic> list) {
    double total = 0;
    for (var node in list) {
      total += double.parse(node['price']) * int.parse(node['number']);
    }
      total=total+deliveryCharges;

    return total;
  }
  double _calculatesubTotal(List<dynamic> list) {
    double total = 0;
    for (var node in list) {
      total += double.parse(node['price']) * int.parse(node['number']);
    }


    return total;
  }

  Future<void> _updateQuantity(String number, String pid) async {
    DataSnapshot snapshot = await pref.child(pid).get();

    if (snapshot.exists) {
      Map<dynamic, dynamic> map1 = snapshot.value as Map<dynamic, dynamic>;

      String quantity = map1['quantity'].toString();
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

  Future<void> _removeFromCart(String uid, String pid) async {
    await cref.child(uid).child(pid).remove();
    setState(() {
      quantity.removeWhere((item) => item['pid'] == pid);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product removed from cart.')),
    );
  }

  @override
  void initState() {
    super.initState();
    _calculatedeliveryCharges(widget.uid);
    getUserPhone(widget.uid).then((fetchedPhone) {
      setState(() {
        phone = fetchedPhone;
      });
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
              stream: cref.child(widget.uid).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData) {
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
                  subtotal= _calculatesubTotal(list);

                  quantity = list.map((item) {
                    return {
                      'number': item['number'].toString(),
                      'pid': item['pid'].toString(),
                    };
                  }).toList();

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
                                              Text('Quantity: $number'),
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
                                      Center(
                                        child: IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _removeFromCart(widget.uid, pid!);
                                          },
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
                          'Sub Total: ${subtotal?.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: height * 0.03, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Delivery charges: ${deliveryCharges?.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: height * 0.03, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Center(
                        child: Text(
                          'Total Bill: ${calculatedTotal?.toStringAsFixed(2)}',
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
            for (var item in quantity) {
              await _updateQuantity(item['number']!, item['pid']!);
            }

            setState(() {
              double number = double.parse(calculatedTotal.toString());
              int intNumber = number.toInt();
              String result = intNumber.toString();
              amountController.text= result;
            });
            await paymentDialogue();
            final DatabaseService2 dbService2 = DatabaseService2();
           await dbService2.moveData('Cart/${widget.uid}', 'orders', {'status': 'false', 'phone': phone,},subtotal!,deliveryCharges,date!,widget.uid,'false');

            final DatabaseService dbService = DatabaseService();
            dbService.moveData('Cart/${widget.uid}', 'BuyerOrders', {'status': 'false', 'phone': phone}).then((value) {
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
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool hasdata = false;
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

class DatabaseService2 {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> moveData(
      String sourcePath,
      String destinationPath,
      Map<dynamic, dynamic> additionalData,
      double subtotal,
      double deliveryCharges,
      String date,
      String uid,
      String status
      ) async {
    try {
      // Step 1: Read the data from the source reference
      DataSnapshot sourceSnapshot = await _dbRef.child(sourcePath).get();

      if (sourceSnapshot.exists) {
        Map<dynamic, dynamic> sourceData = Map<dynamic, dynamic>.from(sourceSnapshot.value as dynamic);

        // Step 2: Check if there's an existing order with the same date for this user
        Query existingOrderQuery = _dbRef.child(destinationPath)
            .orderByChild('uid')
            .equalTo(uid);

        DataSnapshot existingOrderSnapshot = await existingOrderQuery.get();
        String? existingOrderKey;

        if (existingOrderSnapshot.exists) {
          // Loop through existing orders to find if any match the same date
          Map<dynamic, dynamic> orders = Map<dynamic, dynamic>.from(existingOrderSnapshot.value as dynamic);
          orders.forEach((key, value) {
            String date1 = value['date'].toString();
            String date2 = date1.substring(0,10);
            if (date.contains(date2)) {
              existingOrderKey = key;
            }
          });
        }

        if (existingOrderKey != null) {
          // Update the existing order with the new items
          DataSnapshot existingOrderItemsSnapshot = await _dbRef.child('$destinationPath/$existingOrderKey/items').get();
          Map<dynamic, dynamic> existingOrderItems = Map<dynamic, dynamic>.from(existingOrderItemsSnapshot.value as dynamic);

          // Merge the items from the cart into the existing order
          sourceData.forEach((cartItemKey, cartItemValue) {
            if (existingOrderItems.containsKey(cartItemValue['pid'])) {
              // If the item already exists in the order, update its quantity
              existingOrderItems[cartItemValue['pid']]['number'] =
                  (int.parse(existingOrderItems[cartItemValue['pid']]['number']) + int.parse(cartItemValue['number'])).toString();
            } else {
              // Otherwise, add the new item to the order
              existingOrderItems[cartItemValue['pid']] = cartItemValue;
            }
          });

          // Calculate new subtotal based on merged items
          double newSubtotal = existingOrderItems.values.fold(0, (previousValue, element) => previousValue + double.parse(element['price']) * int.parse(element['number']));

          // Update the order with the new items, subtotal, and keep delivery charges constant
          await _dbRef.child('$destinationPath/$existingOrderKey/items').set(existingOrderItems);
          await _dbRef.child('$destinationPath/$existingOrderKey').update({
            'subtotal': newSubtotal
          });
          await _dbRef.child('$destinationPath/$existingOrderKey').update({
            'totalBill': (newSubtotal+deliveryCharges)
          });

          print('Order updated with new items for date: $date');
        } else {
          // No order exists for this date, so create a new one
          String cartId = _dbRef.child(destinationPath).push().key!;

          Map<dynamic, dynamic> orderData = {
            'cartId': cartId,
            'items': sourceData,
            'subtotal': subtotal,
            'deliveryCharges': deliveryCharges,
            'totalBill': subtotal + deliveryCharges,
            'date': date,
            'uid': uid,
            'status': status,
            ...additionalData,
          };

          await _dbRef.child('$destinationPath/$cartId').set(orderData);

          print('New order created for date: $date');
        }

        // Optionally, delete the data from the source reference
        // await _dbRef.child(sourcePath).remove();
      } else {
        print('No data found at $sourcePath');
      }
    } catch (e) {
      print('Failed to move data: $e');
    }
  }
}

