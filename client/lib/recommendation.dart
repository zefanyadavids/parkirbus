import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
//String host = "http://3.227.56.82:1337";
String host = "http://192.168.43.250:1337";

class Recommendation extends StatefulWidget {
  @override
  _RecommendationState createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation> {
  //inisialisasi variabel
  String parkingAreaCode;
  List candidate = [];
  List capacityList = [];
  List attributeWeightList = [];
  var resParkingAreaName;
  var capacity, resCapacity;
  var distance, resDistance;
  var duration, resDuration;
  Timer _timer;
  int _start = 120;
  bool visible = false;
  bool fullCapacity = true;

  //fungsi untuk timer
  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_start < 1) {
            timer.cancel();
            setState(() {
              getRecommendation();
              _start = 120;
            });
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }
 
  //fungsi untuk memperoleh data area parkir rekomendasi
  getParkingAreaInfo(parkingAreaCode) async {
    //mendapatkan data area parkir
    String parkingAreaUri = host + "/api/v1/parkingareas?parking_code=" + parkingAreaCode;
    var parkingAreaRes = await http.get(parkingAreaUri);
    var parkingAreaData = jsonDecode(parkingAreaRes.body);
    var parkingAreaName = parkingAreaData['parkingAreas'][0]['parking_name'];
    var parkingAreaLatitude = parkingAreaData['parkingAreas'][0]['latitude'];
    var parkingAreaLongitude = parkingAreaData['parkingAreas'][0]['longitude'];
    var total = parkingAreaData['parkingAreas'][0]['parking_capacity'];
    var filled = (parkingAreaData['parkingAreas'][0]['parking_filled']).round();
    var trafficModel = parkingAreaData['parkingAreas'][0]['traffic_model'];
    capacity = total-filled;
    capacityList.add(total);
    

    //cek kapasitas penuh
    if(capacity>0) {
      print(">>>>>>>>>>>>>>>>>>>");
      print(capacity);
      fullCapacity = false;
    }

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

    Object json = {
      "parkingAreaName": parkingAreaName,
      "totalCapacity" : total,
      "capacity": capacity, 
      "distance": distance, 
      "duration": duration
    };
    candidate.add(json);
  }

  //fungsi saat membuka halaman rekomendasi
  getRecommendation() async {
    setState(() {
      visible = false;
    });
    print("======================ABU BAKAR ALI======================");
    await getParkingAreaInfo("ABA");
    print("======================NGABEAN======================");
    await getParkingAreaInfo("NGB");
    print("======================SENOPATI======================");
    await getParkingAreaInfo("SEN");

    //get attribute weight
    var attrWeightRes = await http.get(host + "/api/v1/attributes");
    var attrWeightData = jsonDecode(attrWeightRes.body);
    var totalAttribute = attrWeightData['meta']['total'];
    for(var i=0; i<totalAttribute; i++) {
      attributeWeightList.add(attrWeightData['attributes'][i]['attribute_weight']);
    }

    Map<String, Object> sendCandidate = {};
    for (var i=0; i<candidate.length; i++) {
      sendCandidate['$i'] = candidate[i];
    }
    sendCandidate['capacityList'] = capacityList;
    sendCandidate['attrWeightList'] = attributeWeightList;
    sendCandidate['total'] = candidate.length;
    var data = jsonEncode(sendCandidate);

    print(data);

    String url = host + '/api/v1/recommendations/recommendationMethod';
    Map<String, String> headers = {"Content-type": "application/json"};
    http.Response response = await http.post(url, headers: headers, body: data);
    print(response.body);
    var recommendationResult = jsonDecode(response.body);

    startTimer();

    setState(() {
      resParkingAreaName = recommendationResult["parkingAreaName"];
      resCapacity = recommendationResult["capacity"];
      resDistance= recommendationResult["distance"];
      resDuration = recommendationResult["duration"];
      visible = true;
    });
  }

  //init state untuk variabel yang digunakan untuk recommendation.dart (halaman rekomendasi)
  @override
  void initState() {
    getRecommendation();
    super.initState();
  }

  //fungsi agar timer tidak berjalan sewaktu ganti ke halaman lain
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  //widget tampilan halaman rekomendasi
  @override
  Widget build(BuildContext context) {
    final recommendationBody = <Widget>[
      visible ? new Column(
        children: <Widget>[
          fullCapacity ? new Column(
            children: <Widget>[
              Image.asset(
                'assets/images/full.jpg',
              ),
              new Container(
                width: 300,
                height: 30,
                child: new Text("Semua tempat parkir penuh", textAlign: TextAlign.center),
              ),
            ],
          ) : new Column (
            children: <Widget>[
              Image.asset(
                'assets/images/bus.jpg',
                height: 200,
                width: 200,
              ),
              new Container(
                width: 300,
                height: 30,
                child: new Text("Rekomendasi tempat parkir untuk Anda", textAlign: TextAlign.center),
              ),
               new Container(
                width: 300,
                height: 40,
                child: new Text("diperbaharui dalam $_start detik", textAlign: TextAlign.center),
              ),
              new Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: <Widget>[
                    new Container(
                      width: 300,
                      height: 60,
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: new Text("$resParkingAreaName", textAlign: TextAlign.center),
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          width: 100,
                          height: 30,
                          child: new Text("Slot Tersisa", textAlign: TextAlign.center),
                        ),
                        new Container(
                          width: 100,
                          height: 30,
                          child: new Text("Jarak", textAlign: TextAlign.center),
                        ),
                        new Container(
                          width: 100,
                          height: 30,
                          child: new Text("Estimasi Waktu", textAlign: TextAlign.center),
                        )
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Container(
                          width: 100,
                          height: 50,
                          child: new Text("$resCapacity", textAlign: TextAlign.center),
                        ),
                        new Container(
                          width: 100,
                          height: 50,
                          child: new Text("$resDistance km", textAlign: TextAlign.center),
                        ),
                        new Container(
                          width: 100,
                          height: 50,
                          child: new Text("$resDuration menit", textAlign: TextAlign.center,),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ) : Container( child: new Text("sedang memuat...", textAlign: TextAlign.center) ),
    ]; 

    return Scaffold(
      appBar: new AppBar(
        title: new Text('Rekomendasi'),
      ),
      body: new Container(
        decoration: new BoxDecoration(color: Colors.white),
        child: new Center(
          child: new ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              Center(
                child: recommendationBody[0],
              )
            ],
          ),
        ),
      ),
    );
  }
}
