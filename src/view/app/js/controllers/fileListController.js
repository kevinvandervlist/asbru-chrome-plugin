'use strict';

/**
 * Controller for the file listing.
 * The main controller for the app. The controller:
 * - retrieves and persists the model via the todoStorage service
 * - exposes the model to the template and provides event handlers
 */
dbg.controller('FileListController', 
  function FileListController($scope, $location, fileManager) {
    $scope.fileListingName = function(node) {
      if(node instanceof SourceFile) {
        return node.filename
      } else {
        return node.name;
      }
    };

    $scope.files = fileManager.getFiles();
  }
);
