/**
 * RecommendationController
 *
 * @description :: Server-side actions for handling incoming requests.
 * @help        :: See https://sailsjs.com/docs/concepts/actions
 */

const { Controller } = require('sails-ember-rest');

RecommendationController = new Controller({
  recommendationMethod: async function(req, res) {
    var convertedMatrix = [];
    var decisionMatrix = [];
    var minMaxCriteria = [];
    var normalizatedMatrix = [];
    var weightMatrix = req.body.attrWeightList;
    var finalMatrix = [];
    var maxCapacity;
    var minDistance;
    var minDuration;
    var capacityArr = req.body.capacityList;
    var distanceArr = [];
    var durationArr = [];

    //input to duration and distance list
    for(var i=0; i<req.body.total; i++) {
      var distance = req.body[`${i}`].distance;
      distance = distance.replace(" mi", "");
      distance = parseFloat(distance);
      distance = distance/0.62137;
      distance = parseFloat(distance.toFixed(2));

      var duration = req.body[`${i}`].duration;
      if(duration.includes("hours")) {
        duration = duration.replace(" hours", "");
        duration = duration.split(" ");
        duration[0] = parseInt(duration[0])*60;
        duration = parseInt(duration[0])+parseInt(duration[1]);
      } else {
        duration = duration.replace(" mins", "");
        duration = parseInt(duration);
      }

      distanceArr[i] = distance;
      durationArr[i] = duration;
    }

    //dynamic capacity
    var maxCapacity = capacityArr[0];
    var minCapacity = capacityArr[0];
    for(var i=0; i<capacityArr.length; i++) {
      if (capacityArr[i] > maxCapacity)
        maxCapacity = capacityArr[i];
      if (capacityArr[i] < minCapacity)
        minCapacity = capacityArr[i];
    }
    var capacityMaxMin = maxCapacity - minCapacity;
    var capacityRange = (capacityMaxMin/5);

    //dynamic distance
    var maxDistance = distanceArr[0];
    var minDistance = distanceArr[0];
    for(var i=0; i<distanceArr.length; i++) {
      if (distanceArr[i] > maxDistance)
        maxDistance = distanceArr[i];
      if (distanceArr[i] < minDistance)
        minDistance = distanceArr[i];
    }
    var distanceMaxMin = maxDistance - minDistance;
    var distanceRange = (distanceMaxMin/6);

    //dynamic duration
    var maxDuration = durationArr[0];
    var minDuration = durationArr[0];
    for(var i=0; i<durationArr.length; i++) {
      if (durationArr[i] > maxDuration)
        maxDuration = durationArr[i];
      if (durationArr[i] < minDuration)
      minDuration = durationArr[i];
    }
    var durationMaxMin = maxDuration - minDuration;
    var durationRange = (durationMaxMin/6);

    console.log("RANGE SLOT TERSEDIA");
    console.log(capacityArr);
    console.log(minCapacity);
    console.log(parseFloat(minCapacity) + parseFloat(capacityRange));
    console.log(minCapacity + capacityRange*2);
    console.log(minCapacity + capacityRange*3);
    console.log(minCapacity + capacityRange*4);

    console.log("RANGE JARAK");
    console.log(distanceArr);
    console.log(minDistance);
    console.log(parseFloat(minDistance) + parseFloat(distanceRange));
    console.log(minDistance + distanceRange*2);
    console.log(minDistance + distanceRange*3);
    console.log(minDistance + distanceRange*4);

    console.log("RANGE DURASI");
    console.log(durationArr);
    console.log(minDuration);
    console.log(parseFloat(minDuration) + parseFloat(durationRange));
    console.log(minDuration + durationRange*2);
    console.log(minDuration + durationRange*3);
    console.log(minDuration + durationRange*4);

    //make decision matrix
    for(var i=0; i<req.body.total; i++) {

      //preprocessing
      var capacity = req.body[`${i}`].capacity;

      var distance = req.body[`${i}`].distance;
      distance = distance.replace(" mi", "");
      distance = parseFloat(distance);
      distance = distance/0.62137;
      distance = parseFloat(distance.toFixed(2));

      var duration = req.body[`${i}`].duration;
      if(duration.includes("hours")) {
        duration = duration.replace(" hours", "");
        duration = duration.split(" ");
        duration[0] = parseInt(duration[0])*60;
        duration = parseInt(duration[0])+parseInt(duration[1]);
      } else {
        duration = duration.replace(" mins", "");
        duration = parseInt(duration);
      }

      convertedMatrix[i] = [capacity, distance, duration];

      var x = capacityRange;
      if(capacity >= minCapacity && capacity <= minCapacity+(x*1))
        capacity = 0.2;
      else if(capacity > minCapacity+(x*1) && capacity <= minCapacity+(x*2))
        capacity = 0.4;
      else if(capacity > minCapacity+(x*2) && capacity <= minCapacity+(x*3))
        capacity = 0.6;
      else if(capacity > minCapacity+(x*3) && capacity <= minCapacity+(x*4))
        capacity = 0.8;
      else if(capacity > minCapacity+(x*4))
        capacity = 1.0;

      var y = distanceRange;
      if(distance >= minDistance && distance < minDistance+(y*1))
        distance = 0.167;
      else if(distance >= minDistance+(y*1) && distance < minDistance+(y*2))
        distance = 0.334;
      else if(distance >= minDistance+(y*2) && distance < minDistance+(y*3))
        distance = 0.5;
      else if(distance >= minDistance+(y*3) && distance < minDistance+(y*4))
        distance = 0.667;
      else if(distance >= minDistance+(y*4) && distance < minDistance+(y*5))
        distance = 0.833;
      else if(distance > minDistance+(y*5))
        distance = 1.0;

      var z = durationRange
      if(duration >= minDuration && duration <= minDuration+(z*1))
        duration = 0.167;
      else if(duration > minDuration+(z*1) && duration <= minDuration+(z*2))
        duration = 0.334;
      else if(duration > minDuration+(z*2) && duration <= minDuration+(z*3))
        duration = 0.5;
      else if(duration > minDuration+(z*3) && duration <= minDuration+(z*4))
        duration = 0.667;
      else if(duration > minDuration+(z*4) && duration <= minDuration+(z*5))
        duration = 0.833;
      else if(duration > minDuration+(z*5))
        duration = 1.0;

      //get minimum or maximum for each criteria
      if(i==0) {
        maxCapacity = capacity;
        minDistance = distance;
        minDuration = duration;
      } else {
        if(capacity > maxCapacity)
          maxCapacity = capacity;
        if(distance < minDistance)
          minDistance = distance;
        if(duration < minDuration)
          minDuration = duration;
      }

      decisionMatrix[i] = [capacity, distance, duration];
      minMaxCriteria = [maxCapacity, minDistance, minDuration];
    }
    console.log("decision matrix");
    console.log(decisionMatrix[0]);
    console.log(decisionMatrix[1]);
    console.log(decisionMatrix[2]);
    console.log(" ");
   
    //normalization decision matrix
    normalizatedMatrix = decisionMatrix;
    var minMaxPattern = ["max", "min", "min"]
    for(var i=0; i<minMaxPattern.length; i++) {
      for(var j=0; j<decisionMatrix.length; j++) {
        if(minMaxPattern[i]=="max")
          normalizatedMatrix[j][i] = parseFloat((decisionMatrix[j][i]/minMaxCriteria[i]).toFixed(2));
        if(minMaxPattern[i]=="min")
          normalizatedMatrix[j][i] = parseFloat((minMaxCriteria[i]/decisionMatrix[j][i]).toFixed(2));
      }
    }
    console.log("normalized matrix");
    console.log(normalizatedMatrix[0]);
    console.log(normalizatedMatrix[1]);
    console.log(normalizatedMatrix[2]);
    console.log(" ");

    //weightMatrix * normalizatedMatrix
    finalMatrix = normalizatedMatrix;
    for(var i=0; i<normalizatedMatrix.length; i++) {
      for(var j=0; j<normalizatedMatrix[i].length; j++) {
        finalMatrix[j][i] = parseFloat((weightMatrix[i] * finalMatrix[j][i]).toFixed(2));
      }
    }
    console.log("weight matrix");
    console.log(weightMatrix);
    console.log(" ");

    console.log("final matrix");
    console.log(finalMatrix[0]);
    console.log(finalMatrix[1]);
    console.log(finalMatrix[2]);
    console.log(" ");

    // count biggest values to get recommendation
    var alternativeMatrix = [];
    var biggestVal = 0; 
    var idxTag;
    for(var i=0; i<3; i++) {
      var count = (finalMatrix[i][0] + finalMatrix[i][1] + finalMatrix[i][2]).toFixed(2);
      alternativeMatrix[i] = parseFloat(count);
      if(count > biggestVal) {
        biggestVal = count;
        idxTag = i;
      }
    }
    
    console.log("alternative result matrix");
    console.log(alternativeMatrix);
    console.log(" ");

    console.log("biggest val");
    console.log(biggestVal);
    console.log(req.body[idxTag].parkingAreaName)
    console.log(" ");

    var result = {};
    result['parkingAreaName'] = req.body[idxTag].parkingAreaName;
    result['capacity'] = convertedMatrix[idxTag][0];
    result['distance'] = convertedMatrix[idxTag][1];
    result['duration'] = convertedMatrix[idxTag][2];

    return res.status(200).send(result);
  }
});

module.exports = RecommendationController;

