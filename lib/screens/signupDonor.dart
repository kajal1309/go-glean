import 'package:flutter/material.dart';
import 'package:food_donating_app/screens/login.dart';
import 'package:food_donating_app/screens/loginpage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';

class SignupDonor extends StatefulWidget {
  const SignupDonor({Key? key}) : super(key: key);

  @override
  _SignupDonorState createState() => _SignupDonorState();
}

class _SignupDonorState extends State<SignupDonor> {
  final _formKey = GlobalKey<FormState>();
  var _email = "";
  var _password = "";
  String? _name = "";
  String? _address = "";
  String? _phoneNo = "";
  String? _city = "";
  String? _zipcode = "";
  String? _isParticipant = "";
  String _contactPerson = "";
  String _state = "Alabama";
  String _cuisine = "All";
  String _donorType = "Restaurant";
  String _userType = "donor";
  bool userexists = false;
  List<String> cuisine = [];
  List<String> donorType = [];
  TextEditingController _cityController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _phoneNoController = TextEditingController();
  TextEditingController _zipcodeController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _contactPersonController = TextEditingController();
  List<Location> locations = [];
  var lati = 0.0;
  var longi = 0.0;
  submitForm() async {
    final validity = _formKey.currentState?.validate();
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    FocusScope.of(context).unfocus();
    if (validity.toString().isNotEmpty) {
      _formKey.currentState?.save();
      try {
        UserCredential result = await auth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        final User user = result.user!;
        String uid = user.uid;
        //FirebaseAuth.instance.currentUser?.sendEmailVerification();
        await firestore.collection('donors').doc(uid).set({
          'Name': _name,
          'email': _email,
          'Contact Person': _contactPerson,
          'State': _state,
          'Phone Number': _phoneNo,
          'City': _city,
          "Zipcode": _zipcode,
          'Address': _address,
          'User Type': _userType,
          'Cuisine': _cuisine,
          'Donor Type': _donorType
        });
        await firestore.collection('users').doc(uid).set({
          'Name': _name,
          'email': _email,
          
          'Contact Person': _contactPerson,
          'State': _state,
          'Phone Number': _phoneNo,
          'City': _city,
          "Zipcode": _zipcode,
          'Address': _address,
          'User Type': _userType,
          'Cuisine': _cuisine,
          'Donor Type': _donorType
        });

        final snackBar = SnackBar(content: Text('You Are Registered!'));

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.of(context).pop();
      } catch (e) {
        // print('error' + e.toString());
      }
    } else {
      // print('else');
    }
  }

  Future<void> _getCuisines() async {
    FirebaseFirestore.instance
        .collection('utils')
        .doc('cuisines')
        .get()
        .then((value) {
      // print("hello");
      for (int i = 1; i <= value.data()!.length; i++) {
        cuisine.add(value.data()![i.toString()].toString());
        // print(cuisine[i]);
      }
      // print(cuisine);
    });
  }

  Future<void> _getDonorType() async {
    FirebaseFirestore.instance
        .collection('utils')
        .doc('Type of donors')
        .get()
        .then((value) {
      // print("hello");
      for (int i = 1; i <= value.data()!.length; i++) {
        donorType.add(value.data()![i.toString()].toString());
        // print(cuisine[i]);
      }
      // print(donorType);
    });
  }

  void initState() {
    super.initState();
    _getCuisines();
    _getDonorType();
  }

