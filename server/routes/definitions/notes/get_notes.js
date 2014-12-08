'use strict';

var Joi  = require('joi'),
Note = require('../../../models/note');

module.exports = {
  description: 'Return requested notes for user',
  tags:['notes'],
  validate: {
    query: {
      limit: Joi.number(),
      offset: Joi.number(),
      filter: [Joi.string(), Joi.any().allow('')]
    }
  },
  handler: function(request, reply){
    request.query.userId = request.auth.credentials.id;
    Note.query(request.query, function(err, notes){
      reply(notes).code(err ? 400 : 200);
    });
  }
};
