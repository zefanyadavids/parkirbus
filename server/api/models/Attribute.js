/**
 * Attribute.js
 *
 * @description :: A model definition represents a database table/collection.
 * @docs        :: https://sailsjs.com/docs/concepts/models-and-orm/models
 */

module.exports = {
	tableName: "attribute",
	attributes: {
		attribute_name: {
			type: 'string'
		},
		attribute_weight: {
			type: 'number'
		},
	}
};