  @override
  void dispose() {
    super.dispose();
  }
  Future<bool> checkIfEmailInUse(String emailAddress) async {
  try {
    final list = await FirebaseAuth.instance.fetchSignInMethodsForEmail(emailAddress);
    print(list);
    if (list.isNotEmpty) {
      userexists = true;
      showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'User already exists'),
                                            content: const Text(
                                                'Account already exists with given email address. Please login using the credentials or try using forgot password if you have forgotten the password'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
      // Return true because there is an existing
      // user using the email address
      return true;
    } else {
      userexists = false;
      // Return false because email adress is not in use
      return false;
    }
  } catch (error) {
    // Handle error
    // ...
    return true;
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Sign Up Donor"),
      ),
      body: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        controller: _nameController,
                        keyboardType: TextInputType.emailAddress,
                        key: ValueKey('name'),
                        validator: (value) {
                          if (value == null) {
                            return "Cannot be empty";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _name = value;
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          border: UnderlineInputBorder(
                            //borderRadius: new BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          labelText: "Name",
                          labelStyle: GoogleFonts.roboto(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        key: ValueKey('email'),
                        validator: (value) {
                          if (value == null || !value.contains('@')) {
                            return "Incorrect email";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value.toString();
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          border: UnderlineInputBorder(
                            //borderRadius: new BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          labelText: "Enter Email",
                          labelStyle: GoogleFonts.roboto(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.emailAddress,
                        key: ValueKey('password'),
                        validator: (value) {
                          if (value == null || value.length < 8) {
                            return "password is too short";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value.toString();
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          border: UnderlineInputBorder(
                            //borderRadius: new BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          labelText: "Enter password",
                          labelStyle: GoogleFonts.roboto(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        controller: _contactPersonController,
                        keyboardType: TextInputType.emailAddress,
                        key: ValueKey('Contact Person'),
                        validator: (value) {
                          if (value == null) {
                            return "Incorrect name";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _contactPerson = value.toString();
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          border: UnderlineInputBorder(
                            //borderRadius: new BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          labelText: "Contact Person",
                          labelStyle: GoogleFonts.roboto(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        controller: _phoneNoController,
                        keyboardType: TextInputType.phone,
                        key: ValueKey('phoneNo'),
                        validator: (value) {
                          if (value == null) {
                            return "This field cannot be empty";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _phoneNo = value;
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          border: UnderlineInputBorder(
                            //borderRadius: new BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          labelText: "Phone number",
                          labelStyle: GoogleFonts.roboto(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      TextFormField(
                        cursorColor: Theme.of(context).primaryColor,
                        controller: _addressController,
                        keyboardType: TextInputType.emailAddress,
                        key: ValueKey('address'),
                        validator: (value) {
                          if (value == null) {
                            return "This cannot be empty";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _address = value;
                        },
                        decoration: InputDecoration(
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          border: UnderlineInputBorder(
                            //borderRadius: new BorderRadius.circular(8),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          labelText: "Address",
                          labelStyle: GoogleFonts.roboto(
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                      RaisedButton(
                          child: Text('Locate me',style: TextStyle(color: Colors.white),),
                          color: Theme.of(context).primaryColor,
                          onPressed: ()async{
                            locations = await locationFromAddress(_addressController.text);
                            lati = locations[0].latitude;
                            longi = locations[0].longitude;
                            print(locations);
                          }),
                      SizedBox(
                        height: 5,
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextFormField(
                              cursorColor: Theme.of(context).primaryColor,
                              controller: _zipcodeController,
                              keyboardType: TextInputType.emailAddress,
                              key: ValueKey('zipcode'),
                              validator: (value) {
                                if (value == null || value.length != 5) {
                                  return "Incorrect zipcode";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _zipcode = value;
                              },
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                border: UnderlineInputBorder(
                                  //borderRadius: new BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: new BorderRadius.circular(20),
                                ),
                                labelText: "zipcode",
                                labelStyle: GoogleFonts.roboto(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: TextFormField(
                              cursorColor: Theme.of(context).primaryColor,
                              controller: _cityController,
                              keyboardType: TextInputType.emailAddress,
                              key: ValueKey('city'),
                              validator: (value) {
                                if (value == null) {
                                  return "this cannot be empty";
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _city = value;
                              },
                              decoration: InputDecoration(
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor,
                                      width: 1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
                                ),
                                border: UnderlineInputBorder(
                                  //borderRadius: new BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: new BorderRadius.circular(20),
                                ),
                                labelText: "city",
                                labelStyle: GoogleFonts.roboto(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        // height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20.0)
                            //)
                            ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _state,
                              //why is hint not working?
                              hint: Container(
                                color: Colors.blue,
                                child: Text("Enter State"),
                              ),
                              icon: const Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              style: const TextStyle(color: Color(0xff022229)),
                              onChanged: (newValue) {
                                setState(() {
                                  _state = newValue.toString();
                                });
                              },
                              items: <String>[
                                'Alabama',
                                'Alaska',
                                'Arizona',
                                'Arkansas',
                                'California',
                                'Colorado',
                                'Connecticut',
                                'Delaware',
                                'Florida',
                                'Georgia',
                                'Hawaii',
                                'Idaho',
                                'IllinoisIndiana',
                                'Iowa',
                                'Kansas',
                                'Kentucky',
                                'Louisiana',
                                'Maine',
                                'Maryland'
                                    'Massachusetts',
                                'Michigan',
                                'Minnesota',
                                'Mississippi',
                                'Missouri',
                                'MontanaNebraska',
                                'Nevada',
                                'New Hampshire',
                                'New Jersey',
                                'New Mexico',
                                'New York',
                                'North Carolina',
                                'North Dakota',
                                'Ohio',
                                'Oklahoma',
                                'Oregon',
                                'PennsylvaniaRhode Island',
                                'South Carolina',
                                'South Dakota',
                                'Tennessee',
                                'Texas',
                                'Utah',
                                'Vermont',
                                'Virginia',
                                'Washington',
                                'West Virginia',
                                'Wisconsin',
                                'Wyoming'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.roboto(
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        // height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20.0)
                            //)
                            ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _cuisine,
                              hint: Container(
                                child: Text("Cuisine"),
                              ),
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              style: const TextStyle(color: Color(0xff022229)),
                              onChanged: (newValue) {
                                setState(() {
                                  _cuisine = newValue.toString();
                                });
                              },
                              items: cuisine.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.roboto(
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        // height: 50,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey),
                            borderRadius: BorderRadius.circular(20.0)
                            //)
                            ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _donorType,
                              hint: Container(
                                child: Text("Type of donor"),
                              ),
                              icon: Icon(Icons.arrow_drop_down),
                              iconSize: 24,
                              style: const TextStyle(color: Color(0xff022229)),
                              onChanged: (newValue) {
                                setState(() {
                                  _donorType = newValue.toString();
                                });
                              },
                              items: donorType.map<DropdownMenuItem<String>>(
                                  (String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.roboto(
                                      fontSize: 15,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      // TextFormField(
                      //   keyboardType: TextInputType.emailAddress,
                      //   key: ValueKey('isParticipant'),
                      //   validator: (value) {
                      //     return null;
                      //   },
                      //   onSaved: (value) {
                      //     _isParticipant = value;
                      //   },
                      //   decoration: InputDecoration(
                      //     focusedBorder: UnderlineInputBorder(
                      //       borderSide: BorderSide(
                      //           color: Theme.of(context).primaryColor,
                      //           width: 1),
                      //       borderRadius: BorderRadius.all(Radius.circular(20)),
                      //     ),
                      //     border: UnderlineInputBorder(
                      //       //borderRadius: new BorderRadius.circular(8),
                      //       borderSide: BorderSide(
                      //           color: Theme.of(context).primaryColor),
                      //       borderRadius: new BorderRadius.circular(20),
                      //     ),
                      //     labelText:
                      //         "are you a part of any other organization? if yes state below",
                      //     labelStyle: GoogleFonts.roboto(
                      //         color: Theme.of(context).primaryColor),
                      //   ),
                      // ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(
                            0,
                            MediaQuery.of(context).size.height * 0.01,
                            0,
                            MediaQuery.of(context).size.height * 0.01),
                        width: MediaQuery.of(context).size.width * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.0),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: TextButton(
                          onPressed: () async{
                            await checkIfEmailInUse(_emailController.text.trim());
                            if (_nameController.text == null) {
                              showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Invalid name'),
                                            content: const Text(
                                                'name empty'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                            }
                            else if (_emailController.text == null || !_emailController.text.contains('@')) {
                              showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Invalid email'),
                                            content: const Text(
                                                'Email entered is invalid or empty'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                            }
                            else if (_passwordController.text.length <8) {
                              showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Password too short'),
                                            content: const Text(
                                                'Password should have 8 or more characters'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                            }
                            else if (_contactPersonController.text == null) {
                              showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Invalid name'),
                                            content: const Text(
                                                'Contact person details empty'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                            }
                            else if (_phoneNoController.text == null) {
                              showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Invalid Phone number'),
                                            content: const Text(
                                                'Phone number empty'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                            }
                            else if (_addressController.text == null) {
                              showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Invalid address'),
                                            content: const Text(
                                                'Address empty'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                            }
                            else if (_zipcodeController.text.length != 5) {
                              showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Invalid zipcode'),
                                            content: const Text(
                                                'Zipcode should be 5 digits'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                            }
                            else if (_cityController.text == null) {
                              showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Invalid City name'),
                                            content: const Text(
                                                'City name empty'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                            }
                            else if(locations.isEmpty){
                              showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Invalid Address'),
                                            content: const Text(
                                                'Unable to fetch location coordinates from the given address please reenter the precise address'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                            }
                            
                            else{
                            setState(() {
                              FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text)
                                  .then((value) => FirebaseAuth
                                          .instance.currentUser
                                          ?.sendEmailVerification()
                                          .then((value) {
                                        FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(_emailController.text.trim())
                                            .set({
                                          'Address': _addressController.text,
                                          'City': _cityController.text,
                                          'Latitude' : lati,
                                          'Longitude' : longi,
                                          'Contact Person':
                                              _contactPersonController.text,
                                          'Cuisine': _cuisine,
                                          'Donor Type': _donorType,
                                          'Name': _nameController.text,
                                          'Phone Number':
                                              _phoneNoController.text,
                                          'State': _state,
                                          'User Type': 'donor',
                                          'Zipcode': _zipcodeController.text,
                                          'email': _emailController.text,
                                        });
                                        FirebaseFirestore.instance
                                            .collection('donors')
                                            .doc(_emailController.text.trim())
                                            .set({
                                          'Address': _addressController.text,
                                          'City': _cityController.text,
                                          'Contact Person':
                                              _contactPersonController.text,
                                          'Cuisine': _cuisine,
                                          'Donor Type': _donorType,
                                          'Name': _nameController.text,
                                          'Phone Number':
                                              _phoneNoController.text,
                                          'State': _state,
                                          'User Type': 'donor',
                                          'Zipcode': _zipcodeController.text,
                                          'email': _emailController.text,
                                        });
                                        _cityController.clear();
                                        _addressController.clear();
                                        _nameController.clear();
                                        _emailController.clear();
                                        _passwordController.clear();
                                        _addressController.clear();
                                        _phoneNoController.clear();
                                        _zipcodeController.clear();
                                        _contactPersonController.clear();
                                        showDialog<String>(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                            title: const Text(
                                                'Account Created successfully'),
                                            content: const Text(
                                                'Please verify your mail and login'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context, 'OK');
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }));
                            });
                          }
                          },
                          child: Text(
                            "Submit",
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => signinpage()));
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: GoogleFonts.roboto(color: Colors.black),
                              children: <TextSpan>[
                                TextSpan(
                                    text: 'Login!',
                                    style: GoogleFonts.roboto(
                                        color: Theme.of(context).primaryColor)),
                              ],
                            ),
                          )),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.65,
                        height: MediaQuery.of(context).size.height * 0.05,
                        //color: Colors.blue,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Thank you for your interest in fighting hunger and ending waste!",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.02,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}