'use strict';

/**
 * Controller for the file listing.
 */
dbg.controller('FileListController', 
  function FileListController($scope, $location, fileManager) {
    $scope.files = fileManager.getFiles();
  }
);
