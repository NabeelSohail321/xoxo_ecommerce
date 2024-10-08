import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show ByteData, rootBundle;
import '../Authentication/Login.dart';
import 'HomeScreen.dart';

class Reports extends StatefulWidget {
  final String uid;

  Reports(this.uid);

  @override
  _ReportsState createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref("BuyerOrders");
  final DatabaseReference _productRef = FirebaseDatabase.instance.ref("Products");
  DateTime? _startDate;
  DateTime? _endDate;

  int totalNumber=0;
  double buyingprice=0;
  double sellingprice=0;

  double? profitloss;
  List<Map<dynamic, dynamic>> _filteredData = [];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    Future<double> _calculateTotal(List<dynamic> list) async {
      double total = 0;
      double buyingPrice1 = 0;
      double buyingPrice2 = 0;
      double sellingprice1=0;
      int totalproducts=0;

      for (var node in list) {
        String pid = node['pid'];

        await _productRef.child(pid).get().then((DataSnapshot snapshot) {
          if (snapshot.exists) {
            buyingPrice2 = double.parse(snapshot.child('buying').value.toString());
            buyingPrice1  += (double.parse(snapshot.child('buying').value.toString())*int.parse(node['number']));
          }
        });


        totalproducts += int.parse(node['number']);
        sellingprice1 += (double.parse(node['price'])*int.parse(node['number']));
        total += (double.parse(node['price']) - buyingPrice2) * int.parse(node['number']);
      }
      setState(() {
        totalNumber=totalproducts;

        buyingprice=buyingPrice1;
        sellingprice=sellingprice1;
      });
      return total;
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

    void _generatePDF () async{
      final Directory? directory;
      final ByteData fontData = await rootBundle.load('assets/fonts/Ubuntu-Medium.ttf');
      final ttf = pw.Font.ttf(fontData.buffer.asByteData());
      final image = pw.MemoryImage(
        (await rootBundle.load('assets/images/logo_text.png'))
            .buffer
            .asUint8List(),
      );


      try{
        final doc = pw.Document();
        doc.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {

            return pw.ListView(
              children: [
                pw.Container(
                    padding: pw.EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: pw.Column(
                      mainAxisAlignment: pw.MainAxisAlignment.start,
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Center(
                        child: pw.Image(
                          image,
                          width: 200,
                          fit: pw.BoxFit.contain,
                        ),
                      ),
                      pw.SizedBox(height: 20,),
                      pw.Center(child: pw.Text('Reports',style: pw.TextStyle(font: ttf,fontWeight: pw.FontWeight.bold,fontSize: 40))),
                      pw.SizedBox(height: 50,),
                      pw.Center(
                        child: pw.Row(
                          children: [
                            pw.Text('Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate!)}'),
                            pw.SizedBox(width: 30),
                            pw.Text('End Date: ${DateFormat('yyyy-MM-dd').format(_endDate!)}'),
                          ]
                        ),
                      ),
                      pw.SizedBox(height: 20,),
                      pw.Text('Total Number of Products: $totalNumber'),
                      pw.SizedBox(height: 20,),
                      pw.Text('Total Buying Price: $buyingprice'),
                      pw.SizedBox(height: 20,),
                      pw.Text('Total Selling Price: $sellingprice'),
                      pw.SizedBox(height: 50,),
                      pw.Text('Profit/Loss: $profitloss',style: pw.TextStyle(fontWeight: pw.FontWeight.bold,fontSize: 30)),

                    ]
                  )
                ),
              ],
            );
          }));

