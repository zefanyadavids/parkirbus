/**
 * ParkingArea.js
 *
 * @description :: A model definition represents a database table/collection.
 * @docs        :: https://sailsjs.com/docs/concepts/models-and-orm/models
 */

module.exports = {
	tableName: "parking_area",
	attributes: {
		parking_code: {
			type: 'string'
		},
		parking_name: {
			type: 'string', unique: true
		},
		parking_capacity: {
			type: 'number'
		},
		parking_filled: {
			type: 'number'
		},
		latitude: {
			type: 'string'
		},
		longitude: {
			type: 'string'
		},
		traffic_model: {
			type: 'string',
			defaultsTo: 'default'
		}
	}
};

