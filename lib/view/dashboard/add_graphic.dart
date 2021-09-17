import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:page_transition/page_transition.dart';
import 'package:suhu_tubuh/view/dashboard/graphic_pasien.dart';
import 'package:suhu_tubuh/viewmodel/base_model.dart';
import 'package:suhu_tubuh/viewmodel/dashboard_model.dart';
import 'package:intl/intl.dart';
import '../../base_view.dart';
import 'package:intl/date_symbol_data_local.dart';

class AddGraphic extends StatefulWidget {
  final String uid;
  final String nama;
  final String kodeuser;

  const AddGraphic(this.uid, this.nama, this.kodeuser);
  @override
  _AddGraphicState createState() => _AddGraphicState();
}

class _AddGraphicState extends State<AddGraphic> {
  String tanggal =
      (DateFormat("EEEE dd MMMM, yyyy", 'id').format(DateTime.now()))
          .toString();
  String jam = (DateFormat("HH:mm:ss").format(DateTime.now())).toString();

  List<DocumentSnapshot> dataSuhu;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
  }

  Future<QuerySnapshot> getData() async {
    final data = await FirebaseFirestore.instance
        .collection('suhu_tubuh')
        .where('pasienid', isEqualTo: widget.uid)
        .get();
    dataSuhu = data.docs;
    return data;
  }

  final _formKey = GlobalKey<FormState>();
  var suhu = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BaseView<DashBoardModel>(
      // onModelReady: (model) => model.getPasien(),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.nama),
        ),
        body: model.state == ViewState.Busy ?? ViewState.Idle
            ? Center(child: CircularProgressIndicator())
            : Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        decoration: new BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Hari ini : $tanggal",
                              style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              onPressed: () {
                                suhu.clear();

                                if (dataSuhu.length > 0) {
                                  var format = DateFormat("HH:mm:ss");
                                  final start =
                                      format.parse(dataSuhu.last['jam']);
                                  final finish = format.parse(jam);

                                  var format2 = DateFormat("yyyy-MM-dd");
                                  final sDay =
                                      format2.parse(dataSuhu.last['tanggal']);
                                  final sFinish =
                                      format2.parse(DateTime.now().toString());

                                  bool inputs = false;

                                  if (sDay.day == sFinish.day) {
                                    int lengthJarak =
                                        finish.difference(start).inHours;
                                    print("Jarak $lengthJarak");
                                    if (lengthJarak >= 8) {
                                      setState(() {
                                        inputs = true;
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      inputs = true;
                                    });
                                  }

                                  print("Tanggal ${sDay.day} - ${sFinish.day}");
                                  if (inputs) {
                                    showModalBottomSheet(
                                        isScrollControlled: true,
                                        context: context,
                                        builder: (context) {
                                          return FractionallySizedBox(
                                            heightFactor: 0.3,
                                            child: Form(
                                              key: _formKey,
                                              child: Center(
                                                child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text(
                                                          'Input Suhu Tubuh Pasien'),
                                                      myTextInput(suhu,
                                                          'Suhu Tubuh', false),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            1.6,
                                                        child: ElevatedButton(
                                                          onPressed: () async {
                                                            bool input =
                                                                await model
                                                                    .suhuTubuh(
                                                              widget.uid,
                                                              widget.kodeuser,
                                                              int.parse(
                                                                  suhu.text),
                                                              DateFormat(
                                                                      "yyyy-MM-dd")
                                                                  .format(DateTime
                                                                      .now()),
                                                              (DateFormat("HH:mm:ss")
                                                                      .format(DateTime
                                                                          .now()))
                                                                  .toString(),
                                                            );
                                                            if (input == true) {
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "Input berhasil...",
                                                                  toastLength: Toast
                                                                      .LENGTH_LONG,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .green,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      16.0);
                                                              Future.delayed(
                                                                  const Duration(
                                                                      seconds:
                                                                          2),
                                                                  () {
                                                                Navigator.pop(
                                                                    context);
                                                              });
                                                            } else {
                                                              Fluttertoast.showToast(
                                                                  msg:
                                                                      "Input gagal....",
                                                                  toastLength: Toast
                                                                      .LENGTH_LONG,
                                                                  gravity:
                                                                      ToastGravity
                                                                          .CENTER,
                                                                  timeInSecForIosWeb:
                                                                      1,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  fontSize:
                                                                      16.0);
                                                            }
                                                          },
                                                          child: Text('Submit'),
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ]),
                                              ),
                                            ),
                                          );
                                        });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Hanya boleh setelah 8 jam dari pemeriksaan terakhir",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 16.0);
                                  }
                                } else {
                                  showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        return FractionallySizedBox(
                                          heightFactor: 0.3,
                                          child: Form(
                                            key: _formKey,
                                            child: Center(
                                              child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Text(
                                                        'Input Suhu Tubuh Pasien'),
                                                    myTextInput(suhu,
                                                        'Suhu Tubuh', false),
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.6,
                                                      child: ElevatedButton(
                                                        onPressed: () async {
                                                          bool input =
                                                              await model
                                                                  .suhuTubuh(
                                                            widget.uid,
                                                            widget.kodeuser,
                                                            int.parse(
                                                                suhu.text),
                                                            DateFormat(
                                                                    "yyyy-MM-dd",
                                                                    'id')
                                                                .format(DateTime
                                                                    .now()),
                                                            (DateFormat("HH:mm:ss")
                                                                    .format(DateTime
                                                                        .now()))
                                                                .toString(),
                                                          );
                                                          if (input == true) {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Input berhasil...",
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors
                                                                        .green,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                            Future.delayed(
                                                                const Duration(
                                                                    seconds: 2),
                                                                () {
                                                              Navigator.pop(
                                                                  context);
                                                            });
                                                          } else {
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "Input gagal....",
                                                                toastLength: Toast
                                                                    .LENGTH_LONG,
                                                                gravity:
                                                                    ToastGravity
                                                                        .CENTER,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          }
                                                        },
                                                        child: Text('Submit'),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ]),
                                            ),
                                          ),
                                        );
                                      });
                                }
                              },
                              icon: Icon(
                                Icons.add,
                                size: 35,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<QuerySnapshot>(
                          future: getData(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data.docs.length == 0
                                  ? Center(
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                1.4,
                                        child: Image.asset(
                                          'assets/kosong.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: snapshot.data.docs.length,
                                      shrinkWrap: true,
                                      physics: BouncingScrollPhysics(),
                                      itemBuilder: (context, i) {
                                        var dts = snapshot.data.docs[i];
                                        return Card(
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              child: Text(
                                                "${i + 1}",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            title: Text(
                                              "${dts['suhu']} °Celcius ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.black),
                                            ),
                                            subtitle: Text(
                                                "Tanggal ${DateFormat("d MMMM yyyy").format(DateTime.parse(dts['tanggal']))} | ${dts['jam']}"),
                                          ),
                                        );
                                      });
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          }),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.rightToLeft,
                                child: GraphicPasien(
                                  uid: widget.uid,
                                  nama: widget.nama,
                                ),
                                inheritTheme: true,
                                ctx: context),
                          );
                        },
                        child: Text('Lihat Graphic'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget myTextInput(controller, String hint, bool secure) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.4,
      padding: EdgeInsets.all(10),
      child: TextFormField(
        controller: controller,
        obscureText: secure,
        keyboardType: TextInputType.number,
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
