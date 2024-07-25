import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:xoxo_ecommerce/Authentication/Login.dart';
import 'package:xoxo_ecommerce/models/signup.dart';
import 'dart:io';

class Verification extends StatefulWidget {
  final String phoneNumber;
  final String name;
  final String email;
  final String password;
  final String role;
  File? file;
  dynamic pickfile;

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
  bool _isLoading = false;
  final dref = FirebaseDatabase.instance.ref("User");
  final storref = FirebaseStorage.instance;
  String? url;
  User? _user;

  @override
  void initState() {
    super.initState();
    _createUser();
  }

  Future<void> uploadImage(String id) async {
    try {
      if (widget.file != null || widget.pickfile != null) {
        final imageRef = storref.ref().child("Images/${id}.jpg");
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

  Future<void> _createUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );
      _user = userCredential.user;

      if (_user != null) {
        await _user!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent to ${widget.email}')),
        );
        setState(() {
          _isLoading = false;
        });

        // Show the verification check button
        _showVerificationCheckButton();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showVerificationCheckButton() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Verify Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Please check your email for verification.'),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _checkEmailVerification,
                child: Text('Check Verification'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _checkEmailVerification() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_user == null) throw Exception("No user found.");

      // Reload the user data
      await _user!.reload();
      _user = _auth.currentUser; // Refresh user

      if (_user != null && _user!.emailVerified) {
        await _signUp();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please verify your email first.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signUp() async {
    try {
      if (_user != null) {
        await uploadImage(_user!.uid);
        SignUp signUp = SignUp(
          widget.name,
          widget.email,
          widget.phoneNumber,
          widget.password,
          url!,
          _user!.uid,
          widget.role,
        );
        await dref.child(_user!.uid).set(signUp.tomap()).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign up successful')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Login()),
          );
        }).onError((error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing up: $error')),
          );
        });
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
                'A verification email has been sent to ${widget.email}. Please check your inbox.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: height * 0.03),
              ),
              SizedBox(height: height * 0.02),
              if (_isLoading)
                CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _showVerificationCheckButton,
                  child: Text('Check Email Verification'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
