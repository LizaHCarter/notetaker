'use strict';

var Joi  = require('joi'),
Note = require('../../../models/note');

module.exports = {
  description: 'Return a note for a user',
  tags:['notes'],
  validate: {
    params: {
      noteId: Joi.number()
    }
  },
  handler: function(request, reply){
    request.params.userId = request.auth.credentials.id;
    Note.findOne(request.params, function(err, note){
      reply(note).code(err ? 400 : 200);
    });
  }
};
