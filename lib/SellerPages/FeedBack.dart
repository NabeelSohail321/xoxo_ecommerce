import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../Authentication/Login.dart';
import '../models/Rating.dart';
import 'HomeScreen.dart';

class FeedBack extends StatefulWidget {
  String uid;

  FeedBack(this.uid);

  @override
  State<FeedBack> createState() => _FeedBackState();
}

class _FeedBackState extends State<FeedBack> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final dref = FirebaseDatabase.instance.ref("Products");
  bool _noDataFound = false;
  final rref = FirebaseDatabase.instance.ref('Ratings');

  Widget buildCircularProgressIndicator() {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
    );
  }

  Future<double> _getInitialRating(String pid) async {
    final snapshot = await rref.child(pid).get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      print("Fetched data: $data"); // Debug print

      double totalRatingLocal = double.parse(data['rating'] ?? '0');
      int numberOfUsersLocal = int.parse(data['users'] ?? '0');

      double calculatedRating = numberOfUsersLocal == 0 ? 0.0 : (totalRatingLocal / numberOfUsersLocal);

      print("Total Rating: $totalRatingLocal, Number of Users: $numberOfUsersLocal, Calculated Rating: $calculatedRating"); // Debug print

      return calculatedRating;
    } else {
      return 0.0;
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
          // Padding(
          //   padding: EdgeInsets.symmetric(vertical: height * 0.08, horizontal: height * 0.01),
          //   child: InkWell(
          //     onTap: () {
          //       _signOut(context);
          //     },
          //     child: Icon(Icons.logout, size: height * 0.06),
          //   ),
          // ),
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: Icon(Icons.logout),
                onTap: () {
                  _signOut(context);
                },
              ),
              PopupMenuItem(
                child: Icon(Icons.home),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return HomeScreen(widget.uid);
                  }));
                },
              )
            ];
          }, iconSize: height * 0.04),

        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Products",
                style: TextStyle(
                  fontSize: height * 0.03,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Ubuntu',
                ),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder(
              stream: dref.orderByChild('uid').equalTo(widget.uid).onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData && !_noDataFound) {
                  return Center(
                    child: buildCircularProgressIndicator(),
                  );
                } else if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                  Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
                  if (map == null) {
                    return Center(child: Text("No Product Found"));
                  }
                  List<dynamic>? list = [];
                  list.clear();
                  list = map.values.toList();

                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      String name = list![index]['name'].toString();
                      String description = list[index]['description'].toString();
                      String quantity = list[index]['quantity'].toString();
                      String img = list[index]['img'].toString();
                      String pid = list[index]['pid'].toString();

                      return FutureBuilder<double>(
                        future: _getInitialRating(pid),
                        builder: (context, AsyncSnapshot<double> ratingSnapshot) {
                          if (ratingSnapshot.connectionState == ConnectionState.waiting) {
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
                                          name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        leading: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(img),
                                        ),
                                        trailing: buildCircularProgressIndicator(),
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
                            );
                          } else if (ratingSnapshot.hasError) {
                            return Center(child: Text('Error: ${ratingSnapshot.error}'));
                          } else {
                            double rating = ratingSnapshot.data ?? 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
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
                                        trailing: Text('Ratings: ${rating.toStringAsFixed(1)}'),
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
                            );
                          }
                        },
                      );
                    },
                  );
                } else {
                  return Center(child: Text("No Product Found"));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
