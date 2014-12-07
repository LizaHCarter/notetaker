(function(){
  'use strict';

  angular.module('hapi-auth')
  .factory('Note', ['$http', '$upload', function($http, $upload){

    function create(note, files){
      var noteData = {
        url: '/notes',
        method: 'POST',
        data: note,
        file: files,
        fileFormDataName: 'photos'
      };

      return $upload.upload(noteData);
    }

    function query(limit, offset, filter){
      limit = limit || '';
      offset = offset || '';
      filter = filter || '';

      return $http.get('/notes?limit='+limit+'&offset='+offset+'&filter='+filter);
    }

    return {create:create, query:query};
  }]);
})();
