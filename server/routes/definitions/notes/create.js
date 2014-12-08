'use strict';

var Joi  = require('joi'),
Note = require('../../../models/note');

module.exports = {
  description: 'Add a new note',
  tags:['notes'],
  payload: {
    maxBytes: 300000000,
    output:'stream',
    parse: true
  },
  validate: {
    payload: {
      title: Joi.string(),
      body: Joi.string(),
      tags: Joi.string(),
      photos: [Joi.array(), Joi.object(), Joi.any().allow(undefined)]
    }
  },
  handler: function(request, reply){
    request.payload.userId = request.auth.credentials.id;
    Note.create(request.payload, function(err, noteId){
      reply({noteId:noteId}).code(err ? 418 : 200);
    });
  }
};
