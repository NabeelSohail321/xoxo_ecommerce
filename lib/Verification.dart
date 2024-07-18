import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xoxo_ecommerce/Login.dart';
import 'package:xoxo_ecommerce/models/signup.dart';
import 'dart:io';

import 'SellerPages/HomeScreen.dart';

class Verification extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String email;
  final String password;
  // final String Url;
  final String role;
  File? file;
  dynamic pickfile;
  // 1 is for seller
  // 2 is for buyer
  // 3 is for ryder
   Verification({
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.file,
    required this.pickfile,
  });

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _codeController = TextEditingController();
  String _verificationId = "";
  bool _isLoading = false;
  final dref = FirebaseDatabase.instance.ref("User");
  final storref = FirebaseStorage.instance;
  String? url;

  String? id;

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }
  Future<void> uploadImage(String id) async {
    try {
      if (widget.file != null || widget.pickfile != null) {
        final imageRef = storref.ref()
            .child("Images/${id}.jpg");
        UploadTask uploadTask;
        if (kIsWeb) {
          final byte = await widget.pickfile.readAsBytes();
          uploadTask = imageRef.putData(byte);
        } else {
          uploadTask = imageRef.putFile(widget.file!);
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

  void _verifyPhone() async {
    setState(() {
      _isLoading = true;
    });

    await _auth.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        _signUp();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed. Please try again.')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  void _signInWithPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _codeController.text,
      );

      final User? user = (await _auth.signInWithCredential(credential)).user;

      if (user != null) {
        _signUp();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _signUp() async {

    try {
      UserCredential userCredential =await _auth.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      User? user = userCredential.user;
      id = user?.uid;
      await uploadImage(id!);
      SignUp signUp = SignUp(widget.name, widget.email, widget.phoneNumber, widget.password, url!,id!,widget.role);
      await dref.child(id!).set(signUp.tomap()).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up successful')),
        );
      }).onError((error, stackTrace) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error sigining up $error')),
        );
      });



      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The email address is already in use.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up failed. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verification',
          style: TextStyle(
            fontSize: height * 0.05,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu',
          ),
        ),
        centerTitle: true,
        toolbarHeight: height * 0.1,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width * 0.1),
          child: Column(
            children: [
              Text(
                'A verification code has been sent to ${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: height * 0.03),
              ),
              SizedBox(height: height * 0.02),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(labelText: "Verification Code"),
              ),
              SizedBox(height: height * 0.02),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: ()async{

                  _signInWithPhoneNumber();

                },
                child: Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
