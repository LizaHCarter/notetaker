(function(){
  'use strict';
  angular.module('hapi-auth')
    .controller('NotesIndexCtrl', ['$scope', '$state', 'Note', function($scope, $state, Note){
      $scope.notes = [];

      getNotes();

      $scope.create = function(note){
        Note.create(note, $scope.photos).then(function(res){
          $scope.photos = undefined;
          $scope.note = {};
          getNotes();
        }, function(res){
          console.log('error adding note', res);
        });
      };
      $scope.viewNote = function(noteId){
        console.log(noteId);
        $state.go('notes.show', {noteId:noteId});
      };

      function getNotes(limit, offset, filter){
        Note.query(limit, offset, filter).then(function(res){
          $scope.notes = res.data;
        });
      }
    }]);

})();
