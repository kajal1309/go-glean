import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:food_donating_app/screens/forgotpass.dart';
import 'package:food_donating_app/screens/home.dart';
import 'package:food_donating_app/screens/homeDonor.dart';
import 'package:food_donating_app/shared/loading.dart';
import 'package:google_fonts/google_fonts.dart';

class signinpage extends StatefulWidget {
  @override
  State<signinpage> createState() => _loginpageState();
}

class _loginpageState extends State<signinpage> {
  bool _isObscure = true;
  var _userType;
  // usertype(){
  //   FirebaseFirestore.instance
  //                 .collection('users')
  //                 .doc((FirebaseAuth.instance.currentUser)?.uid)
  //                 .get()
  //                 .then((value) {
  //               setState(() {
  //                 if (value.data()!['email'].toString() == FirebaseAuth.instance.currentUser?.email) {
  //                  _userType = value.data()!['User Type'].toString();
  //                  }
  //               });
  //             });
  //             print(_userType);
  //       // Timer(Duration(seconds: 1), () {
  //       // if (_userType == "volunteer") {
  //       //    Navigator.push(context,
  //       //         MaterialPageRoute(builder: (context) => Home()));
  //       // } else {
  //       //    Navigator.push(context,
  //       //         MaterialPageRoute(builder: (context) => HomeDonor()));
  //       // }});
  // }
  final usernamecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Authentication',
          style: GoogleFonts.roboto(
              color: Theme.of(context).scaffoldBackgroundColor),
        ),
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: ListView(
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.roboto(
                          color: Theme.of(context).primaryColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w500),
                    )),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    cursorColor: Theme.of(context).primaryColor,
                    style: GoogleFonts.roboto(color: Colors.black),
                    controller: usernamecontroller,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: GoogleFonts.roboto(color: Colors.black),
                      hintText: 'Email ID',
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    cursorColor: Theme.of(context).primaryColor,
                    obscureText: _isObscure,
                    style: GoogleFonts.roboto(color: Colors.black),
                    controller: passwordcontroller,
                    keyboardType: TextInputType.streetAddress,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor, width: 1),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      hintStyle: GoogleFonts.roboto(color: Colors.black),
                      hintText: 'Enter Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off,
                          color: Theme.of(context).primaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => forgotpassword(),
                        ));
                    },
                    child: Text('Forgot Password',
                        style: GoogleFonts.roboto(
                            color: Theme.of(context).primaryColor,
                            fontSize: 15))),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Container(
                    height: 50,
                    width: 20,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextButton(
                        onPressed: () async{
                          // print(usernamecontroller.text.runtimeType);
                          // print(usernamecontroller.text.toString().runtimeType);
                          FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: usernamecontroller.text.trim(),
                                  password: passwordcontroller.text)
                              .then((value) async {
                            if (FirebaseAuth
                                    .instance.currentUser?.emailVerified ==
                                true) {
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(usernamecontroller.text.trim())
                                  .get()
                                  .then((value) {
                                    buildShowDialog(context);
                                Timer(
                                Duration(seconds: 2),
                                    () {
                                if (value.data()!['User Type'].toString() ==
                                    "volunteer") {
                                  usernamecontroller.clear();
                                  passwordcontroller.clear();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  // Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Home()));
                                  // Navigator.pop(context);
                                } else {
                                  usernamecontroller.clear();
                                  passwordcontroller.clear();
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  // Navigator.pop(context);
                                  // Navigator.pop(context);
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeDonor()));
                                  // Navigator.pop(context);
                                  }});
                              });
                            }
                            else if (usernamecontroller.text.contains('@')) {
                              Fluttertoast.showToast( msg: 'Enter a valid email address',
                                  gravity: ToastGravity.BOTTOM,
                                  fontSize: 18,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  textColor: Colors.white);
                            }
                             else {
                              return Fluttertoast.showToast(
                                  msg: 'User not verified',
                                  gravity: ToastGravity.BOTTOM,
                                  fontSize: 18,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  textColor: Colors.white);
                            }
                          }).catchError((error) {
                            var errormsg = error.message;
                            print(errormsg.toString());
                            if (errormsg.toString() == "Given String is empty or null") {
                              showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  content: 
                                  Text(
                                      "Please enter valid email and password"),
                                  actions: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "OK",
                                                  style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                )),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ));
                            } 
                            else if (errormsg.toString() == 'The email address is badly formatted.') {
                              showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  content: 
                                  Text(
                                      "Please enter a valid email"),
                                  actions: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "OK",
                                                  style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                )),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ));
                            }
                            else if (errormsg.toString() == 'There is no user record corresponding to this identifier. The user may have been deleted.') {
                              showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  content: 
                                  Text(
                                      "Sorry, we can't find an account with this email address and password. Please try again or create a new account."),
                                  actions: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "OK",
                                                  style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                )),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ));
                            }
                            else if(errormsg.toString() == "The password is invalid or the user does not have a password."){
                              showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  content: 
                                  Text(
                                      "Wrong Password"),
                                  actions: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "OK",
                                                  style: GoogleFonts.roboto(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                )),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ));
                            }
                          });
                          
                        },
                        child: Text(
                          'Sign in',
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                          ),
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
buildShowDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }