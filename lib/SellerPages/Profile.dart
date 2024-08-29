import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../Authentication/Login.dart';

class Profile extends StatefulWidget {
  String uid;

  Profile(this.uid);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final dref = FirebaseDatabase.instance.ref("User");
   final _namecontroller = TextEditingController();
   final _addresscontroller= TextEditingController();
   final _phonecontroller= TextEditingController();
   final _zipcodecontroller=TextEditingController();
  String? img;

  String? name;
  String? email;
  dynamic pickfile;
  File? file;
  String? img1;
  String? address;
   String? Phone;
   String? zipcode;

  final storref = FirebaseStorage.instance;
  GoogleMapController? _controller;

  bool _isLoading = true;
  LatLng _currentPosition =  LatLng(31.5925, 74.3095);


  Future<void> _getUserLocation() async {
    Position position = await _determinePosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    try{
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition.latitude,
          _currentPosition.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String fullAddress = '${place.street}, ${place.locality}, ${place
            .postalCode}, ${place.country}';
        setState(() {
          _addresscontroller.text = fullAddress;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location fetched successfully")),
        );

      }

      }catch(e){
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch address")),
      );
    }
    _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition));

  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }


  Future<void> getImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        setState(() {
          pickfile = image;
        });
      } else {
        setState(() {
          file = File(image.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Image Selected")));
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


  Future<void> uploadImage(String id) async {
    await getImage();
    try {
      if (file != null || pickfile != null) {

        Reference storageRef = storref.ref().child('Images/${widget.uid}.jpg');
        await storageRef.delete();

        final imageRef = storref.ref()
            .child("Images/${id}.jpg");

        UploadTask uploadTask;
        if (kIsWeb) {
          final byte = await pickfile.readAsBytes();
          uploadTask = imageRef.putData(byte);
        } else {
          uploadTask = imageRef.putFile(file!);
        }

        final snapshot = await uploadTask.whenComplete(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Image Uploaded")));
        });

        img1 = await snapshot.ref.getDownloadURL();
        print("Image URL: $img");
      }
    } catch (e) {
      print("Error uploading image: $e");
    }
  }


  @override
  Widget build(BuildContext context) {

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
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
        toolbarHeight: height * 0.1,
        actions: [
          Padding(
              padding:  EdgeInsets.symmetric(vertical: height* 0.04, horizontal: height* 0.01 ),
              child: InkWell(onTap: (){
                _signOut(context);
              },
                  child: Icon(Icons.logout, size: height*0.05,color: Colors.black,))
          )
        ],

      ),
      body: Padding(
        padding:  EdgeInsets.symmetric(vertical: 18.0),
        child: Column(
          children: [

            Expanded(child: StreamBuilder(
              stream: dref.orderByChild("uid").equalTo(widget.uid).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      backgroundColor: Colors.grey[200],
                      strokeWidth: 4.0,
                    ),
                  );
                }
               else{
                  Map<dynamic,dynamic> map=snapshot.data!.snapshot.value as dynamic;
                  List<dynamic>? list=[];
                  list.clear();
                  list=map.values.toList();
                  return ListView.builder(
                    itemCount: list.length,
                  itemBuilder: (context,index){
                      name = list![index]['name'].toString();
                      email = list[index]['email'].toString();
                     img = list[index]['img'].toString();
                     address = list[index]['address'].toString();
                     Phone=list[index]['phone'].toString();
                     zipcode=list[index]['zipcode'].toString();


                     // _namecontroller.text=name!;
                     return Center(
                       child: Column(
                         children: [
                           InkWell(
                             onTap: () async{
                              await uploadImage(widget.uid);
                              dref.child(widget.uid).update({
                                "img": img1
                              });
                             },
                             child: CircleAvatar(
                               backgroundImage: NetworkImage(img!) as ImageProvider,
                               radius: 100,
                             ),
                           ),
                           Padding(
                             padding:  EdgeInsets.symmetric(vertical:height*0.01,
                                 horizontal: height*0.03),
                             child: Container(

                               decoration: BoxDecoration(
                                 border: Border.all(
                                   color: Colors.black12, // Border color
                                   width: 2.0, // Border width
                                 ),
                                 borderRadius: BorderRadius.circular(10.0), // Border radius
                               ),
                               child: ListTile(
                                 title: Text(name!),
                                 trailing: IconButton(onPressed: (){
                                   showDialog(context: context, builder: (context) {
                                     return AlertDialog(
                                       scrollable: true,
                                       content: Column(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         crossAxisAlignment: CrossAxisAlignment.center,
                                         children: [
                                           Padding(
                                             padding:  EdgeInsets.symmetric(vertical: height*0.02),
                                             child: TextField(

                                               controller: _namecontroller,
                                               decoration: InputDecoration(
                                                 focusedBorder: OutlineInputBorder(
                                                   borderSide: BorderSide(
                                                     color: Colors.black12, // Border color when not focused
                                                     width: 1.0, // Border width
                                                   ),
                                                   borderRadius: BorderRadius.circular(10.0),
                                                 ),
                                                 hintText: 'Enter name',
                                                 labelText: 'Name',
                                                 enabledBorder: OutlineInputBorder(
                                                   borderSide: BorderSide(
                                                     color: Colors.black12, // Border color when not focused
                                                     width: 1.0, // Border width
                                                   ),
                                                   borderRadius: BorderRadius.circular(10.0),
                                                 ),
                                               ),
                                             ),
                                           ),
                                           SizedBox(height: 20,),
                                           Center(
                                             child: Row(

                                               mainAxisAlignment: MainAxisAlignment.center,
                                               children: [
                                                 ElevatedButton(onPressed: ()async{
                                                  await dref.child(widget.uid).update({
                                                     "name": _namecontroller.text.toString()
                                                   });
                                                  setState(() {
                                                    _namecontroller.text='';
                                                  });
                                                  Navigator.pop(context);
                                                 }, child: Text('save')),
                                                 Padding(
                                                   padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                                   child: ElevatedButton(onPressed: (){

                                                     Navigator.pop(context);
                                                   }, child: Text('cancel')),
                                                 )
                                               ],
                                             ),
                                           ),
                                         ],
                                       ),
                                     );
                                   },);
                                 }, icon: Icon(Icons.edit))
                               ),
                             ),
                           ),
                           Padding(
                             padding:  EdgeInsets.symmetric(vertical: height *0.01,
                                 horizontal: height*0.03),
                             child: Container(
                               decoration: BoxDecoration(
                                 border: Border.all(
                                   color: Colors.black12, // Border color
                                   width: 2.0, // Border width
                                 ),
                                 borderRadius: BorderRadius.circular(10.0), // Border radius
                               ),

                               child: ListTile(
                                   title: Text(email!),
                               ),
                             ),
                           ),
                           Padding(
                             padding:  EdgeInsets.symmetric(vertical:height*0.01,
                                 horizontal: height*0.03),
                             child: Container(

                               decoration: BoxDecoration(
                                 border: Border.all(
                                   color: Colors.black12, // Border color
                                   width: 2.0, // Border width
                                 ),
                                 borderRadius: BorderRadius.circular(10.0), // Border radius
                               ),
                               child: ListTile(
                                   title: Text(address!=null? '${address}':'No Address Found'),
                                   trailing: IconButton(onPressed: (){
                                     showDialog(context: context, builder: (context) {
                                       return StatefulBuilder(builder: (BuildContext context, StateSetter setState){
                                         return AlertDialog(
                                             scrollable: true,
                                             content: Column(
                                               children: [
                                                 ClipRRect(
                                                   borderRadius: BorderRadius.circular(20),
                                                   clipBehavior: Clip.hardEdge,
                                                   child: Container(
                                                     decoration: BoxDecoration(
                                                       border: Border.all(width: 5,style: BorderStyle.solid),
                                                       borderRadius: BorderRadius.circular(20),
                                                     ),
                                                     height: 400,
                                                     width: 800,
                                                     child: GoogleMap(
                                                       onMapCreated: (GoogleMapController controller) {
                                                         _controller = controller;
                                                       },

                                                       initialCameraPosition: CameraPosition(
                                                         target: _currentPosition,
                                                         zoom: 14.0,
                                                       ),
                                                       markers: {
                                                         Marker(
                                                           markerId: const MarkerId("currentLocation"),
                                                           position: _currentPosition,
                                                         ),
                                                       },
                                                     ),
                                                   ),
                                                 ),

                                                 SizedBox(height: 20,),
                                                 Center(
                                                   child: Row(

                                                     mainAxisAlignment: MainAxisAlignment.center,
                                                     children: [
                                                       ElevatedButton(onPressed: ()async{
                                                         await _getUserLocation();
                                                         setState(() {
                                                           _controller?.animateCamera(CameraUpdate.newLatLng(_currentPosition));
                                                           // _addresscontroller.text=_currentPosition.toString();
                                                         });
                                                         await Future.delayed(Duration(seconds: 5));

                                                         if(_currentPosition!=LatLng(31.5925, 74.3095)){
                                                           await dref.child(widget.uid).update({
                                                             "longitude": _currentPosition.longitude,
                                                             "latitude": _currentPosition.latitude,
                                                             "address": _addresscontroller.text

                                                           });
                                                         }
                                                         else {

                                                         }

                                                         Navigator.pop(context);
                                                       }, child: Text('select current location')),
                                                     ],
                                                   ),
                                                 ),
                                               ],
                                             )
                                         );
                                       });
                                     },);
                                   }, icon: Icon(Icons.edit))
                               ),
                             ),
                           ),
                           Padding(
                             padding:  EdgeInsets.symmetric(vertical:height*0.01,
                                 horizontal: height*0.03),
                             child: Container(

                               decoration: BoxDecoration(
                                 border: Border.all(
                                   color: Colors.black12, // Border color
                                   width: 2.0, // Border width
                                 ),
                                 borderRadius: BorderRadius.circular(10.0), // Border radius
                               ),
                               child: ListTile(
                                   title: Text(Phone!),
                                   trailing: IconButton(onPressed: (){
                                     showDialog(context: context, builder: (context) {
                                       return AlertDialog(
                                         scrollable: true,
                                         content: Column(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           crossAxisAlignment: CrossAxisAlignment.center,
                                           children: [
                                             Padding(
                                               padding:  EdgeInsets.symmetric(vertical: height*0.02),
                                               child: TextField(

                                                 keyboardType: TextInputType.number,
                                                 controller: _phonecontroller,
                                                 decoration: InputDecoration(
                                                   focusedBorder: OutlineInputBorder(
                                                     borderSide: BorderSide(
                                                       color: Colors.black12, // Border color when not focused
                                                       width: 1.0, // Border width
                                                     ),
                                                     borderRadius: BorderRadius.circular(10.0),
                                                   ),
                                                   hintText: 'Enter Phone Number',
                                                   labelText: 'Phone Number',
                                                   enabledBorder: OutlineInputBorder(
                                                     borderSide: BorderSide(
                                                       color: Colors.black12, // Border color when not focused
                                                       width: 1.0, // Border width
                                                     ),
                                                     borderRadius: BorderRadius.circular(10.0),
                                                   ),
                                                 ),
                                               ),
                                             ),
                                             SizedBox(height: 20,),
                                             Center(
                                               child: Row(

                                                 mainAxisAlignment: MainAxisAlignment.center,
                                                 children: [
                                                   ElevatedButton(onPressed: ()async{
                                                     await dref.child(widget.uid).update({
                                                       "phone": _phonecontroller.text.toString()
                                                     });
                                                     setState(() {
                                                       _phonecontroller.text='';
                                                     });
                                                     Navigator.pop(context);
                                                   }, child: Text('save')),
                                                   Padding(
                                                     padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                                     child: ElevatedButton(onPressed: (){
                                                       Navigator.pop(context);
                                                     }, child: Text('cancel')),
                                                   )
                                                 ],
                                               ),
                                             ),
                                           ],
                                         ),
                                       );
                                     },);
                                   }, icon: Icon(Icons.edit))
                               ),
                             ),
                           ),
                           Padding(
                             padding:  EdgeInsets.symmetric(vertical:height*0.01,
                               horizontal: height*0.03
                             ),
                             child: Container(

                               decoration: BoxDecoration(
                                 border: Border.all(
                                   color: Colors.black12, // Border color
                                   width: 2.0, // Border width
                                 ),
                                 borderRadius: BorderRadius.circular(10.0), // Border radius
                               ),
                               child: ListTile(
                                   title: Text(zipcode!),
                                   trailing: IconButton(onPressed: (){
                                     showDialog(context: context, builder: (context) {
                                       return AlertDialog(
                                         scrollable: true,
                                         content: Column(
                                           mainAxisAlignment: MainAxisAlignment.center,
                                           crossAxisAlignment: CrossAxisAlignment.center,
                                           children: [
                                             Padding(
                                               padding:  EdgeInsets.symmetric(vertical: height*0.02),
                                               child: TextField(

                                                 keyboardType: TextInputType.number,
                                                 controller: _zipcodecontroller,
                                                 decoration: InputDecoration(
                                                   focusedBorder: OutlineInputBorder(
                                                     borderSide: BorderSide(
                                                       color: Colors.black12, // Border color when not focused
                                                       width: 1.0, // Border width
                                                     ),
                                                     borderRadius: BorderRadius.circular(10.0),
                                                   ),
                                                   hintText: 'Enter ZipCode',
                                                   labelText: 'Zipcode',
                                                   enabledBorder: OutlineInputBorder(
                                                     borderSide: BorderSide(
                                                       color: Colors.black12, // Border color when not focused
                                                       width: 1.0, // Border width
                                                     ),
                                                     borderRadius: BorderRadius.circular(10.0),
                                                   ),
                                                 ),
                                               ),
                                             ),
                                             SizedBox(height: 20,),
                                             Center(
                                               child: Row(

                                                 mainAxisAlignment: MainAxisAlignment.center,
                                                 children: [
                                                   ElevatedButton(onPressed: ()async{
                                                     await dref.child(widget.uid).update({
                                                       "zipcode": _zipcodecontroller.text.toString()
                                                     });
                                                     setState(() {
                                                       _zipcodecontroller.text='';
                                                     });
                                                     Navigator.pop(context);
                                                   }, child: Text('save')),
                                                   Padding(
                                                     padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                                     child: ElevatedButton(onPressed: (){
                                                       Navigator.pop(context);
                                                     }, child: Text('cancel')),
                                                   )
                                                 ],
                                               ),
                                             ),
                                           ],
                                         ),
                                       );
                                     },);
                                   }, icon: Icon(Icons.edit))
                               ),
                             ),
                           ),



                         ],
                       )
                     );

                  });
                }
              },
            ))


          ],
        ),
      ),
    );
  }
}
