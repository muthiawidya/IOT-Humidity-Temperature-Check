import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:suhu_tubuh/base_view.dart';
import 'package:suhu_tubuh/view/dashboard/graphic_pasien.dart';
import 'package:suhu_tubuh/viewmodel/base_model.dart';
import 'package:suhu_tubuh/viewmodel/dashboard_model.dart';

class GraphicSearch extends StatefulWidget {
  final String kodeuser;
  const GraphicSearch({Key key, this.kodeuser}) : super(key: key);
  @override
  _GraphicSearchState createState() => _GraphicSearchState();
}

class _GraphicSearchState extends State<GraphicSearch> {
  @override
  void initState() {
    super.initState();
  }

  List<charts.Series<TimeSeriesSales, DateTime>> seriesList;

  @override
  Widget build(BuildContext context) {
    return BaseView<DashBoardModel>(
      onModelReady: (model) => model.getSuhuSearch(widget.kodeuser).then((valz) {
        for (var it in valz) {
          DateTime dates = DateTime.parse(it['tanggal']);
          model.desktopSalesData.add(TimeSeriesSales(dates, it['suhu']));
        }
        // setState(() {
        //   seriesList = _createRandomData();
        // });
      }),
      builder: (context, model, child) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Graphic user"),
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
                        child: SimpleTimeSeriesCharts.withSampleData(model),
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

class SimpleTimeSeriesCharts extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  SimpleTimeSeriesCharts(this.seriesList, {this.animate});

  factory SimpleTimeSeriesCharts.withSampleData(model) {
    return new SimpleTimeSeriesCharts(
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
