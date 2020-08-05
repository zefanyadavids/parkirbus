import 'dart:convert';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//String host = "http://3.227.56.82:1337";
String host = "http://192.168.43.250:1337";

void main() {
  runApp(new MaterialApp(
    title: "My Apps",
    home: new Setting(),
  ));
}

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  bool saved  = false;
  bool saved2  = false;
  bool setting1 = false;
  bool setting2 = false;
  bool open = false;
  String trafficModel = "";
  String parkingAreaVal;
  int slotPriority;
  int distancePriority;
  int durationPriority;
  List parkingArea = ["Abu Bakar Ali", "Ngabean", "Senopati"];
  Map parkingAreaMap = {"Abu Bakar Ali" : "ABA", "Ngabean" : "NGB", "Senopati" : "SEN"};
  List priorityValue = ["Very High", "High", "Medium", "Low", "Very Low"];
  Map priorityValueMap = {"Very High" : 5, "High" : 4, "Medium" : 3, "Low" : 2, "Very Low" : 1};

  void setTrafficModel(String value) {
    setState(() {
      trafficModel = value;
      saved = false;
    });
  }

  saveSettings1() async {
    String trafficModelUri = host + "/api/v1/parkingareas/updateTrafficModel?parking_code=" + parkingAreaVal + "&traffic_model=" + trafficModel; 
    var trafficModelRes = await http.get(trafficModelUri);
    var trafficModelData = jsonDecode(trafficModelRes.body);
    print(trafficModelData);
    if(trafficModelData['status']=="success") {
      setState(() {
        saved = true;
      });
    }
  }

  saveSettings2() async {
    for(var i=0; i<3; i++) {
      Map<String, Object> sendAttribute = {};
      if(i==0) {
        sendAttribute['attribute'] = "capacity";
        sendAttribute['weight'] = slotPriority;
      } else if (i==1) {
        sendAttribute['attribute'] = "distance";
        sendAttribute['weight'] = distancePriority;
      } else if (i==2) {
        sendAttribute['attribute'] = "duration";
        sendAttribute['weight'] = durationPriority;
      }
      var data = jsonEncode(sendAttribute);
      print(data);

      String url = host + "/api/v1/attributes/updateWeight";
      Map<String, String> headers = {"Content-type": "application/json"};
      http.Response attributeRes = await http.post(url, headers: headers, body: data);
      var attributeData = jsonDecode(attributeRes.body);

      setState(() {
        saved2 = true;
      });
      if(attributeData['status']=="success") {
        
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final component = <Widget>[
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: GestureDetector(
              onTap: (){
                setState(() {
                  if(open) {
                    setting1 = false;
                    open = false;
                  } else {
                    setting1 = true;
                    open = true;
                  }
                  setting2 = false;
                });
              },
              child: new Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: new Text("Model Lalu Lintas"),
              )
            ),
          ),
          setting1 ? new Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child : Column(
              children: <Widget>[
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      height: 10,
                    ),
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
                        setState(() {
                          parkingAreaVal = value;
                          saved = false;
                        });
                      },
                    ),
                    new RadioListTile(
                      value: "default",
                      title: new Text("Default"),
                      groupValue: trafficModel,
                      onChanged: (String value) {
                        setTrafficModel(value);
                      },
                      activeColor: Colors.blue,
                      subtitle: new Text("Mode lalu lintas berdasarkan perkiraan yang tepat dan langsung"),
                    ),
                    new RadioListTile(
                      value: "pessimistic",
                      title: new Text("Pesimistik"),
                      groupValue: trafficModel,
                      onChanged: (String value) {
                        setTrafficModel(value);
                      },
                      activeColor: Colors.blue,
                      subtitle: new Text("Mode lalu lintas yang memungkinkan melihat situasi terburuk, sehingga durasi yang dikembalikan lebih lama dari sebenarnya"),
                    ),
                    new RadioListTile(
                      value: "optimistic",
                      title: new Text("Optimistik"),
                      groupValue: trafficModel,
                      onChanged: (String value) {
                        setTrafficModel(value);
                      },
                      activeColor: Colors.blue,
                      subtitle: new Text("Mode lalu lintas yang memungkinkan melihat situasi terbaik, sehingga durasi yang dikembalikan lebih cepat dari sebenarnya"),
                    ),
                  ]
                ),
                saved ? new Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: new Container(
                    height : 30,
                    decoration : BoxDecoration (color: Colors.blue[100]),
                    child: new Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 130),
                      child: Text("data tersimpan"),
                    )
                  )
                ) : new Container(),
                new Padding(
                  padding: EdgeInsets.all(10), 
                  child: new RaisedButton(
                    padding: const EdgeInsets.all(10),
                    textColor: Colors.white,
                    color: Colors.teal,
                    onPressed: saveSettings1,
                    child: new Text("Simpan"),
                  ),
                ),
                new Padding(padding: EdgeInsets.all(10)),
              ],
            )
          ) : Container( height: 20,),
        ]
      ),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: GestureDetector(
              onTap: (){
                setState(() {
                  if(open) {
                    setting2 = false;
                    open = false;
                  } else {
                    setting2 = true;
                    open = true;
                  }
                  setting1 = false;
                });
              },
              child: new Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: new Text("Bobot Atribut"),
              )
            ),
          ),
          setting2 ? new Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: <Widget>[
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                    ),
                    Text("Slot Tersisa", textAlign: TextAlign.left,),
                    DropdownButton(
                      hint: Text("Pilih Bobot"),
                      value: slotPriority,
                      items: priorityValue.map((value) {
                        return DropdownMenuItem(
                          child: Text(value),
                          value: priorityValueMap["$value"],
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          slotPriority = value;
                          saved = false;
                        });
                      },
                    ),
                    Text("Jarak", textAlign: TextAlign.left,),
                    DropdownButton(
                      hint: Text("Pilih Bobot"),
                      value: distancePriority,
                      items: priorityValue.map((value) {
                        return DropdownMenuItem(
                          child: Text(value),
                          value: priorityValueMap["$value"],
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          distancePriority = value;
                          saved = false;
                        });
                      },
                    ),
                    Text("Durasi", textAlign: TextAlign.left,),
                    DropdownButton(
                      hint: Text("Pilih Bobot"),
                      value: durationPriority,
                      items: priorityValue.map((value) {
                        return DropdownMenuItem(
                          child: Text(value),
                          value: priorityValueMap["$value"],
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          durationPriority = value;
                          saved = false;
                        });
                      },
                    ),
                    new Container(),
                  ]
                ),
                saved2 ? new Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: new Container(
                    height : 30,
                    decoration : BoxDecoration (color: Colors.blue[100]),
                    child: new Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 130),
                      child: Text("data tersimpan"),
                    )
                  )
                ) : new Container(),
                new Padding(
                  padding: EdgeInsets.all(10), 
                  child: new RaisedButton(
                    padding: const EdgeInsets.all(10),
                    textColor: Colors.white,
                    color: Colors.teal,
                    onPressed: saveSettings2,
                    child: new Text("Simpan"),
                  ),
                )
              ]
            ),
          ) : Container( height: 20,),
        ],
      ),
         
    ];

    return Scaffold(
      appBar: AppBar(
        title: new Text("Pengaturan"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
        child: Column(children: <Widget>[
          component[0],
          component[1],
        ],)
      )
    );
  }
}