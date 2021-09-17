import 'package:flutter/material.dart';
import 'package:suhu_tubuh/base_view.dart';
import 'package:suhu_tubuh/viewmodel/base_model.dart';
import 'package:suhu_tubuh/viewmodel/dashboard_model.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class GraphicPasien extends StatefulWidget {
  final String uid;
  final String nama;
  const GraphicPasien({Key key, this.uid, this.nama}) : super(key: key);
  @override
  _GraphicPasienState createState() => _GraphicPasienState();
}

class _GraphicPasienState extends State<GraphicPasien> {
  @override
  void initState() {
    super.initState();
  }

  List<charts.Series<TimeSeriesSales, DateTime>> seriesList;

  // List<charts.Series<TimeSeriesSales, DateTime>> _createRandomData() {
  //   return [
  //     new charts.Series<TimeSeriesSales, DateTime>(
  //       id: 'Sales',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (TimeSeriesSales sales, _) => sales.time,
  //       measureFn: (TimeSeriesSales sales, _) => sales.sales,
  //       data: desktopSalesData,
  //     )
  //   ];
  // }

  @override
  Widget build(BuildContext context) {
    return BaseView<DashBoardModel>(
      onModelReady: (model) => model.getSuhu(widget.uid).then((valz) {
        for (var it in valz) {
          DateTime dates = DateTime.parse(it['tanggal']);

          print(dates);
          model.desktopSalesData.add(TimeSeriesSales(dates, it['suhu']));
        }
        // setState(() {
        //   seriesList = _createRandomData();
        // });
      }),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(widget.nama),
        ),
        body: model.state == ViewState.Busy ?? ViewState.Idle
            ? Center(child: CircularProgressIndicator())
            : Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: MediaQuery.of(context).size.height / 1.2,
                        child: SimpleTimeSeriesChart.withSampleData(model),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

//model sync fusion

class SimpleTimeSeriesChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleTimeSeriesChart(this.seriesList, {this.animate});

  factory SimpleTimeSeriesChart.withSampleData(model) {
    return new SimpleTimeSeriesChart(
      _createSampleData(model),
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.TimeSeriesChart(
      seriesList,
      animate: animate,
      dateTimeFactory: const charts.LocalDateTimeFactory(),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData(
      model) {
    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: model.desktopSalesData,
      )
    ];
  }
}

class TimeSeriesSales {
  final DateTime time;
  final int sales;
  TimeSeriesSales(this.time, this.sales);
}
