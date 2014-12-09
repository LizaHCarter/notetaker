(function(){
  'use strict';

  angular.module('hapi-auth')
    .controller('NotesShowCtrl', ['$scope', '$state', 'Note', function($scope, $state, Note){
      $scope.moment = moment;
      Note.findOne($state.params.noteId).then(function(res){
        $scope.note = res.data;
      });
    }]);
})();
