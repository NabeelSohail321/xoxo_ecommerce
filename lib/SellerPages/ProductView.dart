import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../Login.dart';

class ProductView extends StatefulWidget {
  String pid;


  ProductView(this.pid);

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final storref = FirebaseStorage.instance;
  dynamic pickfile;
  File? file;
  String? img;
  String? img1;
  String? name;
  String? description;
  String? quantity;
  String? selling;
  String? buying;

  final dref = FirebaseDatabase.instance.ref("Products");
  final _namecontroller = TextEditingController();
  final _descriptioncontroller =TextEditingController();
  final _quantitycontroller = TextEditingController();
  final _sellingcontroller = TextEditingController();
  final _buyingcontroller = TextEditingController();



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


  Future<void> uploadImage(String id, {String? existingImageUrl}) async {
    await getImage(); // Assuming getImage() sets file or pickfile
    try {
      if (file != null || pickfile != null) {
        // Check if there is an existing image to delete
        if (existingImageUrl != null) {
          final Uri uri = Uri.parse(existingImageUrl);
          final String encodedPath = uri.pathSegments.last;
          final String filePath = Uri.decodeComponent(encodedPath);

          // Get a reference to the existing file
          final Reference existingImageRef = storref.ref().child(filePath);

          // Delete the existing file
          await existingImageRef.delete().then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Existing image deleted")),
            );
          }).catchError((error) {
            print("Error deleting existing image: $error");
          });
        }

        // Upload the new image
        final imageRef = storref.ref().child("Products/${id}.jpg");
        UploadTask uploadTask;
        if (kIsWeb) {
          final byte = await pickfile.readAsBytes();
          uploadTask = imageRef.putData(byte);
        } else {
          uploadTask = imageRef.putFile(file!);
        }

        final snapshot = await uploadTask.whenComplete(() {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("New image uploaded")));
        });

        img1 = await snapshot.ref.getDownloadURL();
        print("Image URL: $img1");
      }
    } catch (e) {
      print("Error uploading image: $e");
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
            stream: dref.orderByChild("pid").equalTo(widget.pid).onValue,
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
                      description = list[index]['description'].toString();
                      img = list[index]['img'].toString();
                      selling = list[index]['selling'];
                      buying = list[index]['buying'];
                      quantity = list[index]['quantity'];


                      return Center(
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () async{
                                  await uploadImage(widget.pid);
                                  dref.child(widget.pid).update({
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
                                                      await dref.child(widget.pid).update({
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
                                    title: Text(description!),
                                    trailing: IconButton(onPressed: (){
                                      showDialog(context: context, builder: (context) {
                                        return AlertDialog(
                                          scrollable: true,
                                          content: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              TextField(
                                                controller: _descriptioncontroller,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter Description',
                                                  labelText: 'Description',
                                                ),
                                              ),
                                              SizedBox(height: 20,),
                                              Center(
                                                child: Row(

                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(onPressed: ()async{
                                                      await dref.child(widget.pid).update({
                                                        "description": _descriptioncontroller.text.toString()
                                                      });
                                                      setState(() {
                                                        _descriptioncontroller.text='';
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
                                    title: Text(quantity!),
                                    trailing: IconButton(onPressed: (){
                                      showDialog(context: context, builder: (context) {
                                        return AlertDialog(
                                          scrollable: true,
                                          content: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              TextField(
                                                controller: _quantitycontroller,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter quantity',
                                                  labelText: 'quantity',
                                                ),
                                              ),
                                              SizedBox(height: 20,),
                                              Center(
                                                child: Row(

                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(onPressed: ()async{
                                                      await dref.child(widget.pid).update({
                                                        "quantity": _quantitycontroller.text.toString()
                                                      });
                                                      setState(() {
                                                        _quantitycontroller.text='';
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
                                    title: Text(selling!),
                                    trailing: IconButton(onPressed: (){
                                      showDialog(context: context, builder: (context) {
                                        return AlertDialog(
                                          scrollable: true,
                                          content: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              TextField(
                                                controller: _sellingcontroller,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter selling price',
                                                  labelText: 'Price',
                                                ),
                                              ),
                                              SizedBox(height: 20,),
                                              Center(
                                                child: Row(

                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(onPressed: ()async{
                                                      await dref.child(widget.pid).update({
                                                        "selling": _sellingcontroller.text.toString()
                                                      });
                                                      setState(() {
                                                        _sellingcontroller.text='';
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
                                    title: Text(buying!),
                                    trailing: IconButton(onPressed: (){
                                      showDialog(context: context, builder: (context) {
                                        return AlertDialog(
                                          scrollable: true,
                                          content: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              TextField(
                                                controller: _buyingcontroller,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter Buying price',
                                                  labelText: 'Price',
                                                ),
                                              ),
                                              SizedBox(height: 20,),
                                              Center(
                                                child: Row(

                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(onPressed: ()async{
                                                      await dref.child(widget.pid).update({
                                                        "buying": _buyingcontroller.text.toString()
                                                      });
                                                      setState(() {
                                                        _buyingcontroller.text='';
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
