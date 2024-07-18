import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'Login.dart';
import 'Verification.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();
  String role = '1'; // Initialize with a default value
  String? url;
  File? file;
  dynamic pickfile;
  final storref = FirebaseStorage.instance;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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

  // Future<void> uploadImage() async {
  //   try {
  //     if (file != null || pickfile != null) {
  //       final imageRef = storref.ref()
  //           .child("Images/${DateTime.now().millisecondsSinceEpoch}.jpg");
  //       UploadTask uploadTask;
  //       if (kIsWeb) {
  //         final byte = await pickfile.readAsBytes();
  //         uploadTask = imageRef.putData(byte);
  //       } else {
  //         uploadTask = imageRef.putFile(file!);
  //       }
  //
  //       final snapshot = await uploadTask.whenComplete(() {
  //         ScaffoldMessenger.of(context)
  //             .showSnackBar(SnackBar(content: Text("Image Uploaded")));
  //       });
  //
  //       url = await snapshot.ref.getDownloadURL();
  //       print("Image URL: $url");
  //     }
  //   } catch (e) {
  //     print("Error uploading image: $e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
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
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.1),
          child: Column(
            children: [
              (file != null || pickfile != null)
                  ? CircleAvatar(
                radius: 60,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(60)),
                    image: DecorationImage(
                      image: kIsWeb
                          ? NetworkImage(pickfile.path) as ImageProvider
                          : FileImage(file!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
                  : InkWell(
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
                      decoration: InputDecoration(labelText: "Name"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: "Email"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(
                            r"^[a-zA-Z0-9.!#$%&'*+/=?^_{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$")
                            .hasMatch(value)) {
                          return "Please enter a valid email";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(labelText: "Phone Number"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        } else if (!RegExp(r'^\+92\d{10}$').hasMatch(value)) {
                          return 'Please enter a valid phone number in the format +92 3XXXXXXXXX';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: "Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 8) {
                          return 'Your password must be at least 8 characters long';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        } else if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: height * 0.02),
                    SizedBox(height: 20),
                    PopupMenuButton<String>(
                      initialValue: role, // Set initial value here
                      onSelected: (String value) {
                        setState(() {
                          role = value;
                        });
                      },
                      itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: '1',
                          child: Text('Seller'),
                        ),
                        const PopupMenuItem<String>(
                          value: '2',
                          child: Text('Buyer'),
                        ),
                        const PopupMenuItem<String>(
                          value: '3',
                          child: Text('Rider'),
                        ),
                      ],
                      child: ListTile(
                        title: Text('Role'),
                        trailing: Text(
                          role == '1'
                              ? 'Seller'
                              : role == '2'
                              ? 'Buyer'
                              : 'Rider',
                        ),
                        leading: Icon(
                          role == '1'
                              ? Icons.person
                              : role == '2'
                              ? Icons.shopping_cart
                              : Icons.electric_bike,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          // await uploadImage();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Verification(
                                phoneNumber: _phoneController.text,
                                name: _nameController.text,
                                email: _emailController.text,
                                password: _passwordController.text,
                                role: role,
                                file: file,
                                pickfile: pickfile,
                              ),
                            ),
                          );
                        }
                      },
                      child: Text('Sign Up'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()));
                          });
                        },
                        child: Text(
                          'Login?',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
