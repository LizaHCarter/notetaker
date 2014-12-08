/* jshint camelcase:false */

'use strict';

var path    = require('path'),
    AWS     = require('aws-sdk'),
    pg      = require('../postgres/manager'),
    async   = require('async');

function Note(obj){
}

Note.create = function(obj, cb){
  // console.log(obj);
  // console.log(obj.photos[0].hapi.filename);

  obj.tags = Note.sanitizeTags(obj.tags || '');

  pg.query('select add_note($1, $2, $3, $4)', [obj.userId, obj.title, obj.body, obj.tags], function(err, results){
    if(err || !(results && results.rows)){return cb(err || 'Note failed to add correctly', null);}
      // console.log(results.rows[0].add_note);
      var noteId = results.rows[0].add_note;

      if(!obj.photos){return cb(err, noteId);}

        if(!Array.isArray(obj.photos)){obj.photos = [obj.photos];}

          var photos = obj.photos.map(function(obj, i){
            return {noteId:noteId, photoId:i, stream:obj};
          });

          async.map(photos, uploadPhotoToS3, function(err, photoUrls){
            var urlString = photoUrls.join(',');
            pg.query('SELECT add_photos($1,$2)', [urlString, noteId], function(err, results){
              cb(err, noteId);
            });
          });
        });

      };

      Note.sanitizeTags = function(s){
        var tags = s.split(',');
        tags.forEach(function(t, i){
          tags[i] = t.trim().toLowerCase();
        });
        return tags.join(',');
      };

      Note.query = function(query, cb){
        console.log(query);
        query.limit = query.limit || 10;
        query.offset = query.offset || 0;
        query.filter = query.filter || '';

        var queryString = 'SELECT * FROM query_notes($1,$2,$3)',
        queryParams = [query.userId, query.limit, query.offset];

        pg.query(queryString, queryParams, function(err, results){
          cb(err, results.rows);
        });
      };

      Note.findOne = function(params, cb){
        var queryString = 'SELECT * FROM find_note($1,$2)',
        queryParams = [params.userId, params.noteId];

        pg.query(queryString, queryParams, function(err, results){
          cb(err, results.rows);
        });
      };

      module.exports = Note;

      // HELPER FUNCTIONS //
      function uploadPhotoToS3(obj, done){
        var s3     = new AWS.S3(),
        ext    = path.extname(obj.stream.hapi.filename),
        file   = obj.noteId + '_' + obj.photoId + ext,
        url    = 'https://s3.amazonaws.com/' + process.env.AWS_BUCKET + '/' + file,
        params = {Bucket: process.env.AWS_BUCKET, Key: file, Body: obj.stream._data, ACL: 'public-read'};
        s3.putObject(params, function(err){
          console.log('S3 Error:', err);
          done(err, url);
        });
      }
