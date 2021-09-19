import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhu_tubuh/viewmodel/base_model.dart';
import 'dart:async';

class UserModel extends BaseModel {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  CollectionReference pasien = FirebaseFirestore.instance.collection('pasien');

  String codes = '';

  Future<bool> createUser(
      String name, String noHp, String alamat, String umur) async {
    // String getRandomString(int length) =>
    //     String.fromCharCodes(Iterable.generate(
    //         length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    String kodeUser = DateFormat('hmss').format(DateTime.now()).toString();
    notifyListeners();
    setState(ViewState.Busy);
    var register = await pasien.add({
      "kodeuser": kodeUser,
      "name": name,
      "no_hp": noHp,
      "alamat": alamat,
      "umur": umur,
    });

    if (register is String) {
      notifyListeners();
      setState(ViewState.Idle);
      return false;
    } else {
      notifyListeners();
      setState(ViewState.Idle);
      codes = kodeUser;
      return true;
    }
  }

  Future<bool> loginUser(
      String email, String password, BuildContext context) async {
    setState(ViewState.Busy);
    notifyListeners();
    var select = await users
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .get();

    if (select.docs.length > 0) {
      notifyListeners();
      setState(ViewState.Idle);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userid', select.docs.first.id.toString());
      prefs.setBool('isLogin', true);
      prefs.setInt('isRole', select.docs.first['role']);
      prefs.setString('email', select.docs.first['email']);
      prefs.setString('password', select.docs.first['password']);
      prefs.setString('nama', select.docs.first['name']);
      return true;
    } else {
      notifyListeners();
      setState(ViewState.Idle);
      return false;
    }
  }
}
