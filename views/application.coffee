@ProjectsCtrl = ($scope, $http) ->
  projects = []
  folders = []

  $http.get('/projects.json')
    .then (res) ->
      $scope.projects = res.data
      projects = res.data
      merge()

  $http.get('/folders.json')
    .then (res) ->
      folders = res.data
      merge()

  merge = ->
    project_names = (project.name for project in projects)
    $scope.unpublished = (folder for folder in folders when folder.name not in project_names)