        if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        } else {
          directory = await getDownloadsDirectory();
        }

        if (directory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Directory not found')),
          );
          return;
        }
        String path = directory.path;
        String myFile =
            '${path}/xoxo-ecommmerce(Seller Report)-${DateFormat('yyyy-MM-dd').format(_startDate!)}-${DateFormat('yyyy-MM-dd').format(_endDate!)}.pdf';
        final file = File(myFile);
        await file.writeAsBytes(await doc.save());
        OpenFile.open(myFile);


      }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error $e')),
        );
        debugPrint("$e");

      }


    }

    if (_filteredData.isNotEmpty) {
      _calculateTotal(_filteredData).then((value) {
        setState(() {
          profitloss = value;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Reports',
          style: TextStyle(
            fontSize: height * 0.03,
            fontWeight: FontWeight.bold,
            fontFamily: 'Ubuntu',
          ),
        ),
        centerTitle: true,
        toolbarHeight: height * 0.1,
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(
                      'Start Date: ${_startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Not selected'}',
                      style: TextStyle(fontSize: height * 0.02),
                    ),
                    trailing: Icon(Icons.calendar_today, size: height * 0.03),
                    onTap: () async {
                      DateTime? pickedDate = await _selectDate(context, _startDate, DateTime.now());
                      if (pickedDate != null && (_endDate == null || pickedDate.isBefore(_endDate!))) {
                        setState(() {
                          _startDate = pickedDate;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Start date cannot be after end date')),
                        );
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      'End Date: ${_endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : 'Not selected'}',
                      style: TextStyle(fontSize: height * 0.02),
                    ),
                    trailing: Icon(Icons.calendar_today, size: height * 0.03),
                    onTap: () async {
                      DateTime? pickedDate = await _selectDate(context, _endDate, DateTime.now());
                      if (pickedDate != null && (_startDate == null || pickedDate.isAfter(_startDate!))) {
                        setState(() {
                          _endDate = pickedDate;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('End date cannot be before start date')),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                if (_startDate != null && _endDate != null) {
                  _filterData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please select both start and end dates')),
                  );
                }
              },
              child: Text('Filter Data'),
            ),
            if (profitloss != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Profit/Loss: $profitloss',
                  style: TextStyle(fontSize: height * 0.025, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 10,),
              _filteredData.isNotEmpty? ElevatedButton(onPressed: (){
                _generatePDF();
              }, child: Text('Generate Pdf')):Container(),


              Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: height * 0.3,
                child: _buildChart(),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredData.length,
                itemBuilder: (context, index) {
                  String name = _filteredData[index]['name'].toString();
                  String description = _filteredData[index]['description'].toString();
                  String sellingPrice = _filteredData[index]['price'].toString();
                  String img = _filteredData[index]['img'].toString();
                  String number = _filteredData[index]['number'].toString();
                  String status = _filteredData[index]['status'].toString().toLowerCase();
                  String date = _filteredData[index]['date'].toString();
                  double buying = double.parse(_filteredData[index]['buying'].toString());

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 6),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                          color: status == 'false' ? Colors.red : Colors.green, // Border color
                          width: 3.0, // Border width
                        ),
                      ),
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
                                  fontSize: height * 0.02,
                                ),
                              ),
                              leading: CircleAvatar(
                                radius: height * 0.04,
                                backgroundImage: NetworkImage(img),
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Date: $date',
                                      style: TextStyle(color: Colors.black, fontSize: height * 0.015),
                                    ),
                                    Text(
                                      'Quantity: $number',
                                      style: TextStyle(color: Colors.black, fontSize: height * 0.015),
                                    ),
                                  ],
                                ),
                              ),
                              subtitle: Text(
                                description,
                                style: TextStyle(color: Colors.black, fontSize: height * 0.017, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            Center(
                              child: (status == 'deliver')
                                  ? Text(
                                'Delivered',
                                style: TextStyle(
                                  fontSize: height * 0.017,
                                  color: status == 'false' ? Colors.red : Colors.green,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis, // Add ellipsis to handle overflow
                              )
                                  : Text('Pending', style: TextStyle(fontSize: height * 0.017)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate, DateTime? maxDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: maxDate ?? DateTime(2101),
    );
    return picked;
  }

  void _filterData() async {
    final startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
    final endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);

    _databaseRef.orderByChild("sid").equalTo(widget.uid).once().then((DatabaseEvent event) {
      Map<dynamic, dynamic> orders = event.snapshot.value as Map<dynamic, dynamic>;
      List<Map<dynamic, dynamic>> filteredOrders = [];

      orders.forEach((key, value) {
        String orderDateStr = value['date'].substring(0, value['date'].length - 4); // Remove the last 4 characters (time part)
        if (orderDateStr.compareTo(startDateStr) >= 0 && orderDateStr.compareTo(endDateStr) <= 0) {
          if (value['status'].toString().toLowerCase() == 'deliver') {
            filteredOrders.add(value);
          }
        }
      });

      setState(() {
        _filteredData = filteredOrders;
      });
    });
  }

  Widget _buildChart() {
    if (_filteredData.isEmpty) {
      return Container(); // Return empty container if there is no data
    }

    List<FlSpot> spots = [];
    List<String> dates = [];

    for (int i = 0; i < _filteredData.length; i++) {
      double x = i.toDouble();
      double y = (double.parse(_filteredData[i]['price']) - double.parse(_filteredData[i]['buying'])) * int.parse(_filteredData[i]['number']);
      spots.add(FlSpot(x, y));
      dates.add(_filteredData[i]['date'].substring(8, _filteredData[i]['date'].length - 8));
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: MediaQuery.of(context).size.height*0.3,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: const Color(0xffe7e8ec),
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: const Color(0xffe7e8ec),
                  strokeWidth: 1,
                );
              },
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: const Color(0xffe7e8ec), width: 1),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                barWidth: 2,
                color: Colors.blue,
                belowBarData: BarAreaData(show: false),
                dotData: FlDotData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 4.0,
                      child: Text(
                        value.toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
                axisNameWidget: Text(
                  'Profit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                axisNameSize: 20,
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < dates.length) {
                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 4.0,
                        child: Text(
                          dates[index],
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
                axisNameWidget: Text(
                  'Date',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                axisNameSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}