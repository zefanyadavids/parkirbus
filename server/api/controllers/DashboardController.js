/**
 * DashboardController
 *
 * @description :: Server-side actions for handling incoming requests.
 * @help        :: See https://sailsjs.com/docs/concepts/actions
 */

const { Controller } = require('sails-ember-rest');

DashboardController = new Controller({
  convertDistance: async function(req, res){
    var distance = req.param('distance');
    distance = distance.replace(" mi", "");
    distance = parseFloat(distance);
    distance = distance/0.62137;
    distance = parseFloat(distance.toFixed(2));
    
    var result = [distance]
    return res.status(200).send(result);
  },

  convertDuration: async function(req, res){
    var duration = req.param('duration');
    if(duration.includes("hours")) {
      duration = duration.replace(" hours", "");
      duration = duration.split(" ");
      duration[0] = parseInt(duration[0])*60;
      duration = parseInt(duration[0])+parseInt(duration[1]);
    } else {
      duration = duration.replace(" mins", "");
      duration = parseInt(duration);
    }

    var result = [duration]
    return res.status(200).send(result);
  },

  getTimeForChart: async function(req, res) {
    var time = new Date();
    var hours = time.getHours();
    var minutes = time.getMinutes();
    var result = [hours-6, hours-5, hours-4, hours-3, hours-2, hours-1, hours];

    for(var i=0; i<result.length; i++){
      if(result[i]<0){
        result[i]=result[i]+24;
      }
      if(result[i]<10) {
        result[i]=`0${result[i]}`
      }
      result[i] = `${result[i]}.${minutes}`
    }

    return res.status(200).send(result);
  }
});

module.exports = DashboardController;