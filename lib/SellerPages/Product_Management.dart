import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xoxo_ecommerce/SellerPages/ProductView.dart';
import 'dart:io';
import '../Authentication/Login.dart';
import '../models/Product.dart';

class ProductsPage extends StatefulWidget {
  final String uid;

  ProductsPage(this.uid);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? url;
  File? file;
  XFile? pickfile;
  final storref = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _buyingController = TextEditingController();
  final TextEditingController _sellingController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final dref = FirebaseDatabase.instance.ref("Products");
  bool _noDataFound = false;

  Future<void> getImage() async {
    final ImagePicker imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (kIsWeb) {
          pickfile = image;
        } else {
          file = File(image.path);
        }
      });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("No Image Selected")));
    }
  }

  Future<void> uploadImage() async {
    try {
      if (file != null || pickfile != null) {
        final imageRef = storref.ref()
            .child("Products/${DateTime.now().millisecondsSinceEpoch}.jpg");
        UploadTask uploadTask;
        if (kIsWeb) {
          final byte = await pickfile!.readAsBytes();
          uploadTask = imageRef.putData(byte);
        } else {
          uploadTask = imageRef.putFile(file!);
        }

        final snapshot = await uploadTask.whenComplete(() {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Image Uploaded")));
        });

        url = await snapshot.ref.getDownloadURL();
        print("Image URL: $url");
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Products",style: TextStyle(
                fontSize: height * 0.03,
                fontWeight: FontWeight.bold,
                fontFamily: 'Ubuntu',
              ),)
            ],
          ),
          Expanded(
              child: StreamBuilder(
                stream: dref.orderByChild('uid').equalTo(widget.uid).onValue,
                builder: (context, AsyncSnapshot<DatabaseEvent> snapshot){
                  if(!snapshot.hasData && !_noDataFound){
                    return Center(
                      child: buildCircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                    Map<dynamic,dynamic> map=snapshot.data!.snapshot.value as dynamic;
                    if (map == null) {
                      return Center(child: Text("No Product Found"));
                    }
                    List<dynamic>? list=[];
                    list.clear();
                    list=map.values.toList();

                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        String name = list![index]['name'].toString();
                        String description = list[index]['description'].toString();
                        String quantity = list[index]['quantity'].toString();
                        String img = list[index]['img'].toString();
                        String pid = list[index]['pid'].toString();

                        return (list.length != 0)
                            ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                          child: InkWell(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return ProductView(pid);
                            },));
                          },
                            child: Card(
                              elevation: 10,
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                // constraints: BoxConstraints(minHeight: 60),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text(
                                        name,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      leading: CircleAvatar(
                                        radius: 30,
                                        backgroundImage: NetworkImage(img),
                                      ),
                                      trailing: Text(quantity),
                                      subtitle: Text(
                                        description,
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
                          ),
                        )
                            : Container();
                      },
                    );
                  } else {
                    return Center(child: Text("No Product Found"));
                  }
                },
              ))

        ],
      ),

      floatingActionButton: SizedBox(
        height: 90,
        width: 90,
        child: FloatingActionButton(
          onPressed: (){
            setState(() {
              showmyDialog();
            });
          },
          child: Icon(Icons.add,size: 60,weight: 20,),
        ),
      ),
    );
  }

  Future<void> showmyDialog() async{
    return showDialog(
        context: context, builder: (BuildContext bcontext){
      return AlertDialog(
          scrollable: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (file != null || pickfile != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: kIsWeb
                      ? NetworkImage(pickfile!.path) as ImageProvider
                      : FileImage(file!) ,
                )
              else
                InkWell(
                  onTap: getImage,
                  child: CircleAvatar(
                    radius: 60,
                    child: Icon(
                      Icons.upload_outlined,
                      size: 40,
                    ),
                  ),
                ),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: "Product Name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: "Description"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(labelText: "Quantity"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _buyingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(labelText: "Buying price"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Buying price for this product';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _sellingController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(labelText: "Selling price"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Selling price';
                        }
                        return null;
                      },
                    ),



                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  await uploadImage();
                                  String id = dref.push().key.toString();
                                  Product product = Product(_nameController.text, _descriptionController.text, _quantityController.text, url!,widget.uid,_buyingController.text,_sellingController.text,id!);
                                  await dref.child(id).set(product.tomap()).then((value) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Product Uploaded')),
                                    );
                                  }).onError((error, stackTrace) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error Uploading Product: $error')),
                                    );
                                  });
                                  Navigator.pop(context);
                                }
                                setState(() {
                                  _nameController.text='';
                                  _descriptionController.text='';
                                  _quantityController.text='';
                                  _buyingController.text='';
                                  _sellingController.text='';
                                  pickfile = null;
                                  file = null;
                                });
                              },
                              child: Text('Submit'),
                            ),
                          ),
                          ElevatedButton(onPressed: (){
                            Navigator.pop(context);
                          }, child: Text("Cancel"))
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            ],
          )

      );
    });
  }

  Widget buildCircularProgressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    );
  }

}
