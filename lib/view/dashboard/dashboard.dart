import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:suhu_tubuh/view/dashboard/add_graphic.dart';
import 'package:suhu_tubuh/view/dashboard/add_pasien.dart';
import 'package:suhu_tubuh/view/dashboard/cari.dart';
import 'package:suhu_tubuh/view/dashboard/graphic_pasien.dart';
import 'package:suhu_tubuh/view/user/login.dart';
import 'package:suhu_tubuh/viewmodel/base_model.dart';
import 'package:suhu_tubuh/viewmodel/dashboard_model.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../base_view.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import "package:collection/collection.dart";

class HomeScreen extends StatefulWidget {
  final String uid;
  final String nama;

  const HomeScreen(this.uid, this.nama);
  @override
  _HomeScreenState createState() => new _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  String selectedDate = '';
  String dateCount = '';
  String range = '';
  String rangeCount = '';

  VoidCallback onSetting;
  ScrollController scrollController;
  SlidingUpPanelController panelController = SlidingUpPanelController();

  String namaPasien = '';
  String uid = '';

  void setTanggal(String name, String useruid) {
    setState(() {
      namaPasien = name;
      uid = useruid;
    });
    panelController.expand();
  }

  String startDate = '';
  String endDate = '';

  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    print('select');
    setState(() {
      if (args.value is PickerDateRange) {
        range =
            DateFormat('dd/MM/yyyy').format(args.value.startDate).toString() +
                ' - ' +
                DateFormat('dd/MM/yyyy')
                    .format(args.value.endDate ?? args.value.startDate)
                    .toString();
        startDate =
            DateFormat('yyyy-MM-dd').format(args.value.startDate).toString();
        endDate = DateFormat('yyyy-MM-dd')
            .format(args.value.endDate ?? args.value.startDate)
            .toString();
      } else if (args.value is DateTime) {
        selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        dateCount = args.value.length.toString();
      } else {
        rangeCount = args.value.length.toString();
      }
    });
  }

  // Notifikasi
  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _showNotification(String nama, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'your channel id', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await notificationsPlugin.show(0, nama, body, platformChannelSpecifics,
        payload: 'item x');
  }

  void initializeSetting() async {
    var initializeAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializeSetting = InitializationSettings(android: initializeAndroid);
    await notificationsPlugin.initialize(initializeSetting);
  }

  Future<void> _showNotificationPeriod(String nama, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
            'peroid', 'your channel name', 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await notificationsPlugin.show(0, nama, body, platformChannelSpecifics,
        payload: 'item x');
  }

  List<DocumentSnapshot> dataSuhu;

  Future<QuerySnapshot> getData() async {
    final data =
        await FirebaseFirestore.instance.collection('suhu_tubuh').get();
    dataSuhu = data.docs;
    waktuCheckSuhu();
    return data;
  }

  void waktuCheckSuhu() {
    var format = DateFormat("HH:mm:ss");
    final finish = format.parse(DateFormat("HH:mm:ss").format(DateTime.now()));
    var newMap = groupBy(dataSuhu, (obj) => obj['pasienid']);
    for (var i in newMap.keys) {
      var x = dataSuhu.where((e) => e['pasienid'] == i).toList();
      final start = format.parse(x.last['jam']);
      if (finish.difference(start).inHours >= 8) {
        sendNotifPeriod(x.last['pasienid']);
      }
    }
  }

  Future sendNotifPeriod(String pasienId) async {
    final data = await FirebaseFirestore.instance
        .collection('pasien')
        .doc(pasienId)
        .get();
    _showNotificationPeriod(data['name'], 'Waktu nya check suhu badan');
    return data;
  }

  Timer timer;

  @override
  void initState() {
    super.initState();
    panelController.anchor();
    initializeDateFormatting();
    initializeSetting();
    timer = Timer.periodic(Duration(minutes: 10), (Timer t) => getData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseView<DashBoardModel>(
      onModelReady: (model) => model.getPasien().then((e) async {
        List<DocumentSnapshot> pasien = e;
        for (var s in pasien) {
          var dats = await FirebaseFirestore.instance
              .collection('suhu_tubuh')
              .where('pasienid', isEqualTo: s.id)
              .get();
          if (dats.docs.length >= 4) {
            for (int i = 1; i <= dats.docs.length; i++) {
              if (i % 3 == 0) {
                _showNotification(s['name'], 'Membutuhkan perawatan Khusus');
              }
            }
          }
        }
        getData();
      }),
      builder: (context, model, child) => Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text('Dashboard'),
              actions: <Widget>[
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: CariPasien(),
                              inheritTheme: true,
                              ctx: context));
                    },
                    icon: Icon(Icons.search)),
                SizedBox(width: 14),
                IconButton(
                    onPressed: () {
                      showAlertDialog(context);
                    },
                    icon: Icon(Icons.settings_power_sharp))
                // Padding(
                //   child: IconButton(
                //       icon: Icon(Icons.info),
                //       onPressed: () {
                //         getData();
                //         // _showNotification("Nama Pasien", "Test Notifikasi");
                //       }),
                //   padding: const EdgeInsets.only(right: 10.0),
                // )
              ],
            ),
            // drawer: Drawer(),
            body: model.state == ViewState.Busy ?? ViewState.Idle
                ? Center(child: CircularProgressIndicator())
                : Container(
                    child: SingleChildScrollView(
                      physics: BouncingScrollPhysics(),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          await model.getPasien().then((e) async {
                            List<DocumentSnapshot> pasien = e;
                            for (var s in pasien) {
                              var dats = await FirebaseFirestore.instance
                                  .collection('suhu_tubuh')
                                  .where('pasienid', isEqualTo: s.id)
                                  .get();
                              if (dats.docs.length >= 4) {
                                for (int i = 1;
                                    i <= dats.docs.length + 1;
                                    i++) {
                                  if (i % 3 == 0) {
                                    _showNotification(s['name'],
                                        'Membutuhkan perawatan Khusus');
                                  }
                                }
                              }
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Column(
                            children: [
                              FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('pasien')
                                    .get(),
                                builder: (context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    return snapshot.data.docs.length == 0
                                        ? Center(
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.4,
                                              child: Image.asset(
                                                'assets/kosong.png',
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics: BouncingScrollPhysics(),
                                            itemCount:
                                                snapshot.data.docs.length,
                                            itemBuilder: (context, index) {
                                              var data =
                                                  snapshot.data.docs[index];
                                              return Card(
                                                elevation: 2,
                                                child: ListTile(
                                                  contentPadding:
                                                      EdgeInsets.all(8),
                                                  leading: CircleAvatar(
                                                    child: Text('${index + 1}',
                                                        style: TextStyle(
                                                            fontSize: 22,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white)),
                                                    radius: 22,
                                                  ),
                                                  title: Text(data['name'],
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black)),
                                                  subtitle: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          "Kode ${data['kodeuser']}",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey)),
                                                      Text(data['no_hp'],
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color:
                                                                  Colors.grey)),
                                                      Text(data['alamat'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.grey)),
                                                    ],
                                                  ),
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                                    context,
                                                                    PageTransition(
                                                                        type: PageTransitionType
                                                                            .rightToLeft,
                                                                        child: AddGraphic(
                                                                            data
                                                                                .id,
                                                                            data[
                                                                                'name'],
                                                                            data[
                                                                                'kodeuser']),
                                                                        inheritTheme:
                                                                            true,
                                                                        ctx:
                                                                            context))
                                                                .then((value) {
                                                              model
                                                                  .getPasien()
                                                                  .then(
                                                                      (e) async {
                                                                List<DocumentSnapshot>
                                                                    pasien = e;
                                                                for (var s
                                                                    in pasien) {
                                                                  var dats = await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'suhu_tubuh')
                                                                      .where(
                                                                          'pasienid',
                                                                          isEqualTo:
                                                                              s.id)
                                                                      .get();
                                                                  if (dats.docs
                                                                          .length >=
                                                                      3) {
                                                                    for (int i =
                                                                            1;
                                                                        i <=
                                                                            dats.docs.length;
                                                                        i++) {
                                                                      if (i % 3 ==
                                                                          0) {
                                                                        _showNotification(
                                                                            s['name'],
                                                                            'Membutuhkan perawatan Khusus');
                                                                      }
                                                                    }
                                                                  }
                                                                }
                                                              });
                                                            });
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .add_chart_sharp,
                                                            size: 30,
                                                            color: Colors.blue,
                                                          )),
                                                      IconButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              PageTransition(
                                                                  type: PageTransitionType
                                                                      .rightToLeft,
                                                                  child:
                                                                      GraphicPasien(
                                                                    uid:
                                                                        data.id,
                                                                    nama: data[
                                                                        'name'],
                                                                  ),
                                                                  inheritTheme:
                                                                      true,
                                                                  ctx: context),
                                                            );
                                                          },
                                                          icon: Icon(
                                                            Icons
                                                                .bar_chart_sharp,
                                                            size: 34,
                                                            color: Colors
                                                                .purpleAccent,
                                                          ))
                                                    ],
                                                  ),
                                                ),
                                              );
                                            });
                                  } else {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.blue,
              onPressed: () async {
                await Navigator.push(
                  context,
                  PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: TambahPasien(),
                      inheritTheme: true,
                      ctx: context),
                ).then((value) {
                  model.getPasien().then((e) async {
                    List<DocumentSnapshot> pasien = e;
                    for (var s in pasien) {
                      var dats = await FirebaseFirestore.instance
                          .collection('suhu_tubuh')
                          .where('pasienid', isEqualTo: s.id)
                          .get();
                      if (dats.docs.length >= 4) {
                        for (int i = 1; i <= dats.docs.length; i++) {
                          if (i % 3 == 0) {
                            _showNotification(
                                s['name'], 'Membutuhkan perawatan Khusus');
                          }
                        }
                      }
                    }
                  });
                });
              },
              child: Icon(
                Icons.person_add,
                color: Colors.white,
                size: 35,
              ),
            ),
          ),
          SlidingUpPanelWidget(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 15.0),
              decoration: ShapeDecoration(
                color: Colors.white,
                shadows: [
                  BoxShadow(
                      blurRadius: 5.0,
                      spreadRadius: 2.0,
                      color: const Color(0x11000000))
                ],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white,
                      alignment: Alignment.center,
                      height: 50.0,
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.menu,
                            size: 30,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 8.0,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              namaPasien,
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                panelController.anchor();
                              },
                              icon: Icon(Icons.close))
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                    Divider(
                      height: 0.5,
                      color: Colors.grey[300],
                    ),
                    Flexible(
                      child: Container(
                        child: SfDateRangePicker(
                          onSelectionChanged: _onSelectionChanged,
                          selectionMode: DateRangePickerSelectionMode.range,
                          initialSelectedRange: PickerDateRange(
                              DateTime.now().subtract(const Duration(days: 4)),
                              DateTime.now().add(const Duration(days: 3))),
                        ),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Selected range: ' + range,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(
                                        color: Colors.teal, width: 2.0)))),
                        child: Text('Submit'),
                        onPressed: () {
                          panelController.anchor();
                          // Navigator.push(
                          //   context,
                          //   PageTransition(
                          //       type: PageTransitionType.rightToLeft,
                          //       child: GrapichRange(
                          //         uid: uid,
                          //         nama: widget.nama,
                          //         startDate: startDate,
                          //         endDate: endDate,
                          //       ),
                          //       inheritTheme: true,
                          //       ctx: context),
                          // );
                        },
                      ),
                    ),
                  ],
                  mainAxisSize: MainAxisSize.min,
                ),
              ),
            ),
            controlHeight: 0.0,
            anchor: 0.0,
            panelController: panelController,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Batal"),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = TextButton(
      child: Text("Logout"),
      onPressed: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.clear();
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Lgout"),
      content: Text("Anda yakin logout ?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
