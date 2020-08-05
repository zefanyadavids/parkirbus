import 'dart:convert';
import 'package:e_parking/recommendation.dart';
import 'package:e_parking/setting.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
//String host = "http://3.227.56.82:1337";
String host = "http://192.168.43.250:1337";

void 
main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeusParking',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: MyHomePage(title: 'e-Parking'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//class ini digunakan untuk dropdown pilihan area parkir
class Company {
  int id;
  String name;
  String code;

  Company(this.id, this.name, this.code);

  static List<Company> getCompanies() {
    return <Company>[
      Company(1, 'Abu Bakar Ali', 'ABA'),
      Company(2, 'Ngabean', 'NGB'),
      Company(3, 'Senopati', 'SEN'),
    ];
  }
}

//class ini digunakan untuk chart bus terparkir
class AddCharts {
  final String label;
  final int value;
  AddCharts(this.label, this.value);
}

class _MyHomePageState extends State<MyHomePage> {
  //inisialisasi data dalam dashboard
  int capacity = 0;
  String distance = "unknow";
  String duration = "unknow";
  String trafficModel = "";
  bool visible = false;

  //inisialisasi untuk dropdown list area parkir
  String parkingAreaVal;
  List parkingArea = ["Abu Bakar Ali", "Ngabean", "Senopati"];
  Map parkingAreaMap = {"Abu Bakar Ali" : "ABA", "Ngabean" : "NGB", "Senopati" : "SEN"};

  //inisialisasi data untuk peta
  double mapViewLatitude = -7.791501;
  double mapViewLongitude = 110.365895;
  List<Marker> allMarkers = [];

  //inisialisasi data untuk chart
  var timeChart = ["0.00", "0.00", "0.00", "0.00", "0.00", "0.00", "0.00"];
  var busParkedChart = [0, 0, 0, 0, 0, 0, 0];
  static var chartdisplay;

  //init state untuk variabel yang digunakan untuk main.dart (halaman dashboard)
  @override
  void initState() {
    super.initState();

    setState(() {
      var data = [
        AddCharts(timeChart[0], busParkedChart[0]),
        AddCharts(timeChart[1], busParkedChart[1]),
        AddCharts(timeChart[2], busParkedChart[2]),
        AddCharts(timeChart[3], busParkedChart[3]),
        AddCharts(timeChart[4], busParkedChart[4]),
        AddCharts(timeChart[5], busParkedChart[5]),
        AddCharts(timeChart[6], busParkedChart[6]),
      ];
      var series = [
        charts.Series(
          domainFn: (AddCharts addCharts, _) => addCharts.label,
          measureFn: (AddCharts addCharts, _) => addCharts.value,
          colorFn: (AddCharts addCharts, _) =>
              charts.ColorUtil.fromDartColor(Colors.teal),
          id: 'addCharts',
          data: data,
        ),
      ];
      chartdisplay = charts.BarChart(
        series,
        animationDuration: Duration(milliseconds: 1500),
      );
    });

    allMarkers.add(
      Marker(
        markerId: MarkerId('ABA'), 
        draggable: false, 
        infoWindow: InfoWindow(
          title: "Area Parkir Abu Bakar Ali",
          snippet: "Jl. Abu Bakar Ali No.1,\nSuryatmajan, Kec. Danurejan,\nKota Yogyakarta"
        ),
        onTap: () {
         
        },
        position: LatLng(-7.789946, 110.366873)
      )
    );
    allMarkers.add(
      Marker(
        markerId: MarkerId('NGB'), 
        draggable: false, 
        infoWindow: InfoWindow(
          title: "Area Parkir Ngabean",
          snippet: "Jl. KH Wahid Hasyim No.7,\nNotoprajan, Ngampilan,\nKota Yogyakarta",
        ),
        onTap: () {
          print("Ngabean");
        },
        position: LatLng(-7.801396, 110.356231)
      )
    );
    allMarkers.add(
      Marker(
        markerId: MarkerId('SEN'), 
        draggable: false, 
        infoWindow: InfoWindow(
          title: "Area Parkir Senopati",
          snippet: "Jl. Panembahan Senopati No.16,\nPrawirodirjan, Kec. Gondomanan,\nKota Yogyakarta"
        ),
        onTap: () {
          print("Senopati");
        },
        position: LatLng(-7.801696, 110.367738)
      )
    );
  }

