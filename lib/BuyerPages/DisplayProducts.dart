import 'package:animated_rating_stars/animated_rating_stars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:xoxo_ecommerce/BuyerPages/Cart.dart';
import 'package:xoxo_ecommerce/BuyerPages/HomeScreen.dart';
import 'package:xoxo_ecommerce/BuyerPages/ViewProduct.dart';
import 'package:xoxo_ecommerce/models/Rating.dart';
import '../Authentication/Login.dart';

class Display extends StatefulWidget {
  final String uid;

  Display(this.uid);

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final dref = FirebaseDatabase.instance.ref("Products");
  final rref = FirebaseDatabase.instance.ref('Ratings');

  String? pid;
  String category='clothe';
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
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: Icon(Icons.logout),
                onTap: () {
                  _signOut(context);
                },
              ),
              PopupMenuItem(
                child: Icon(Icons.shopping_cart),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return cart(widget.uid);
                  }));
                },
              ),
              PopupMenuItem(
                child: Icon(Icons.home),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Homescreenb(widget.uid);
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
          SizedBox(height: 20,),
          Container(
            width: MediaQuery.of(context).size.width*0.5,
            child: PopupMenuButton<String>(
              initialValue: category, // Set initial value here
              onSelected: (String value) {
                setState(() {
                  category = value;
                });
              },
              itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'clothe',
                  child: Text('Clothes'),
                ),
                const PopupMenuItem<String>(
                  value: 'electronics',
                  child: Text('Electronics'),
                ),
                const PopupMenuItem<String>(
                  value: 'appliances',
                  child: Text('Appliances'),
                ),
              ],
              child: ListTile(
                title: Text('Category'),
                trailing: Text(
                  category == 'clothe'
                      ? 'Clothes'
                      : category == 'electronics'
                      ? 'Electronics'
                      : 'Applpiances',
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),
          Expanded(
            child: StreamBuilder(
              stream: dref.onValue,
              builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                      backgroundColor: Colors.grey[200],
                      strokeWidth: 4.0,
                    ),
                  );
                } else if (snapshot.data?.snapshot.value == null) {
                  return Center(
                    child: Text("No products found"),
                  );
                } else {
                  Map<dynamic, dynamic> map = snapshot.data!.snapshot.value as dynamic;
                  List<dynamic>? list = [];
                  list.clear();
                  list = map.values.toList();
                  List<dynamic> list1 = list.where((element) => element['category'].toString().toLowerCase() == category.toLowerCase()).toList();


                  return GridView.extent(
                    maxCrossAxisExtent: 500,
                    children: List.generate(list1.length, (index) {
                      pid = list1![index]['pid'];
                      return DashboardCard(
                        title: list1[index]['name'],
                        img: list1[index]['img'],
                        description: list1[index]['description'],
                        uid: widget.uid,
                        pid: pid!,
                      );
                    }),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardCard extends StatefulWidget {
  final String title;
  final String img;
  final String description;
  final String uid, pid;

  DashboardCard({
    required this.title,
    required this.img,
    required this.description,
    required this.uid,
    required this.pid,
  });

  @override
  _DashboardCardState createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  final rref = FirebaseDatabase.instance.ref('Ratings');
  double rating = 0;
  double totalRating = 0;
  int numberOfUsers = 0;
  bool hasRated = false;

  @override
  void initState() {
    super.initState();
    _getInitialRating();
  }

  Future<void> _getInitialRating() async {
    final snapshot = await rref.child(widget.pid).get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      print("Fetched data: $data"); // Debug print
      setState(() {
        totalRating = double.parse(data['rating'] ?? '3.5');
        numberOfUsers = int.parse(data['users'] ?? '1');
        rating = numberOfUsers == 0 ? 0 : (totalRating / numberOfUsers);
        hasRated = data['ratedBy']?.containsKey(widget.uid) ?? false;
        print("Total Rating: $totalRating, Number of Users: $numberOfUsers, Calculated Rating: $rating, Has Rated: $hasRated"); // Debug print
      });
    } else {
      // Rating rating1 = Rating(widget.pid, '3.5', '1');
      // await rref.child(widget.pid).set(rating1.tomap());
      setState(() {
        rating = 3.5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return viewProduct(widget.uid, widget.pid);
        }, maintainState: true));
      },
      child: Card(
        color: Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: BorderSide(
            color: Colors.orangeAccent, // Border color
            width: 4.0, // Border width
          ),
        ),
        margin: EdgeInsets.all(10.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(widget.img),
                ),
                SizedBox(height: 10.0),
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 28.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  widget.description,
                  style: TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
                ),
                if (rating != 0) ...[
                  AnimatedRatingStars(
                    initialRating: rating,
                    minRating: 0.0,
                    maxRating: 5.0,
                    filledColor: Colors.amber,
                    emptyColor: Colors.grey,
                    filledIcon: Icons.star,
                    halfFilledIcon: Icons.star_half,
                    emptyIcon: Icons.star_border,
                    onChanged: hasRated
                        ? (double newRating) {}
                        : (double newRating) {
                      print(newRating);
                      // _getInitialRating();
                      _handleRatingChange(newRating);
                    },
                    displayRatingValue: true,
                    interactiveTooltips: true,
                    customFilledIcon: Icons.star,
                    customHalfFilledIcon: Icons.star_half,
                    customEmptyIcon: Icons.star_border,
                    starSize: 30.0,
                    animationDuration: Duration(milliseconds: 300),
                    animationCurve: Curves.easeInOut,
                    readOnly: hasRated,
                  ),
                ] else ...[
                  CircularProgressIndicator(),
                ],
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleRatingChange(double newRating) {
    setState(() {
      hasRated = true;
      rating = newRating;
    });
    _updateRating(newRating);
  }

  Future<void> _updateRating(double newRating) async {
    final snapshot = await rref.child(widget.pid).get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      double users = double.parse(data['users']);
      double rating1 = double.parse(data['rating']);

      double newTotalRating = rating1 + newRating;
      double newNumberOfUsers = users + 1;

      await rref.child(widget.pid).update({
        'users': newNumberOfUsers.toString(),
        'rating': newTotalRating.toString(),
        'ratedBy/${widget.uid}': true, // Add user to ratedBy list
      });

      setState(() {
        totalRating = newTotalRating;
        numberOfUsers = newNumberOfUsers.toInt();
        rating = totalRating / numberOfUsers;
      });
    }
  }
}
