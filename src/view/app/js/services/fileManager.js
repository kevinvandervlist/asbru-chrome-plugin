'use strict';

/**
 * 
 */
dbg.factory('fileManager', ["dataProxy", function(dataProxy) {
  var cnt = 0;
  var files = new FileManager

  // It is usefull to cache files on the frontend.
  dataProxy.getFiles(function(message) {
    var sf = new SourceFile(message);
    files.saveFile(sf.origin, sf.id, sf);
  });

  function hierarchy(files) {
    var ret = [];
    // For each origin
    angular.forEach(files.getOrigins(), function(origin) {
      if(ret[origin] === undefined) {
        ret[origin] = [];
      }
      // Store the hierarchy
      var allPaths = [];
      // Define a recursive approach for an associative array.
      var f = function(target, nodename, cur, file) {
        var _nodename;
        if (target[nodename] === undefined) {
          target[nodename] = [];
        }
        if (cur.length === 0) {
          target[nodename].push(file);
        } else {
          _nodename = cur.shift();
          target[nodename] = f(target[nodename], _nodename, cur, file);
        }
        return target;
      };
      // Generate an associative array recursively
      angular.forEach(files.getAllFilesByOrigin(origin), function(file) {
        allPaths = f(allPaths, "/", file.getPath(), file);
      });
      ret[origin] = allPaths;
    });


    var treeify = function(tree, obj) {
      for (var key in tree) {
        var value = tree[key];

        if (value instanceof Array) {
          var child = {name: key, nodes: []};
          obj.nodes.push(treeify(value, child));
        } else {
          obj.nodes.push(value);
        }

      };
      return obj;
    }

    console.log(ret);
    var obj = {name: "TOP", nodes: []};
    ret = treeify(ret, obj);

    console.log(ret);
    return ret;
  }

	return {
		getFiles: function () {
			return hierarchy(files);
		},
	};
}]);


// function hierarchy(files) {
//     var ret = [];
//     var obj = {value: "TOP", children: []}
//     // For each origin
//     angular.forEach(files.getOrigins(), function(origin) {
//       if(ret[origin] === undefined) {
//         ret[origin] = [];
//       }
//       // Store the hierarchy
//       var allPaths = [];
//       // Define a recursive approach for an associative array.
//       var f = function(target, nodename, cur, file) {
//         var _nodename;
//         if (target[nodename] === undefined) {
//           target[nodename] = [];
//         }
//         if (cur.length === 0) {
//           target[nodename].push(file);
//         } else {
//           _nodename = cur.shift();
//           target[nodename] = f(target[nodename], _nodename, cur, file);
//         }
//         return target;
//       };
//       // Generate an associative array recursively
//       angular.forEach(files.getAllFilesByOrigin(origin), function(file) {
//         allPaths = f(allPaths, "/", file.getPath(), file);
//       });
//       ret[origin].push(allPaths);
//     });
