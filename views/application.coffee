@ProjectsCtrl = ($scope, $http) ->
  $http.get('/projects.json')
    .then (res) ->
      $scope.projects = res.data
