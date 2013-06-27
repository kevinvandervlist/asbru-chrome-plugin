'use strict';

function router($routeProvider) {
  $routeProvider.when('/fileList', {
    templateUrl: 'partials/fileList.html', 
    controller: 'FileListCtrl'
  });
  $routeProvider.when('/content', {
    templateUrl: 'partials/content.html', 
    controller: 'ContentCtrl'
  });
  $routeProvider.when('/state', {
    templateUrl: 'partials/state.html', 
    controller: 'StateCtrl'
  });
  $routeProvider.when('/console', {
    templateUrl: 'partials/console.html', 
    controller: 'ConsoleCtrl'
  });

  $routeProvider.otherwise({redirectTo: '/fileList'});
}
/* Declare app level module which depends on filters, and services */
var dbg = angular.module('dbg', [
  'dbg.filters', 
  'dbg.services', 
  'dbg.directives', 
  'dbg.controllers'
]).config(['$routeProvider', router]);

