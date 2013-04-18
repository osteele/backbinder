@ProjectsCtrl = ($scope, $http) ->
  $http.get('/projects.json')
    .then (res) ->
      $scope.projects = res.data
  $http.get('/folders.json')
    .then (res) ->
      $scope.folders = res.data
