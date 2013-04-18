@ProjectsCtrl = ($scope, $http) ->
  projects = []
  folders = []

  $http.get('/user/info.json')
    .then (res) ->
      userInfo = res.data
      dataRef = new Firebase('https://backbinder.firebaseio.com');
      dataRef.auth userInfo.token, (error, result) ->
        console.log("Login Failed!", error) if error
        return if error
        # console.log('Authenticated successfully with payload:', result.auth)
        # console.log('Auth expires at:', new Date(result.expires * 1000))
      foldersRef = dataRef.child("users/#{userInfo.id}/folders")
      foldersRef.on 'value', (nameSnapshot) ->
        folders = nameSnapshot.val()
        $scope.$apply merge

  reload = ->
    $http.get('/projects.json')
      .then (res) ->
        $scope.projects = res.data
        projects = res.data
        merge()

    $http.get('/folders.json')

  reload()

  $scope.publish_folder = (folder) ->
    folder.publishing = true
    $http.post('/folder/publish', {name: folder.name})
      .success(reload)
      .error(-> folder.publishing = false; folder.error = "Error")

  merge = ->
    project_names = (project.name for project in projects)
    $scope.unpublished = (folder for folder in folders when folder.name not in project_names)
