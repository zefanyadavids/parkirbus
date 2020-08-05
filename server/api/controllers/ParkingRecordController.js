/**
 * ParkingRecordController
 *
 * @description :: Server-side actions for handling incoming requests.
 * @help        :: See https://sailsjs.com/docs/concepts/actions
 */

const { Controller } = require('sails-ember-rest');

ParkingRecordController = new Controller({
  laserRecorded: async function (req, res){
    console.log(">>>>>>>>>>>>>>>>>>>> START <<<<<<<<<<<<<<<<<<<<");
    console.log("ESP8266 terkoneksi ke server");

    let getParkingAreaId = await ParkingArea.find({
      where : {parking_code : req.param('parking_code')},
      select : ['id']
    })

    if(req.param('bus_type')==1) {
      console.log("sensor mendeteksi bus kecil");
    } else if(req.param('bus_type')==2) {
      console.log("sensor mendeteksi bus sedang");
    } else if(req.param('bus_type')==3) {
      console.log("sensor mendeteksi bus besar");
    }

    var record = [];
    let createRecord;
    if(req.param('parking_entrance')=='true'){
      createRecord = await ParkingRecord.create({
        parking_area_id: getParkingAreaId[0].id,
        parking_entrance: true,
        bus_type: req.param('bus_type')
      });
      console.log("bus berjalan melalui pintu masuk");
    } else if(req.param('parking_exit')=='true') {
      createRecord = await ParkingRecord.create({
        parking_area_id: getParkingAreaId[0].id,
        parking_exit: true,
        bus_type: req.param('bus_type')
      });
      console.log("bus berjalan melalui pintu keluar");
    }
    
    var result = {};
    record[0] = createRecord;
    result["parkingRecords"] = record;
    console.log("record bus ditambahkan");
    console.log(result);
    console.log(">>>>>>>>>>>>>>>>>>>>> END <<<<<<<<<<<<<<<<<<<<<");
    res.status(200).send(result);
  },

  countBus: async function (req, res){
    let sql;
    let data;
    var result = [];
    var parking_area_id = req.param("parking_area_id")

    var index = 0;
    for(var i=6; i>=0; i--) {
      sql = `SELECT * FROM "parking_record" WHERE "parking_area_id" = '${parking_area_id}' AND "parking_entrance" = true AND "createdAt" <= now() - INTERVAL '${i} Hours'`;
      data = await ParkingRecord.getDatastore().sendNativeQuery(sql);
      var masuk = data.rowCount;

      sql = `SELECT * FROM "parking_record" WHERE "parking_area_id" = '${parking_area_id}' AND "parking_exit" = true AND "createdAt" <= now() - INTERVAL '${i} Hours'`;
      data = await ParkingRecord.getDatastore().sendNativeQuery(sql);
      var keluar = data.rowCount;

      var counter = masuk - keluar;
      result[index] = counter;
      index++;
    }

    res.status(200).send(result);
  }
});

module.exports = ParkingRecordController;

