import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Services {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  Future<bool> loginUser(
      String email, String password, BuildContext context) async {
    var select = await users
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    if (select.docs.length > 0) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userid', select.docs.first.id.toString());
      prefs.setBool('isLogin', true);
      prefs.setInt('isRole', select.docs.first['role']);
      prefs.setString('email', select.docs.first['email']);
      prefs.setString('password', select.docs.first['password']);
      prefs.setString('nama', select.docs.first['name']);
      return true;
    } else {
      return false;
    }
  }
}
