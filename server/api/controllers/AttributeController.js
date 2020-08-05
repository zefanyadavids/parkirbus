/**
 * AttributeController
 *
 * @description :: Server-side actions for handling incoming requests.
 * @help        :: See https://sailsjs.com/docs/concepts/actions
 */

const { Controller } = require('sails-ember-rest');

AttributeController = new Controller({
  updateWeight : async function(req, res) {
    var weight;
    if(req.body.weight==1)
      weight = 0.2;
    else if(req.body.weight==2)
      weight = 0.4;
    else if(req.body.weight==3)
      weight = 0.6;
    else if(req.body.weight==4)
      weight = 0.8;
    else if(req.body.weight==5)
      weight = 1.0;

    let newWeight = await Attribute.updateOne({ attribute_name: req.body.attribute})
    .set({
      attribute_weight: weight
    });

    return res.status(200).send(newWeight);
  },
});

module.exports = AttributeController;



