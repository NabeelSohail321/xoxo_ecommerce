import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:xoxo_ecommerce/Authentication/Login.dart';
import 'Authentication/SignUp.dart';
import 'BuyerPages/HomeScreen.dart';
import 'RiderPages/Rider.dart';
import 'SellerPages/HomeScreen.dart';
import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthHandler(),
      ),
    );
  }
}

class AuthHandler extends StatefulWidget {
  const AuthHandler({super.key});

  @override
  State<AuthHandler> createState() => _AuthHandlerState();
}

class _AuthHandlerState extends State<AuthHandler> {
  late DatabaseReference _userRef;
  Widget _homePage = CircularProgressIndicator();

  @override
  void initState() {
    super.initState();
    _userRef = FirebaseDatabase.instance.ref().child('User');
    _checkAuthState();
  }


  void _checkAuthState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        setState(() => _homePage = Signup());
      } else {
        final role = await _getUserRole(user);
        setState(() {
          _homePage = _getHomePageForRole(role, user.uid);
        });
      }
    });
  }


  Future<String?> _getUserRole(User user) async {
    final snapshot = await _userRef.child(user.uid).child('role').get();
    return snapshot.value as String?;
  }



  Widget _getHomePageForRole(String? role, String Id) {
    switch (role) {
      case '1':
        return HomeScreen(Id);
      case '2':
        return Homescreenb(Id);
      case '3':
        return Rider();
      default:
        return Signup();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(child: _homePage)
    );
  }
}

