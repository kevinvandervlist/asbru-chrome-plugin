'use strict';

/**
 * 
 */
dbg.factory('dataProxy', ["messager", function(messager) {
  return {
		getFiles: function (cb) {
      messager.sendMessage("js.ListFiles", {}, cb);
		},
	};
}]);
