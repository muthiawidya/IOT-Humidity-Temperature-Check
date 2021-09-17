import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:suhu_tubuh/base_view.dart';
import 'package:suhu_tubuh/view/dashboard/add_graphic.dart';
import 'package:suhu_tubuh/view/dashboard/graphic_pasien.dart';
import 'package:suhu_tubuh/viewmodel/dashboard_model.dart';

class CariPasien extends StatefulWidget {
  @override
  _CariPasienState createState() => _CariPasienState();
}

class _CariPasienState extends State<CariPasien> {
  var cari = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BaseView<DashBoardModel>(
      // onModelReady: (model) =>
      builder: (context, model, child) => Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30, horizontal: 14),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back)),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 1.3,
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: TextField(
                            // controller: cari,
                            autofocus: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              hintText: "Masukan kode pasien",
                              hintStyle: TextStyle(color: Colors.grey[500]),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 18),
                            ),
                            onSubmitted: (val) {
                              setState(() {
                                cari.text = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('pasien')
                        .where('kodeuser', isEqualTo: cari.text)
                        .get(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        return new ListView.builder(
                            itemCount: snapshot.data.docs.length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              print(snapshot.data.docs.length);
                              return snapshot.data.docs.length > 0
                                  ? Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            child: Text('${index + 1}',
                                                style: TextStyle(
                                                    fontSize: 22,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white)),
                                            radius: 22,
                                          ),
                                          title: Text(
                                              snapshot.data.docs[index]['name'],
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black)),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  "Kode ${snapshot.data.docs[index]['kodeuser']}",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey)),
                                              Text(
                                                  snapshot.data.docs[index]
                                                      ['no_hp'],
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.grey)),
                                              Text(
                                                  snapshot.data.docs[index]
                                                      ['alamat'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        PageTransition(
                                                            type:
                                                                PageTransitionType
                                                                    .rightToLeft,
                                                            child: AddGraphic(
                                                                snapshot
                                                                    .data
                                                                    .docs[index]
                                                                    .id,
                                                                snapshot.data
                                                                            .docs[
                                                                        index]
                                                                    ['name'],
                                                                    snapshot.data.docs[index]['kodeuser']
                                                                    ),
                                                            inheritTheme: true,
                                                            ctx: context));
                                                  },
                                                  icon: Icon(
                                                    Icons.add_chart_sharp,
                                                    size: 30,
                                                    color: Colors.blue,
                                                  )),
                                              IconButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      PageTransition(
                                                          type:
                                                              PageTransitionType
                                                                  .rightToLeft,
                                                          child: GraphicPasien(
                                                            uid: snapshot.data
                                                                .docs[index].id,
                                                            nama: snapshot.data
                                                                    .docs[index]
                                                                ['name'],
                                                          ),
                                                          inheritTheme: true,
                                                          ctx: context),
                                                    );
                                                  },
                                                  icon: Icon(
                                                    Icons.bar_chart_sharp,
                                                    size: 34,
                                                    color: Colors.purpleAccent,
                                                  ))
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                      'Data tidak di temukan',
                                      style: TextStyle(color: Colors.black),
                                    ));
                            });
                      } else {
                        return Center(
                            child: Text(
                          'Data tidak di temukan',
                          style: TextStyle(color: Colors.black),
                        ));
                      }
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
