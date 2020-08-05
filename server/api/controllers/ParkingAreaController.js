/**
 * ParkingAreaController
 *
 * @description :: Server-side actions for handling incoming requests.
 * @help        :: See https://sailsjs.com/docs/concepts/actions
 */

const { Controller } = require('sails-ember-rest');

ParkingAreaController = new Controller({
  createParkingArea : async function(req, res) {
    let newParkingArea = await ParkingArea.create({
      parking_code: req.body.parking_code,
      parking_name: req.body.parking_name,
      parking_capacity: req.body.parking_capacity,
      parking_filled: req.body.parking_filled,
    }).fetch();

    return res.status(200).send(newParkingArea);
  },

  updateParkingCapacity : async function(req, res) {
    let parkingAreaInfo = await ParkingArea.find({
      parking_code : req.param('parking_code')
    });
    var parkingFilled = parkingAreaInfo[0].parking_filled;
    let updatedParkingCapacity;

    if(req.param('parking_entrance')=='true'){
      var newParkingFilled = parseFloat(parkingFilled) + parseFloat(req.param('bus_value'));
      updatedParkingCapacity = await ParkingArea.updateOne({
        parking_code : req.param('parking_code')
      }).set({
        parking_filled : parseFloat(newParkingFilled)
      })
    } else if (req.param('parking_exit')=='true'){
      var newParkingFilled = parseFloat(parkingFilled) - parseFloat(req.param('bus_value'));
      updatedParkingCapacity = await ParkingArea.updateOne({
        parking_code : req.param('parking_code')
      }).set({
        parking_filled : parseFloat(newParkingFilled)
      })
    }
    return res.status(200).send(updatedParkingCapacity);
  },

  getCapacity : async function(req, res) {
    let parkingAreaInfo = await ParkingArea.find({
      parking_code : req.param('parking_code')
    });
    var parkingFilled = parkingAreaInfo[0].parking_filled;
    var parkingCapacity = parkingAreaInfo[0].parking_capacity;

    var result = (parkingCapacity - parkingFilled).toFixed(0);

    return res.status(200).send(result);
  },

  updateTrafficModel : async function(req, res) {
    let updatedTrafficModel = await ParkingArea.updateOne({
      parking_code : req.param('parking_code')
    }).set({
      traffic_model : req.param('traffic_model')
    })

    var result = {};
    result['status'] = 'success';
    result['res'] = updatedTrafficModel;
    return res.status(200).send(result);
  }
});

module.exports = ParkingAreaController;

