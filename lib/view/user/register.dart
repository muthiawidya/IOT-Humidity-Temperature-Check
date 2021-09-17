import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:suhu_tubuh/viewmodel/base_model.dart';
import 'package:suhu_tubuh/viewmodel/user_model.dart';
import 'dart:async';
import '../../base_view.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // var email = TextEditingController();
  var nama = TextEditingController();
  var nohp = TextEditingController();
  var alamat = TextEditingController();
  var umur = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseView<UserModel>(
      // onModelReady: (model) => model.getPosts(Provider.of<User>(context).id),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        body: model.state == ViewState.Busy ?? ViewState.Idle
            ? Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(10),
                              child: Text(
                                'Register Pasien',
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 30),
                              ),
                            ),
                            // myTextInput(email, 'Email Address', false, 1),
                            myTextInput(nama, 'Nama Lengkap', false, 1),
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
                                  child: Text('Register'),
                                  onPressed: () async {
                                    if (_formKey.currentState.validate()) {
                                      var registers = await model.createUser(
                                          nama.text,
                                          nohp.text,
                                          alamat.text,
                                          umur.text);

                                      if (registers == true) {
                                        Fluttertoast.showToast(
                                            msg: "Register berhasil...",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        Future.delayed(
                                          const Duration(seconds: 2),
                                          () {
                                            // Navigator.pop(context);
                                          },
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                            msg: "Register gagal.....",
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
                            Container(
                              child: Row(
                                children: <Widget>[
                                  Text('Do you have account?'),
                                  // ignore: deprecated_member_use
                                  FlatButton(
                                    textColor: Colors.blue,
                                    child: Text(
                                      'Login',
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  )
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                              ),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height / 4,
                              margin: const EdgeInsets.all(15.0),
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.blueAccent),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Kode anda akan di dapatkan apabila berhasil Register, Simpan Kode anda.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: Colors.deepOrange,
                                          fontSize: 16),
                                    ),
                                    SizedBox(height: 16),
                                    model.codes == ""
                                        ? SizedBox()
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Text(
                                                model.codes,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              IconButton(
                                                  onPressed: () async {
                                                    await Clipboard.setData(
                                                        new ClipboardData(
                                                            text: model.codes));
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Kode berhasil di copy",
                                                        toastLength:
                                                            Toast.LENGTH_LONG,
                                                        gravity:
                                                            ToastGravity.CENTER,
                                                        timeInSecForIosWeb: 1,
                                                        backgroundColor:
                                                            Colors.green,
                                                        textColor: Colors.white,
                                                        fontSize: 16.0);
                                                  },
                                                  icon: Icon(Icons.copy))
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
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
