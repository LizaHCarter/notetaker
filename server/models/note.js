/* jshint camelcase:false */

'use strict';

var pg = require('../postgres/manager');

function Note(){
}

Note.create = function(user, obj, cb){
  pg.query('select add_note($1, $2, $3, $4)', [user.id, obj.title, obj.body, obj.tags], function(err, results){
    cb(err, results && results.rows ? results.rows[0].add_note : null);
  });
};

Note.query = function(user, query, cb){
  pg.query('select * from query_notes($1, $2, $3)', [user.id, query.limit, query.offset], function(err, results){
    cb(err, results && results.rows ? results.rows : null);
  });
};

module.exports = Note;
