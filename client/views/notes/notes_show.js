(function(){
  'use strict';

  angular.module('hapi-auth')
    .controller('NotesShowCtrl', ['$scope', '$state', 'Note', function($scope, $state, Note){
      Note.findOne($state.params.noteId).then(function(res){
        $scope.note = res.data;
      });

      $scope.backToIndex = function(){
        $state.go('notes.index');
      };

    }]);
})();
