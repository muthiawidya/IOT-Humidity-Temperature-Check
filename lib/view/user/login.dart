import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhu_tubuh/base_view.dart';
import 'package:suhu_tubuh/view/dashboard/dashboard.dart';
import 'package:suhu_tubuh/view/dashboard/graphic_search.dart';
import 'package:suhu_tubuh/view/user/register.dart';
import 'package:suhu_tubuh/viewmodel/base_model.dart';
import 'package:suhu_tubuh/viewmodel/user_model.dart';
import 'dart:async';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  var email = TextEditingController();
  var password = TextEditingController();

  var kodeusers = TextEditingController();
  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Lihat Graphic'),
            content: Container(
              height: MediaQuery.of(context).size.height / 7.6,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {},
                    controller: kodeusers,
                    decoration:
                        InputDecoration(hintText: "Masukan kode Pasien"),
                  ),
                  SizedBox(height: 10),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      onPressed: () {
                        if (kodeusers.text.length <= 6 || kodeusers == null) {
                          Fluttertoast.showToast(
                              msg: "Kode pasien tidak valid",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        } else {
                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: GraphicSearch(kodeuser: kodeusers.text),
                                inheritTheme: true,
                                ctx: context),
                          );
                        }
                      },
                      child: Text("Cari"),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

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
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          ListView(
                            shrinkWrap: true,
                            children: <Widget>[
                              Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Login User',
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 30),
                                  )),
                              myTextInput(email, 'Email Address', false),
                              myTextInput(password, 'Password', true),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 50,
                                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                                // ignore: deprecated_member_use
                                child: RaisedButton(
                                  textColor: Colors.white,
                                  color: Colors.blue,
                                  child: Text('Login'),
                                  onPressed: () async {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();

                                    if (_formKey.currentState.validate()) {
                                      var logins = await model.loginUser(
                                          email.text, password.text, context);

                                      if (logins == true) {
                                        Fluttertoast.showToast(
                                            msg: "Login berhasil...",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.green,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                        Future.delayed(
                                          const Duration(seconds: 2),
                                          () {
                                            if (prefs.getInt('isRole') == 2) {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          HomeScreen(
                                                              prefs.getString(
                                                                  'userid'),
                                                              prefs.getString(
                                                                  'nama'))));
                                            } else {
                                              // Navigator.pushReplacement(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) => AdminPage(
                                              //             prefs.getString('userid'),
                                              //             prefs.getString('nama'))));
                                            }
                                          },
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                            msg:
                                                "Login gagal, Email atau password salah",
                                            toastLength: Toast.LENGTH_LONG,
                                            gravity: ToastGravity.CENTER,
                                            timeInSecForIosWeb: 1,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                            fontSize: 16.0);
                                      }
                                    }
                                  },
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Text('Does not have account?'),
                                    // ignore: deprecated_member_use
                                    FlatButton(
                                      textColor: Colors.blue,
                                      child: Text(
                                        'Sign up',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: RegisterPage(),
                                              inheritTheme: true,
                                              ctx: context),
                                        );
                                      },
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                ),
                              ),
                            ],
                          ),
                          Center(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.yellow[900])),
                              onPressed: () {
                                _displayTextInputDialog(context);
                              },
                              child: Text('Lihat Graphic'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget myTextInput(controller, String hint, bool secure) {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextFormField(
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
