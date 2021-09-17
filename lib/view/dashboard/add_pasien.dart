import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:suhu_tubuh/base_view.dart';
import 'package:suhu_tubuh/viewmodel/base_model.dart';
import 'package:suhu_tubuh/viewmodel/dashboard_model.dart';

class TambahPasien extends StatefulWidget {
  @override
  _TambahPasienState createState() => _TambahPasienState();
}

class _TambahPasienState extends State<TambahPasien> {
  final _formKey = GlobalKey<FormState>();

  var nama = TextEditingController();
  var nohp = TextEditingController();
  var alamat = TextEditingController();
  var umur = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseView<DashBoardModel>(
      // onModelReady: (model) => model.getPasien(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text('Tambah Pasien'),
        ),
        body: model.state == ViewState.Busy ?? ViewState.Idle
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Container(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        myTextInput(nama, 'Nama Lengkap Pasien', false, 1),
                        myTextInput(nohp, 'Nomor HP', false, 1),
                        myTextInput(alamat, 'Alamat', false, 2),
                        myTextInput(umur, 'Umur', false, 1),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                            // ignore: deprecated_member_use
                            child: RaisedButton(
                              textColor: Colors.white,
                              color: Colors.blue,
                              child: Text('Tambah'),
                              onPressed: () async {
                                if (_formKey.currentState.validate()) {
                                  var createPasien = await model.createPasien(
                                      nama.text,
                                      nohp.text,
                                      alamat.text,
                                      umur.text);

                                  if (createPasien == true) {
                                    Fluttertoast.showToast(
                                        msg: "Tambah Pasien berhasil...",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                    Future.delayed(
                                      const Duration(seconds: 2),
                                      () {
                                        Navigator.pop(context);
                                      },
                                    );
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Tambah Pasien gagal.....",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                }
                              },
                            )),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget myTextInput(controller, String hint, bool secure, int lines) {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextFormField(
        maxLines: lines,
        controller: controller,
        obscureText: secure,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(),
          labelText: hint,
        ),
        validator: (value) {
          if (value.isEmpty) {
            return '$hint tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}
