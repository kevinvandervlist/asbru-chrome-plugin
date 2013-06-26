#= require controllers.coffee
#= require directives.coffee
#= require filters.coffee
#= require routes.coffee
#= require services.coffee

angular.module "myApp", [
    "myApp.filters",
    "myApp.services",
    "myApp.directives"
  ]
  .config ["$routeProvider", routes]

angular.bootstrap document, ["myApp"]

