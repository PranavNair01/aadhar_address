import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class userLogin extends StatefulWidget {
  const userLogin();

  @override
  _userLoginState createState() => _userLoginState();
}

String userRefId;

class _userLoginState extends State<userLogin> {
  @override
  String user_aadhar;
  Future<int> checkIfDocExists(String docId) async {
    try {
      var collectionRef = FirebaseFirestore.instance.collection('ongoing');
      var doc = await collectionRef.doc(docId).get();
      if (doc.exists) {
        int step = doc.get('step');
        return step;
      } else
        return 0;
    } catch (e) {
      throw e;
    }
  }

  void generateRefID() {
    var bytes = utf8.encode(user_aadhar);
    var digest = sha1.convert(bytes);
    userRefId = digest.toString();
    userRefId = userRefId.substring(0, 10);
    user_aadhar = null;
    print("User Ref ID: $userRefId");
  }

  void addUser(String id) {
    var db = FirebaseFirestore.instance;
    DateTime curr = DateTime.now();
    db.collection("ongoing").doc(id).set({
      "step": 1,
      "tramsactionID": id,
      "timestamp": curr,
    });
  }

  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
        body: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                width: MediaQuery.of(context).size.width / 1.3,
                height: MediaQuery.of(context).size.height / 13.6,
                child: TextField(
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                  onChanged: (value) {
                    if (value.isEmpty)
                      return null;
                    else {
                      user_aadhar = value;
                      print(user_aadhar);
                    }
                  },
                  decoration: InputDecoration(
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20),
                    labelText: "Enter User Aadhar Number",
                  ),
                ),
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFF143B40),
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                alignment: FractionalOffset.center,
                width: MediaQuery.of(context).size.width / 4,
                height: 40,
                child: FlatButton(
                  onPressed: () async {
                    if (user_aadhar != null && user_aadhar.length == 12) {
                      generateRefID();
                    }
                    int step = await checkIfDocExists(userRefId);
                    if (step == 0) {
                      addUser(userRefId);
                    }
                    Navigator.pushNamed(context, 'userotp', arguments: step);
                  },
                  child: Text(
                    "Get OTP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//TODO: Improve UI
//Error for wrong input format less than 12 digits 
//Auth API integration