import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:suhu_tubuh/view/dashboard/graphic_pasien.dart';
import 'package:suhu_tubuh/viewmodel/base_model.dart';
import 'dart:async';

class DashBoardModel extends BaseModel {
  List<TimeSeriesSales> desktopSalesData = [];

  List<DocumentSnapshot> listPasien;
  List listSuhu = [];
  CollectionReference firePasien =
      FirebaseFirestore.instance.collection('pasien');

  CollectionReference fireSuhu =
      FirebaseFirestore.instance.collection('suhu_tubuh');

  Future getSuhuSearch(String kodeuser) async {
    setState(ViewState.Busy);
    var snapshot = await fireSuhu.where('kodeuser', isEqualTo: kodeuser).get();
    listSuhu = snapshot.docs;
    setState(ViewState.Idle);
    notifyListeners();
    return listSuhu;
  }

  Future getSuhu(String uid) async {
    setState(ViewState.Busy);
    var snapshot = await fireSuhu
        //.where('tanggal', isEqualTo: tgl)
        .where('pasienid', isEqualTo: uid)
        .get();
    listSuhu = snapshot.docs;
    setState(ViewState.Idle);
    notifyListeners();
    return listSuhu;
  }

  // ignore: missing_return
  Future<bool> suhuTubuh(
      String uid, String kodeuser, int suhu, String tgl, String jam) async {
    notifyListeners();
    setState(ViewState.Busy);
    print("tanggal $tgl $jam");
    var adding = await fireSuhu.add({
      "pasienid": uid,
      "kodeuser": kodeuser,
      "suhu": suhu,
      "tanggal": tgl + " " + jam,
      "jam": jam,
    });
    if (adding is String) {
      notifyListeners();
      setState(ViewState.Idle);
      return false;
    } else {
      notifyListeners();
      setState(ViewState.Idle);
      return true;
    }
  }

  Future<bool> createPasien(
      String name, String noHp, String alamat, String umur) async {
    notifyListeners();
    // const _chars = '1234567890';
    // Random _rnd = Random();
    // String getRandomString(int length) =>
    //     String.fromCharCodes(Iterable.generate(
    //         length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

    String kodeUser = DateFormat('hmss').format(DateTime.now()).toString();
    setState(ViewState.Busy);
    var register = await firePasien.add({
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
      return true;
    }
  }

  Future<dynamic> getPasien() async {
    setState(ViewState.Busy);
    var snapshot = await firePasien.get();
    listPasien = snapshot.docs;
    setState(ViewState.Idle);
    notifyListeners();
    return listPasien;
  }
}
