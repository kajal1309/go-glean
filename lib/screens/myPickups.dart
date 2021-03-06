import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_donating_app/screens/startJourney.dart';
import 'package:food_donating_app/shared/loading.dart';
import 'package:food_donating_app/shared/no_pickups.dart';
import 'package:food_donating_app/widget/charity.dart';
import 'package:food_donating_app/widget/internet_service.dart';
import 'package:food_donating_app/widget/noInternetScreen.dart';
import 'package:food_donating_app/widget/restaurent_map.dart';
import 'package:food_donating_app/widget/timecheck.dart';

class MyPickups extends StatefulWidget {
  const MyPickups({Key? key}) : super(key: key);

  @override
  _MyPickupsState createState() => _MyPickupsState();
}

class _MyPickupsState extends State<MyPickups> {
  bool _pressAttention = true, _dataLoaded = false, _pickUpAvailable = false;
  List pickUpList = [];
  List pickUpCharityList = [];
  DateTime now = DateTime.now();
  void getPickUps(bool _pressAttention) async {
    bool connected = await InternetService().checkInternetConnection();
    if (!connected) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoInternetScreen(),
        ),
      );
      return;
    }

    pickUpList = [];
    CollectionReference pickupCollection =
        FirebaseFirestore.instance.collection('pickup_details');

    if (_pressAttention) {
      pickupCollection =
          FirebaseFirestore.instance.collection('pickup_details');
    } else {
      pickupCollection = FirebaseFirestore.instance.collection('old_pickups');
    }

    CollectionReference charityCollection =
        FirebaseFirestore.instance.collection('charity');

    String? curUserEmail = FirebaseAuth.instance.currentUser!.email;

    QuerySnapshot pickUpSnapshot = await pickupCollection.get();

    List? pList = [];
    List pList2 =
        pickUpSnapshot.docs.map((DocumentSnapshot s) => s.data()).toList();

    for (var i = 0; i < pList2.length; i++) {
      // print('\n\n\n');
      if (pList2[i]['Pickedby'] == curUserEmail) {
        bool check = false;

        for (var j = 0; j < pList.length; j++) {
          if (pList[j]['Restaurant Name'] == pList2[i]['Restaurant Name']) {
            check = true;
            for (var k = 0; k < pList2[i]['descriptionlist'].length; k++) {
              pList[j]['descriptionlist'].add(pList2[i]['descriptionlist'][k]);
              pList[j]['quantitylist'].add(pList2[i]['quantitylist'][k]);
              pList[j]['unitlist'].add(pList2[i]['unitlist'][k]);
            }
          }
        }

        if (check) continue;
        // print(pList2[i]['PickedCharityUniId']);

        DocumentSnapshot snapshot =
            await charityCollection.doc(pList2[i]['PickedCharityUniId']).get();
        // print(pList2[i]['PickedCharityUniId']);
        var data = snapshot.data() as Map;
        pickUpCharityList.add(data);
        pList.add(pList2[i]);
      }
    }

    // print('\n\n\n');
    // print(pickUpList.length);
    // print('\n\n\n');
    for (var i = 0; i < pList.length; i++) {
      List stDate = pList[i]['startdate'].split('-');
      DateTime sDate = DateTime.utc(
          int.parse(stDate[0]), int.parse(stDate[1]), int.parse(stDate[2]));
      if (sDate.compareTo(now) <= 0) {
        pList[i]['frstartdate'] = "Today";
      } else {
        pList[i]['frstartdate'] = pList[i]['startdate'];
      }
      // print(pList[i]['']);
      // print('\n\n');
    }

    if (!_dataLoaded)
      setState(() {
        pickUpList = pList;
        _dataLoaded = true;
        if (pickUpList.length != 0)
          _pickUpAvailable = true;
        else
          _pickUpAvailable = false;
      });
  }

  void checkDate(String date) {}

  @override
  void initState() {
    super.initState();
    getPickUps(_pressAttention);

    // print(FirebaseAuth.instance.currentUser!.email);
    // print('\n\n\n\n');
  }

  @override
  Widget build(BuildContext context) {
    void openUnclaimConfirmation(int index) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Column(
            children: [
              Text(
                "We're sorry to see you unclaim your pickup",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ButtonTheme(
                minWidth: 36,
                child: RaisedButton(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  textColor: Colors.white,
                  color: Theme.of(context).primaryColor,
                  child: Text(
                    'CONFIRM',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(28.0),
                  ),
                  onPressed: () async {
                    // print('object');
                    final CollectionReference pCollection =
                        FirebaseFirestore.instance.collection('pickup_details');

                    QuerySnapshot snapshot = await pCollection.get();
                    snapshot.docs.forEach((element) {
                      Map dataMap = element.data() as Map;
                      if (dataMap['Pickedby'] ==
                              FirebaseAuth.instance.currentUser!.email &&
                          pickUpList[index]['PickedCharityUniId'] ==
                              dataMap['PickedCharityUniId'] &&
                          pickUpList[index]['Restaurant Name'] ==
                              dataMap['Restaurant Name']) {
                        // print(element.id);
                        pCollection.doc(element.id).update({
                          'Pickedby': '',
                          'Status': 'upcoming',
                          'PickedCharityUniId': '',
                        });
                      }
                    });

                    _dataLoaded = false;
                    _pickUpAvailable = false;
                    Navigator.pop(context);
                    getPickUps(_pressAttention);
                  },
                ),
              ),
              FlatButton(
                child: Text('CANCEL'),
                color: Colors.transparent,
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
        ),
      );
    }

    // print(pickUpList.length);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("My Pickups"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
          Row(
            children: [
              SizedBox(width: MediaQuery.of(context).size.width * 0.1),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  // color: Colors.orange,
                  color: _pressAttention
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).scaffoldBackgroundColor,
                  onPressed: () {
                    setState(() {
                      _pressAttention = true;
                      _dataLoaded = false;
                    });
                    getPickUps(_pressAttention);
                    // print('upcoming');
                  },
                  child: Text(
                    'Upcoming',
                    style: TextStyle(
                      color: !_pressAttention
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                    side: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  // color: Colors.orange,
                  color: !_pressAttention
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).scaffoldBackgroundColor,
                  onPressed: () {
                    setState(() {
                      _pressAttention = false;
                      _dataLoaded = false;
                    });
                    // print('history');
                    // print(_pressAttention);
                    getPickUps(_pressAttention);
                  },
                  child: Text(
                    'History',
                    style: TextStyle(
                      color: !_pressAttention
                          ? Theme.of(context).scaffoldBackgroundColor
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.width * 0.05),
          _dataLoaded
              ? _pickUpAvailable
                  // ? Text('data')
                  ? Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: pickUpList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                child: Card(
                                  clipBehavior: Clip.antiAlias,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${pickUpList[index]['frstartdate']} to ${pickUpList[index]['enddate']}",
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                decoration:
                                                    TextDecoration.underline,
                                                color: Colors.black,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'PickUp available between ${pickUpList[index]['starttime']} and ${pickUpList[index]['endtime']}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Text(
                                              'Drop off available between ${pickUpCharityList[index]['OpenCloseTime'][(now.weekday - 1) * 2]} and ${pickUpCharityList[index]['OpenCloseTime'][(now.weekday - 1) * 2 + 1]}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  'Pickup from',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  pickUpList[index]
                                                      ['Restaurant Name'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  'Drop off to',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  pickUpCharityList[index]
                                                      ['name'],
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black54,
                                                  ),
                                                )
                                              ],
                                            ),
                                            SizedBox(height: 8),
                                          ],
                                        ),
                                        if (_pressAttention)
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ButtonTheme(
                                                    minWidth: 36,
                                                    child: RaisedButton(
                                                      textColor: Colors.white,
                                                      color: Color.fromRGBO(
                                                          118, 210, 83, 1),
                                                      child: Text(
                                                        'START',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      shape:
                                                          new RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      onPressed: () async {
                                                        bool connected =
                                                            await InternetService()
                                                                .checkInternetConnection();
                                                        if (!connected) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  NoInternetScreen(),
                                                            ),
                                                          );
                                                          return;
                                                        }

                                                        if (!TimeCheck()
                                                            .getResOpenStatus(
                                                                pickUpList[
                                                                        index][
                                                                    'startdate'],
                                                                pickUpList[
                                                                        index][
                                                                    'starttime'],
                                                                pickUpList[
                                                                        index]
                                                                    ['enddate'],
                                                                pickUpList[
                                                                        index][
                                                                    'endtime'])) {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Restaurant is closed now",
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                              timeInSecForIosWeb:
                                                                  1,
                                                              backgroundColor:
                                                                  Colors
                                                                      .black45,
                                                              fontSize: 16.0);
                                                          return;
                                                        }
                                                        print(
                                                            pickUpList[index]);

                                                        if (!TimeCheck()
                                                            .getCharOpenStatus(
                                                                Charity(
                                                          name: '',
                                                          posLat: '',
                                                          posLng: '',
                                                          uniId: '',
                                                          // openTime: doc['openTime'] ?? '',
                                                          // closeTime: doc['closeTime'] ?? '',
                                                          donationType: [],
                                                          phoneNumber:
                                                              '1234567890',
                                                          openCloseTime:
                                                              pickUpCharityList[
                                                                      index][
                                                                  'OpenCloseTime'],
                                                        ))) {
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Charity is closed now",
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                              timeInSecForIosWeb:
                                                                  1,
                                                              backgroundColor:
                                                                  Colors
                                                                      .black45,
                                                              fontSize: 16.0);
                                                          return;
                                                        }

                                                        print(
                                                            pickUpList[index]);

                                                        // print(FirebaseAuth.instance.currentUser!.uid);
                                                        // Navigator.pop(context);
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                StartJourney(
                                                              curChar:
                                                                  pickUpCharityList[
                                                                      index],
                                                              curRes:
                                                                  pickUpList[
                                                                      index],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ButtonTheme(
                                                    minWidth: 36,
                                                    child: RaisedButton(
                                                      textColor: Colors.white,
                                                      color: Color.fromRGBO(
                                                          248, 95, 99, 1),
                                                      child: Text(
                                                        'UNCLAIM',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      shape:
                                                          new RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                .circular(10.0),
                                                      ),
                                                      onPressed: () {
                                                        openUnclaimConfirmation(
                                                            index);
                                                        // print(FirebaseAuth.instance.currentUser!.uid);
                                                        // Navigator.pop(context);
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16)
                            ],
                          );
                        },
                      ),
                    )
                  : NoPickUpsAvailable()
              : Loading()
        ],
      ),
    );
  }
}
