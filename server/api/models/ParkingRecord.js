/**
 * ParkingRecord.js
 *
 * @description :: A model definition represents a database table/collection.
 * @docs        :: https://sailsjs.com/docs/concepts/models-and-orm/models
 */

module.exports = {
	tableName: "parking_record",
	attributes: {
		parking_area_id: {
			type: 'number'
		},
		parking_entrance: {
			type: 'boolean',
			defaultsTo: false
		},
		parking_exit: {
			type: 'boolean',
			defaultsTo: false
		},
		bus_type: {
			type: 'number'
		},
	}
};