  //fungsi yang digunakan saat area parkir terpilih pada dropdown list area parkir
  onChangeDropdownItem(String value) async {
    setState(() {
      parkingAreaVal = value;  //Untuk memberitahu _valFriends bahwa isi nya akan diubah sesuai dengan value yang kita pilih
    });

    //mendapatkan data area parkir
    String parkingAreaUri = host + "/api/v1/parkingareas?parking_code=" + parkingAreaVal;
    var parkingAreaRes = await http.get(parkingAreaUri);
    var parkingAreaData = jsonDecode(parkingAreaRes.body);
    var parkingAreaId = parkingAreaData['parkingAreas'][0]['id'];
    var parkingAreaLatitude = parkingAreaData['parkingAreas'][0]['latitude'];
    var parkingAreaLongitude = parkingAreaData['parkingAreas'][0]['longitude'];
    var total = parkingAreaData['parkingAreas'][0]['parking_capacity'];
    var filled = (parkingAreaData['parkingAreas'][0]['parking_filled']).round();
    trafficModel = parkingAreaData['parkingAreas'][0]['traffic_model'];
    capacity = total-filled;

    //memamnggil google distance matrix API
    //geolocation current location
    final position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    //percabangan API uri setiap traffic model
    String googleApiUri;
    if(trafficModel=="default"){
    googleApiUri = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=" +
        (position.latitude).toString() + "," + (position.longitude).toString() +
        "&destinations=" + parkingAreaLatitude + ",%20" + parkingAreaLongitude + "&departure_time=now&key=AIzaSyD5NMkehswtLHBwd0hf_bYYhoeyZBKZtew";
    } else if(trafficModel=="pessimistic"){
    googleApiUri = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=" +
        (position.latitude).toString() + "," + (position.longitude).toString() +
        "&destinations=" + parkingAreaLatitude + ",%20" + parkingAreaLongitude + "&traffic_model=pessimistic&departure_time=now&key=AIzaSyD5NMkehswtLHBwd0hf_bYYhoeyZBKZtew";
    } else if(trafficModel=="optimistic"){
    googleApiUri = "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=" +
        (position.latitude).toString() + "," + (position.longitude).toString() +
        "&destinations=" + parkingAreaLatitude + ",%20" + parkingAreaLongitude + "&traffic_model=optimistic&departure_time=now&key=AIzaSyD5NMkehswtLHBwd0hf_bYYhoeyZBKZtew";
    }
    var googleApiRes = await http.get(googleApiUri);
    var googleApiData = jsonDecode(googleApiRes.body);
    distance = googleApiData['rows'][0]['elements'][0]['distance']['text'];
    duration = googleApiData['rows'][0]['elements'][0]['duration_in_traffic']['text'];
    print(googleApiData);
    
    //memperoleh data bus terparkir pada chart
    String busParkedUri = host + "/api/v1/parkingrecords/countBus?parking_area_id=" + parkingAreaId.toString();
    var busParkedRes = await http.get(busParkedUri);
    var busParkedData = jsonDecode(busParkedRes.body);
    //memperoleh data waktu pada chart
    var chartTimeRes = await http.get( host + "/api/v1/dashboards/gettimeforchart");
    var chartTimeData = jsonDecode(chartTimeRes.body);
    
    //convert data jarak
    var convertDistanceUri =  host + "/api/v1/dashboards/convertdistance?distance=$distance";
    var convertDistanceRes = await http.get(convertDistanceUri);
    var convertDistanceData = jsonDecode(convertDistanceRes.body);
    var distanceData = convertDistanceData[0];
    distance = "$distanceData km";

    //convert data waktu
    var convertDurationUri =  host + "/api/v1/dashboards/convertduration?duration=$duration";
    var convertDurationRes = await http.get(convertDurationUri);
    var convertDurationData = jsonDecode(convertDurationRes.body);
    var durationData = convertDurationData[0];
    duration = "$durationData menit";
    
    //memanggil kembali setstate untuk memperbaharui data pada main.dart (halaman hasboard)
    setState(() {
      var data = [
        AddCharts(chartTimeData[0], busParkedData[0]),
        AddCharts(chartTimeData[1], busParkedData[1]),
        AddCharts(chartTimeData[2], busParkedData[2]),
        AddCharts(chartTimeData[3], busParkedData[3]),
        AddCharts(chartTimeData[4], busParkedData[4]),
        AddCharts(chartTimeData[5], busParkedData[5]),
        AddCharts(chartTimeData[6], busParkedData[6]),
      ];
      var series = [
        charts.Series(
          domainFn: (AddCharts addCharts, _) => addCharts.label,
          measureFn: (AddCharts addCharts, _) => addCharts.value,
          colorFn: (AddCharts addCharts, _) =>
              charts.ColorUtil.fromDartColor(Colors.teal),
          id: 'addCharts',
          data: data,
        ),
      ];
      chartdisplay = charts.BarChart(
        series,
        animationDuration: Duration(milliseconds: 1500),
      );
      visible = true;
    });
  }

