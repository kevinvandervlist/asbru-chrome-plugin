'use strict';

/**
 * Controller for a specific file node.
 * It can be either a directory or a file.
 */

dbg.controller('FileController', 
  function FileController($scope, $location) {
    if($scope.node instanceof SourceFile) {
      $scope.title = $scope.node.filename;
      $scope.class = "filename";
    } else {
      $scope.title = $scope.node.name;
      $scope.class = "foldername";
    }
  }
);
