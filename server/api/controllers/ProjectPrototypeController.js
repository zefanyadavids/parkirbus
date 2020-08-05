/**
 * ProjectPrototypeController
 *
 * @description :: Server-side actions for handling incoming requests.
 * @help        :: See https://sailsjs.com/docs/concepts/actions
 */

const { Controller } = require('sails-ember-rest');

ProjectPrototypeController = new Controller({
  createPrototype : async function(req, res) {
    let newPrototype = await ProjectPrototype.create({
      prototype: "Abu Bakar Ali",
    }).fetch();

    return res.status(200).send(newPrototype);
  },

  switchPrototype : async function(req, res) {
    let updatedPrototype = await ProjectPrototype.updateOne({ id: 2 })
    .set({
      prototype: req.param("newPrototype")
    });

    return res.status(200).send(updatedPrototype);
  },

  getCurrentPrototype : async function(req, res) {
    let currentPrototype = await ProjectPrototype.find({ id: 2 })

    return res.status(200).send(currentPrototype[0].prototype);
  }
});
``
module.exports = ProjectPrototypeController;