  //list tampilan dashboard bagian bawah
  List<Widget> dashboardInfoList() {
    var parkingAreaList = Column(
      children: <Widget>[
        new Container(
          child: Padding(
            padding: EdgeInsets.only(bottom: 30),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 20.0),
                  DropdownButton(
                    hint: Text("Pilih Area Parkir"),
                    value: parkingAreaVal,
                    items: parkingArea.map((value) {
                      return DropdownMenuItem(
                        child: Text(value),
                        value: parkingAreaMap["$value"],
                      );
                    }).toList(),
                    onChanged: (value) {
                      onChangeDropdownItem(value);
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    var capacityColumn = visible ? Column(
      children: <Widget>[
        new Text.rich(
          TextSpan(
            text: 'Grafik Bus Terparkir',
          ),
        ),
        new Container(
          height: MediaQuery.of(context).size.height * 0.30,
          width: MediaQuery.of(context).size.width * 0.80,
          child: chartdisplay,
        ),
      ],
    ) : Container();

    var matrixDistance = visible ? Column(
      children: <Widget>[
        Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: new Row(
              children: <Widget>[
                Expanded(child: new Center(child: new Text("Slot Tersisa"))),
                Expanded(child: new Center(child: new Text("Jarak"))),
                Expanded(child: new Center(child: new Text("Estimasi Waktu"))),
              ],
            ),
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 0),
            child: new Row(
              children: <Widget>[
                Expanded(child: new Center(child: new Text("$capacity"))),
                Expanded(child: new Center(child: new Text(distance))),
                Expanded(child: new Center(child: new Text(duration))),
              ],
            ),
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 15.0, 0, 50.0),
            child: new Row(
              children: <Widget>[
                Expanded(child: new Center(child: new Text(""))),
                Expanded(child: new Center(child: new Text(""))),
                Expanded(child: new Center(child: new Text("($trafficModel)"))),
              ],
            ),
          ),
        )
      ],
    )  : Container();

    List<Widget> infoList = <Widget>[
      parkingAreaList,
      capacityColumn,
      matrixDistance
    ];
    return infoList;
  }

  //widget tampilan dashboard keseluruhan
  @override
  Widget build(BuildContext context) {
    var dashboard = Column(
      children: <Widget>[
        new Column(
          children: <Widget>[
            new Container(
              width: MediaQuery.of(context).size.width,
              height: 260.0,
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: LatLng(mapViewLatitude, mapViewLongitude),
                  zoom: 13.67,
                ),
                markers: Set.from(allMarkers),
              ),
            ),
          ],
        ),
        new Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: 50.0),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: List.generate(
                dashboardInfoList().length,
                (index) {
                  return new Column(
                    children: <Widget>[
                      Container(
                        width: 400.0,
                        color: Color.fromRGBO(1, 1, 1, 0),
                        child: Center(child: dashboardInfoList()[index]),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );

    final listPage = <Widget>[
      dashboard,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Setting()),
                );
              },
              child: Icon(
                  Icons.settings
              ),
            )
          ),
        ],
      ),
      body: Container(
        child: listPage[0],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Recommendation()),
          );
        },
        label: Text('Rekomendasikan Saya'),
        icon: Icon(Icons.search),
        backgroundColor: Colors.teal,
      ),
    );
  }
}