import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../Login.dart';

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
  String? img;

  String? name;
  String? email;
  dynamic pickfile;
  File? file;
  String? img1;

  final storref = FirebaseStorage.instance;

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()), // Navigate to your login screen
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

          Expanded(child: StreamBuilder(
            stream: dref.orderByChild("uid").equalTo(widget.uid).onValue,
            builder: (contex, AsyncSnapshot<DatabaseEvent> snapshot){
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
                           padding: const EdgeInsets.all(10.0),
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
                                       TextField(
                                         controller: _namecontroller,
                                         decoration: InputDecoration(
                                           hintText: 'Enter name',
                                           labelText: 'Name',
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
                         Padding(
                           padding: const EdgeInsets.all(10.0),
                           child: ListTile(
                               title: Text(email!),
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
    );
  }
}
