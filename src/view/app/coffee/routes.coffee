# This only contains route information.
routes = ($routeProvider) ->
  $routeProvider.when "/fileList",
    templateUrl: "partials/fileList.html"
    controller: FileListController

  $routeProvider.when "/state",
    templateUrl: "partials/state.html"
    controller: StateController

  $routeProvider.when "/content",
    templateUrl: "partials/content.html"
    controller: ContentController

  $routeProvider.when "/console",
    templateUrl: "partials/console.html"
    controller: ConsoleController

  $routeProvider.otherwise
    redirectTo: "/fileList"
