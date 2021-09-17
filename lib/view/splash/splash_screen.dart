import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhu_tubuh/core/service.dart';
import 'package:suhu_tubuh/locator.dart';
import 'package:suhu_tubuh/view/dashboard/dashboard.dart';
import 'package:suhu_tubuh/view/user/login.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> animation;

  var _visible = true;
  FToast fToast;

  @override
  void initState() {
    startSplashScreen();
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  startSplashScreen() async {
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 2));
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animation.addListener(() => this.setState(() {}));
    animationController.forward();
    final Services api = locator<Services>();

    setState(() {
      _visible = !_visible;
    });

    var duration = const Duration(seconds: 3);
    return Timer(
      duration,
      () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        //prefs.clear();
        if (prefs.getBool('isLogin') == true) {
          var login = await api.loginUser(
              prefs.getString('email'), prefs.getString('password'), context);

          if (login == true) {
            Future.delayed(const Duration(seconds: 2), () {
              if (prefs.getInt('isRole') == 2) {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(
                            prefs.getString('userid'),
                            prefs.getString('nama'))));
              } else {
                // Navigator.pushReplacement(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) => AdminPage(
                //             prefs.getString('userid'),
                //             prefs.getString('nama'))));
              }
            });
          } else {
            Fluttertoast.showToast(
                msg: "Session berakhir, silahkan login lagi",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            prefs.clear();
          }
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LoginPage(),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black, // navigation bar color
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light, // status bar color
    ));
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(fit: StackFit.expand, children: <Widget>[
        new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(30),
              child: Center(
                child: Image.asset(
                  "assets/logo.png",
                  width: animation.value * 300,
                  height: animation.value * 300,
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}
