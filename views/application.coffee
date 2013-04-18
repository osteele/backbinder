@ProjectsCtrl = ($scope, $http) ->
  projects = []
  folders = []

  reload = ->
    $http.get('/projects.json')
      .then (res) ->
        $scope.projects = res.data
        projects = res.data
        merge()

    $http.get('/folders.json')
      .then (res) ->
        folders = res.data
        merge()

  reload()

  $scope.publish_folder = (folder) ->
    folder.publishing = true
    $http.post('/folder/publish', {name: folder.name})
      .success(reload)
      .error(-> folder.publishing = false; folder.error = "Error")

  merge = ->
    project_names = (project.name for project in projects)
    $scope.unpublished = (folder for folder in folders when folder.name not in project_names)
