#= require data/ViewData.coffee
# Services

# Demonstrate how to register services
#In this case it is a simple value service.
angular.module('myApp.services', [])
  .value('version', '0.1');

# Data store
angular.module('data', [],

angular.module('datastore', [], ($provide) ->
  $provide.factory('serviceId', -> @data = new ViewData
