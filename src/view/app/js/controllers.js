'use strict';

/* Controllers */

angular.module('dbg.controllers', [])
  .controller('FileListCtrl', [function() {
    console.log("Filelist");
  }])
  .controller('ContentCtrl', [function() {
    console.log("Content");
  }])
  .controller('StateCtrl', [function() {
    console.log("State");
  }])
  .controller('ConsoleCtrl', [function() {
    console.log("Console");
  }]);

