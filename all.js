(function() {
  var AsyncVariable, BreakPoint, BreakPointMarkup, BreakpointManager, CallStack, CallstackVariable, CircularBuffer, Console, DataStore, FileManager, FileManagerMarkup, GuiBase, Logger, Messaging, Origin, OriginDataManager, ScopeVariable, ScopeVariableStack, SingletonDispatcher, SourceFile, SourceFileMarkup, StateInformation, StateInformationManager, StateInformationMarkup, StateTree, String, TreeNode, ViewData, comm_JS, comm_debugger, setupGuiElements, _ref, _ref1, _ref2,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  SingletonDispatcher = (function() {
    var Dispatcher, instance;

    function SingletonDispatcher() {}

    instance = null;

    Dispatcher = (function() {
      function Dispatcher() {
        this.invokeCallbacks = __bind(this.invokeCallbacks, this);        this.callbackArray = [];
      }

      Dispatcher.prototype.addCallback = function(cb) {
        return this.callbackArray.push(cb);
      };

      Dispatcher.prototype.removeCallback = function(cb) {
        var remove;

        remove = function(array, object) {
          var element, i, _i, _len, _results;

          i = 0;
          _results = [];
          for (_i = 0, _len = array.length; _i < _len; _i++) {
            element = array[_i];
            if (element === object) {
              array.splice(i, 1)[0];
            }
            _results.push(i++);
          }
          return _results;
        };
        return remove(this.callbackArray, cb);
      };

      Dispatcher.prototype.invokeCallbacks = function() {
        var cb, _i, _len, _ref;

        _ref = this.callbackArray;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          cb = _ref[_i];
          cb();
        }
        return void 0;
      };

      Dispatcher.prototype.setTimeoutCallback = function(ms) {
        return window.setTimeout(this.invokeCallbacks, ms);
      };

      Dispatcher.prototype.setIntervalCallback = function(ms) {
        return setInterval(this.invokeCallbacks, ms);
      };

      Dispatcher.prototype.setTimeout = function(cb, ms) {
        return setTimeout(cb, ms);
      };

      Dispatcher.prototype.setInterval = function(cb, ms) {
        return setInterval(cb, ms);
      };

      return Dispatcher;

    })();

    SingletonDispatcher.get = function() {
      return instance != null ? instance : instance = new Dispatcher;
    };

    return SingletonDispatcher;

  }).call(this);

  GuiBase = (function() {
    function GuiBase() {
      this.vdata = new ViewData;
      this.dispatcher = SingletonDispatcher.get();
    }

    GuiBase.prototype.click = function(element, callback) {
      return element.effect("highlight", {}, 100, callback);
    };

    return GuiBase;

  })();

  BreakPointMarkup = (function(_super) {
    __extends(BreakPointMarkup, _super);

    function BreakPointMarkup(id, lineNumber) {
      this.id = id;
      this.lineNumber = lineNumber;
      BreakPointMarkup.__super__.constructor.call(this);
    }

    BreakPointMarkup.prototype.setBreakpoint = function() {
      var line;

      line = $(".file-" + this.id + "-line-" + this.lineNumber);
      return line.addClass("selected-item");
    };

    BreakPointMarkup.prototype.removeBreakpoint = function() {
      var line;

      line = $(".file-" + this.id + "-line-" + this.lineNumber);
      return line.removeClass("selected-item");
    };

    return BreakPointMarkup;

  })(GuiBase);

  Origin = (function() {
    function Origin() {}

    Origin.createOriginFromUri = function(uri) {
      var origin, splice, split;

      origin = null;
      switch (uri.split(':')[0]) {
        case "file":
          origin = "file";
          break;
        case "http":
        case "https":
          split = uri.split('/');
          splice = split.splice(0, 3);
          origin = splice.join("/");
          break;
        default:
          throw "origin for " + uri + " is not defined";
      }
      return origin;
    };

    return Origin;

  })();

  BreakPoint = (function() {
    function BreakPoint(message) {
      var parentFile;

      this.breakpointId = message.breakpointId;
      this.columnNumber = message.columnNumber;
      this.lineNumber = message.lineNumber;
      this.scriptId = message.scriptId;
      this.origin = message.origin;
      this.markup = new BreakPointMarkup(this.scriptId, this.lineNumber);
      this.markup.setBreakpoint();
      parentFile = window.hoocsd.data.files.getFile(this.scriptId, this.origin);
      parentFile.addBreakpoint(this.lineNumber, this);
      this.saveBreakpoint();
    }

    BreakPoint.prototype.saveBreakpoint = function() {
      return window.hoocsd.data.breakpoints.saveBreakpoint(this.origin, this.getIdentifier(), this);
    };

    BreakPoint.prototype.remove = function(messaging) {
      window.hoocsd.data.breakpoints.removeBreakpoint(this.origin, this.getIdentifier());
      this.markup.removeBreakpoint();
      return messaging.sendMessage({
        type: "js.removeBreakpoint",
        breakpointId: this.breakpointId,
        origin: this.origin
      });
    };

    BreakPoint.prototype.getIdentifier = function() {
      return this.breakpointId;
    };

    BreakPoint.prototype.setBreakpoint = function() {
      return this.markup.setBreakpoint();
    };

    return BreakPoint;

  })();

  FileManagerMarkup = (function(_super) {
    __extends(FileManagerMarkup, _super);

    function FileManagerMarkup(fileManager) {
      this.fileManager = fileManager;
      this.showFile = __bind(this.showFile, this);
      this._update = __bind(this._update, this);
      FileManagerMarkup.__super__.constructor.call(this);
    }

    FileManagerMarkup.prototype.updateFileListing = function() {
      return this._update();
    };

    FileManagerMarkup.prototype._update = function() {
      var allPaths, f, file, fileList, fileNodeLine, fileNodeTree, flci, origin, originList, title, _i, _j, _len, _len1, _ref, _ref1, _results,
        _this = this;

      flci = $("" + (this.vdata.filelistContentId()));
      flci.empty();
      originList = $("<ul />");
      flci.append(originList);
      _ref = this.fileManager.getOrigins();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        origin = _ref[_i];
        title = $("<li><h4>" + origin + "</h4></li>");
        fileList = $("<ul />");
        originList.append(title);
        originList.append(fileList);
        allPaths = [];
        f = function(target, nodename, cur, file) {
          var _nodename;

          if (target[nodename] == null) {
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
        _ref1 = this.fileManager.getAllFilesByOrigin(origin);
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          file = _ref1[_j];
          allPaths = f(allPaths, "/", file.getPath(), file);
        }
        fileNodeLine = function(file, parent) {
          var element;

          element = file.getSourceFileLine();
          element.addClass("filename");
          parent.append(element);
          f = function(element, file) {
            var callback;

            callback = function() {
              return _this.showFile(file);
            };
            return element.click(function() {
              return _this.click(element, callback);
            });
          };
          return f(element, file);
        };
        fileNodeTree = function(array, parent) {
          var child, closure, key, value, _results1;

          _results1 = [];
          for (key in array) {
            value = array[key];
            if (value instanceof Array) {
              title = $("<li>" + key + "</li>").addClass("foldername");
              child = $("<ul />");
              parent.append(title);
              parent.append(child);
              if (key !== "/") {
                child.hide();
              }
              closure = function(title, child) {
                return title.click(function() {
                  var cb;

                  cb = function() {
                    return child.toggle();
                  };
                  return _this.click(title, cb);
                });
              };
              closure(title, child);
              _results1.push(fileNodeTree(value, child));
            } else {
              _results1.push(fileNodeLine(value, parent));
            }
          }
          return _results1;
        };
        _results.push(fileNodeTree(allPaths, fileList));
      }
      return _results;
    };

    FileManagerMarkup.prototype.showFile = function(file) {
      var bp, el, k, _ref;

      el = $(this.vdata.mainContentId());
      el.empty();
      el.append(file.getFormattedCode());
      _ref = file.getBreakpoints();
      for (k in _ref) {
        bp = _ref[k];
        bp.setBreakpoint();
      }
      return void 0;
    };

    return FileManagerMarkup;

  })(GuiBase);

  DataStore = (function() {
    function DataStore() {
      this.store = [];
    }

    DataStore.prototype.put = function(key, value) {
      return this.store[key] = value;
    };

    DataStore.prototype.get = function(key) {
      return this.getByKey(key);
    };

    DataStore.prototype.getByKey = function(key) {
      if (this.keyExists(key)) {
        return this.store[key];
      }
      return null;
    };

    DataStore.prototype.getAllValues = function() {
      var key, ret, value, _ref;

      ret = [];
      _ref = this.store;
      for (key in _ref) {
        value = _ref[key];
        ret.push(value);
      }
      return ret;
    };

    DataStore.prototype.getByValue = function(value) {
      var key, val, _ref;

      _ref = this.store;
      for (key in _ref) {
        val = _ref[key];
        if (value === val) {
          return value;
        }
      }
      return null;
    };

    DataStore.prototype.keyExists = function(key) {
      return this.store[key] != null;
    };

    DataStore.prototype.valueExists = function(value) {
      return this.getByValue(value !== null);
    };

    DataStore.prototype.remove = function(key) {
      return delete this.store[key];
    };

    return DataStore;

  })();

  OriginDataManager = (function() {
    function OriginDataManager() {
      this.data = [];
    }

    OriginDataManager.prototype.put = function(origin, key, value) {
      if (this.data[origin] == null) {
        this.data[origin] = new DataStore;
      }
      return this.data[origin].put(key, value);
    };

    OriginDataManager.prototype.get = function(key, origin) {
      var datastore, v, _ref;

      if (origin == null) {
        origin = null;
      }
      if (origin != null) {
        return this.data[origin].get(key);
      } else {
        _ref = this.data;
        for (origin in _ref) {
          datastore = _ref[origin];
          v = datastore.get(key);
          if (v != null) {
            return v;
          }
        }
      }
      return void 0;
    };

    OriginDataManager.prototype.remove = function(key, origin) {
      var datastore, _ref;

      if (origin == null) {
        origin = null;
      }
      if (origin != null) {
        this.data[origin].remove(key);
      } else {
        _ref = this.data;
        for (origin in _ref) {
          datastore = _ref[origin];
          datastore.remove(key);
          return void 0;
        }
      }
      return void 0;
    };

    OriginDataManager.prototype.getAllDataByOrigin = function(origin) {
      return this.data[origin].getAllValues();
    };

    OriginDataManager.prototype.getOrigins = function() {
      var origin, ret, store, _ref;

      ret = [];
      _ref = this.data;
      for (origin in _ref) {
        store = _ref[origin];
        ret.push(origin);
      }
      return ret;
    };

    return OriginDataManager;

  })();

  FileManager = (function(_super) {
    __extends(FileManager, _super);

    function FileManager() {
      FileManager.__super__.constructor.call(this);
      this.markup = new FileManagerMarkup(this);
    }

    FileManager.prototype.saveFile = function(origin, key, sourceFile) {
      this.put(origin, key, sourceFile);
      return this.markup.updateFileListing();
    };

    FileManager.prototype.getFile = function(key, origin) {
      if (origin == null) {
        origin = null;
      }
      return this.get(key, origin);
    };

    FileManager.prototype.getAllFilesByOrigin = function(origin) {
      return this.getAllDataByOrigin(origin);
    };

    FileManager.prototype.showBreakpointAndSourceFile = function(file, id, line) {
      this.markup.showFile(file);
      return $(".file-" + id + "-line-" + line).addClass("active-breakpoint");
    };

    return FileManager;

  })(OriginDataManager);

  BreakpointManager = (function(_super) {
    __extends(BreakpointManager, _super);

    function BreakpointManager() {
      _ref = BreakpointManager.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    BreakpointManager.prototype.saveBreakpoint = function(origin, key, breakpoint) {
      return this.put(origin, key, breakpoint);
    };

    BreakpointManager.prototype.removeBreakpoint = function(origin, key) {
      return this.remove(key, origin);
    };

    BreakpointManager.prototype.getFile = function(key, origin) {
      if (origin == null) {
        origin = null;
      }
      return this.get(key, origin);
    };

    BreakpointManager.prototype.getAllBreakpointByOrigin = function(origin) {
      return this.getAllDataByOrigin(origin);
    };

    return BreakpointManager;

  })(OriginDataManager);

  window.hoocsd = {};

  ViewData = (function() {
    function ViewData() {}

    ViewData.prototype.init = function() {
      return window.hoocsd = this.defaultGlobalState();
    };

    ViewData.prototype.defaultGlobalState = function() {
      var dataStores, ret;

      dataStores = {
        files: new FileManager,
        breakpoints: new BreakpointManager
      };
      return ret = {
        data: dataStores,
        logger: null,
        messaging: null,
        cli: null,
        omniscient: "omniscient"
      };
    };

    ViewData.prototype.filelistContentId = function() {
      return "#filelist-content";
    };

    ViewData.prototype.mainContentId = function() {
      return "#content-window";
    };

    ViewData.prototype.stateInfoId = function() {
      return "#state-information-panel";
    };

    return ViewData;

  })();

  SourceFileMarkup = (function(_super) {
    __extends(SourceFileMarkup, _super);

    function SourceFileMarkup(filename, id, uri, sourceFile) {
      this.filename = filename;
      this.id = id;
      this.uri = uri;
      this.sourceFile = sourceFile;
      this.formatted_code = null;
      this.element = $("<li>" + this.filename + "</li>", {
        id: this.id
      });
      SourceFileMarkup.__super__.constructor.call(this);
    }

    SourceFileMarkup.prototype.getFormattedCode = function() {
      var breakpointCallback, cnt, code, f, line, linediv, loc, _i, _len, _ref1,
        _this = this;

      code = this.sourceFile.getRawSourceCode();
      breakpointCallback = this.sourceFile.getBreakpointCallback();
      this.formatted_code = $("<ol></ol>");
      cnt = this.sourceFile.getOffset();
      _ref1 = code.split("\n");
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        line = _ref1[_i];
        linediv = $("<li></li>");
        loc = $("<pre></pre>");
        loc[0].innerText = line;
        linediv.addClass("file-" + this.id + "-line-" + cnt);
        linediv.append(loc);
        this.formatted_code.append(linediv);
        f = function(element, line) {
          var callback;

          callback = function() {
            return breakpointCallback(line, _this.id, _this.uri);
          };
          return linediv.click(function() {
            return _this.click(element, callback);
          });
        };
        f(linediv, cnt);
        cnt++;
      }
      return this.formatted_code;
    };

    SourceFileMarkup.prototype.getSourceFileLine = function() {
      return this.element;
    };

    return SourceFileMarkup;

  })(GuiBase);

  String = (function() {
    function String(str) {
      this.str = str;
    }

    String.prototype.substringOf = function(other) {
      return (new RegExp(this.str)).test(other);
    };

    return String;

  })();

  SourceFile = (function() {
    function SourceFile(fileMessage) {
      this._toggleBreakPoint = __bind(this._toggleBreakPoint, this);      this.code = fileMessage.code;
      this.id = fileMessage.scriptId;
      this.uri = fileMessage.url;
      this.offset = fileMessage.offset;
      this.origin = fileMessage.origin;
      this.filename = this.uri.substr(this.uri.lastIndexOf("/") + 1);
      if (this.filename === "") {
        this.filename = "index";
      }
      this.path = this._hierarchicalArray(fileMessage.url, fileMessage.origin);
      this.breakpoints = [];
      this.markup = new SourceFileMarkup(this.filename, this.id, this.uri, this);
      this.saveFile();
    }

    SourceFile.prototype.getPath = function() {
      return [].concat(this.path);
    };

    SourceFile.prototype.getOffset = function() {
      return this.offset;
    };

    SourceFile.prototype.getSourceFileLine = function() {
      return this.markup.getSourceFileLine();
    };

    SourceFile.prototype.getFormattedCode = function() {
      return this.markup.getFormattedCode();
    };

    SourceFile.prototype.getRawSourceCode = function() {
      return this.code;
    };

    SourceFile.prototype.getBreakpoints = function() {
      return this.breakpoints;
    };

    SourceFile.prototype.saveFile = function() {
      return window.hoocsd.data.files.saveFile(this.origin, this.id, this);
    };

    SourceFile.prototype.addBreakpoint = function(lineNumber, breakpoint) {
      return this.breakpoints[lineNumber] = breakpoint;
    };

    SourceFile.prototype.removeBreakpoint = function(lineNumber, breakpoint) {
      return this.breakpoints[lineNumber] = null;
    };

    SourceFile.prototype.getBreakpointCallback = function() {
      return this._toggleBreakPoint;
    };

    SourceFile.prototype._toggleBreakPoint = function(cnt, id, uri) {
      if (this.breakpoints[cnt] != null) {
        this.breakpoints[cnt].remove(window.hoocsd.messaging);
        return this.breakpoints[cnt] = null;
      } else {
        return window.hoocsd.messaging.sendMessage({
          type: "js.setBreakpointByUrl",
          origin: this.origin,
          lineNumber: cnt,
          url: uri,
          urlRegex: null,
          columnNumber: 0,
          condition: null,
          scriptId: this.id
        });
      }
    };

    SourceFile.prototype._hierarchicalArray = function(uri, origin) {
      var ostr;

      ostr = new String(origin);
      if (ostr.substringOf(uri)) {
        uri = uri.substring(origin.length);
      }
      uri = uri.split("/");
      if (uri[0] === "") {
        uri.shift();
      }
      uri.pop();
      return uri;
    };

    return SourceFile;

  })();

  comm_JS = (function() {
    function comm_JS(messaging, table) {
      this.messaging = messaging;
      this.table = table;
      this.setBreakpointSuccess = __bind(this.setBreakpointSuccess, this);
      this.listFile = __bind(this.listFile, this);
      this.table["js.ListFile"] = this.listFile;
      this.table["js.setBreakpointSuccess"] = this.setBreakpointSuccess;
    }

    comm_JS.prototype.listFile = function(message) {
      new SourceFile(message);
      return this.messaging.log(message.url);
    };

    comm_JS.prototype.setBreakpointSuccess = function(message) {
      return new BreakPoint(message);
    };

    return comm_JS;

  })();

  StateInformationMarkup = (function(_super) {
    __extends(StateInformationMarkup, _super);

    function StateInformationMarkup(stateInformation) {
      this.stateInformation = stateInformation;
      StateInformationMarkup.__super__.constructor.call(this);
      this.html = $("<ul />");
    }

    StateInformationMarkup.prototype.destroy = function() {};

    StateInformationMarkup.prototype.updateHTML = function() {
      var node, tree, _i, _len, _ref1;

      this.html.empty();
      tree = this.stateInformation.getStateTree();
      _ref1 = tree.getChildren();
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        node = _ref1[_i];
        switch (node.constructor.name) {
          case "ScopeVariableStack":
            this.html.append(this._scopeVariablesStart(node));
            break;
          case "CallStack":
            this.html.append(this._callStack(node));
        }
      }
      return this.html;
    };

    StateInformationMarkup.prototype._stateTitle = function(title, child) {
      var element,
        _this = this;

      element = $("<h4>" + title + "</h4>");
      element.click(function() {
        var cb;

        cb = function() {
          return child.toggle();
        };
        return _this.click(element, cb);
      });
      return element;
    };

    StateInformationMarkup.prototype._clickableTreeItem = function(node, text, child, callback) {
      var element,
        _this = this;

      if (callback == null) {
        callback = null;
      }
      element = $("<li>" + text + "</li>");
      element.click(function() {
        var cb;

        cb = function() {
          var n, _i, _len, _ref1;

          child.toggle();
          _ref1 = node.getChildren();
          for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
            n = _ref1[_i];
            n.toggleVisible();
          }
          if (callback != null) {
            callback();
          }
          return _this.updateHTML();
        };
        return _this.click(element, cb);
      });
      return element;
    };

    StateInformationMarkup.prototype._callStack = function(node) {
      var activeCallStack, call, cs, csline, f, html, stack, title, _i, _j, _len, _len1, _ref1, _ref2,
        _this = this;

      html = $("<li />");
      stack = $("<ul />");
      title = this._stateTitle(node.value.title, stack);
      activeCallStack = null;
      _ref1 = node.getChildren();
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        cs = _ref1[_i];
        if (cs.value.active) {
          activeCallStack = cs;
        }
      }
      html.append(title);
      _ref2 = node.getChildren();
      for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
        call = _ref2[_j];
        csline = $("<li>" + call.value.functionName + " -> " + call.value.fileName + ":" + call.value.lineNumber + "</li>");
        if (call.value.active) {
          csline.addClass("selected-item");
        }
        stack.append(csline);
        f = function(active, selected, element) {
          element.click(function() {
            var cb;

            cb = function() {
              _this.stateInformation.changeCallstackContext(active, selected);
              return _this.updateHTML();
            };
            return _this.click(element, cb);
          });
          return element;
        };
        f(activeCallStack, call, csline);
      }
      html.append(stack);
      return html;
    };

    StateInformationMarkup.prototype._scopeVariablesStart = function(node) {
      var html, scope, scopeNode, title, _i, _len, _ref1;

      html = $("<li />");
      scope = $("<ul />");
      title = this._stateTitle(node.value.title, scope);
      html.append(title);
      _ref1 = node.getChildren();
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        scopeNode = _ref1[_i];
        scope.append(this._scopeVariables(scopeNode));
      }
      html.append(scope);
      return html;
    };

    StateInformationMarkup.prototype._scopeVariables = function(node) {
      var cb, child, html, scope, subtitle, text, title, _i, _len, _ref1,
        _this = this;

      html = $("<li />");
      scope = $("<ul />");
      title = node.value.title;
      subtitle = node.value.subtitle;
      text = title;
      if (subtitle != null) {
        text += " (" + subtitle + ")";
      }
      cb = function() {
        var child, _i, _len, _ref1, _results;

        _this.stateInformation.addChildScopeVariables(node);
        _ref1 = node.getChildren();
        _results = [];
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          child = _ref1[_i];
          _results.push(scope.append(_this._scopeVariables(child)));
        }
        return _results;
      };
      html.append(this._clickableTreeItem(node, this._describeNode(node), scope, cb));
      _ref1 = node.getChildren();
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        child = _ref1[_i];
        scope.append(this._scopeVariables(child));
      }
      html.append(scope);
      if (node.isVisible()) {
        html.show();
      } else {
        html.hide();
      }
      return html;
    };

    StateInformationMarkup.prototype._describeNode = function(node) {
      var scopeObject, text;

      scopeObject = node.value.scopeObject;
      if (scopeObject == null) {
        return "" + node.value.title;
      } else if (scopeObject.value == null) {
        text = "" + node.value.title;
        if (node.value.subtitle != null) {
          text += " (" + node.value.subtitle + ")";
        }
        return text;
      }
      if (scopeObject.value.objectId != null) {
        return "" + scopeObject.name + ": " + scopeObject.value.description;
      } else {
        switch (scopeObject.value.type) {
          case "string":
            return "" + scopeObject.name + ": \"" + scopeObject.value.value + "\"";
          case "number":
            return "" + scopeObject.name + ": " + scopeObject.value.value;
          default:
            return "" + scopeObject.name + ": " + scopeObject.value.value + " :: " + scopeObject.value.type;
        }
      }
    };

    return StateInformationMarkup;

  })(GuiBase);

  TreeNode = (function() {
    function TreeNode(value) {
      this.value = value;
      this.children = [];
    }

    TreeNode.prototype.clear = function() {
      return this.children = [];
    };

    TreeNode.prototype.getValue = function() {
      return this.value;
    };

    TreeNode.prototype.getChildren = function() {
      return this.children;
    };

    TreeNode.prototype.hasChildren = function() {
      return this.children.length !== 0;
    };

    TreeNode.prototype.addChild = function(node) {
      return this.children.push(node);
    };

    TreeNode.prototype.removeChild = function(node) {
      var remove;

      remove = function(array, object) {
        var element, i, _i, _len, _results;

        i = 0;
        _results = [];
        for (_i = 0, _len = array.length; _i < _len; _i++) {
          element = array[_i];
          if (element === object) {
            array.splice(i, 1)[0];
          }
          _results.push(i++);
        }
        return _results;
      };
      return remove(this.children, node);
    };

    TreeNode.prototype.isLeaf = function() {
      return !this.hasChildren();
    };

    TreeNode.prototype.isNode = function() {
      return this.hasChildren();
    };

    return TreeNode;

  })();

  StateTree = (function(_super) {
    __extends(StateTree, _super);

    function StateTree(value) {
      this.toggleVisible = __bind(this.toggleVisible, this);
      this.setVisible = __bind(this.setVisible, this);
      this.isVisible = __bind(this.isVisible, this);      this.visible = true;
      StateTree.__super__.constructor.call(this, value);
    }

    StateTree.prototype.isVisible = function() {
      return this.visible;
    };

    StateTree.prototype.setVisible = function(state) {
      return this.visible = state;
    };

    StateTree.prototype.toggleVisible = function() {
      return this.visible = !this.visible;
    };

    return StateTree;

  })(TreeNode);

  CallStack = (function(_super) {
    __extends(CallStack, _super);

    function CallStack() {
      CallStack.__super__.constructor.call(this, {
        title: "Call Stack"
      });
    }

    return CallStack;

  })(StateTree);

  ScopeVariableStack = (function(_super) {
    __extends(ScopeVariableStack, _super);

    function ScopeVariableStack() {
      ScopeVariableStack.__super__.constructor.call(this, {
        title: "Scope Variables"
      });
    }

    return ScopeVariableStack;

  })(StateTree);

  ScopeVariable = (function(_super) {
    __extends(ScopeVariable, _super);

    function ScopeVariable() {
      _ref1 = ScopeVariable.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    return ScopeVariable;

  })(StateTree);

  CallstackVariable = (function(_super) {
    __extends(CallstackVariable, _super);

    function CallstackVariable() {
      _ref2 = CallstackVariable.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    return CallstackVariable;

  })(StateTree);

  AsyncVariable = (function() {
    function AsyncVariable(value, callback, id) {
      this.value = value != null ? value : null;
      if (callback == null) {
        callback = null;
      }
      this.id = id != null ? id : null;
      this.onChange = [];
      if (callback != null) {
        this.onChange.push(callback);
      }
    }

    AsyncVariable.prototype.setValue = function(v) {
      var cb, _i, _len, _ref3, _results;

      this.value = v;
      _ref3 = this.onChange;
      _results = [];
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        cb = _ref3[_i];
        _results.push(cb(this.value, this.id));
      }
      return _results;
    };

    AsyncVariable.prototype.addCallback = function(cb) {
      return this.onChange.push(cb);
    };

    AsyncVariable.prototype.clearCallback = function() {
      return this.onChange = null;
    };

    AsyncVariable.prototype.getValue = function() {
      return this.value;
    };

    AsyncVariable.prototype.getIdentifier = function() {
      return this.id;
    };

    return AsyncVariable;

  })();

  StateInformation = (function() {
    function StateInformation(origin, messaging, pe) {
      var scriptId;

      this.origin = origin;
      this.messaging = messaging;
      this.updatePropDesc = __bind(this.updatePropDesc, this);
      this.destroy = __bind(this.destroy, this);
      this.tree = this._createStateTree(pe.reason, pe.callFrames);
      this.properties = {};
      this.sim = new StateInformationMarkup(this);
      scriptId = pe.callFrames[0].location.scriptId;
      this.breakpointHit = {
        scriptId: scriptId,
        file: this._getFileByScriptId(scriptId),
        line: pe.callFrames[0].location.lineNumber,
        column: pe.callFrames[0].location.columnNumber
      };
    }

    StateInformation.prototype.breakpointHitLocation = function() {
      return this.breakpointHit;
    };

    StateInformation.prototype.updateHTML = function() {
      return this.sim.updateHTML();
    };

    StateInformation.prototype.getOrigin = function() {
      return this.origin;
    };

    StateInformation.prototype.getStateTree = function() {
      return this.tree;
    };

    StateInformation.prototype.destroy = function() {
      if (this.sim != null) {
        return this.sim.destroy();
      }
    };

    StateInformation.prototype.updatePropDesc = function(objectId, propDescArray) {
      return this.properties[objectId].setValue(propDescArray);
    };

    StateInformation.prototype.changeCallstackContext = function(oldCtx, newCtx) {
      var node, _i, _len, _ref3, _results;

      oldCtx.getValue().active = false;
      newCtx.getValue().active = true;
      _ref3 = this.tree.getChildren();
      _results = [];
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        node = _ref3[_i];
        if (node.constructor.name === "ScopeVariableStack") {
          this.tree.removeChild(node);
          _results.push(this.tree.addChild(newCtx.getValue().scopeVars));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    StateInformation.prototype.addChildScopeVariables = function(scopeNode) {
      var cb, object, thisNode, thisReference,
        _this = this;

      if (scopeNode == null) {
        return;
      }
      if (scopeNode.hasChildren()) {
        return;
      }
      object = scopeNode.getValue().scopeObject;
      if (object.value != null) {
        object = object.value;
      }
      thisReference = scopeNode.getValue().thisReference;
      cb = function(value, id) {
        var item, itemNode, proto, _i, _len;

        proto = _this._newProtoNode();
        for (_i = 0, _len = value.length; _i < _len; _i++) {
          item = value[_i];
          itemNode = _this._newScopeVariableNode(item, item.name);
          if (item.isOwn != null) {
            scopeNode.addChild(itemNode);
          } else {
            proto.addChild(itemNode);
            itemNode.setVisible(false);
          }
        }
        if (proto.hasChildren()) {
          return scopeNode.addChild(proto);
        }
      };
      this._getProperties(object, cb);
      if (thisReference != null) {
        thisNode = this._newScopeVariableNode(thisReference, "this: " + thisReference.description);
        scopeNode.addChild(thisNode);
        return this.addChildScopeVariables(this.thisNode);
      }
    };

    StateInformation.prototype._getFileByScriptId = function(scriptId) {
      return window.hoocsd.data.files.get(scriptId, this.origin);
    };

    StateInformation.prototype._newProtoNode = function() {
      return new ScopeVariable({
        title: "__proto__"
      });
    };

    StateInformation.prototype._newScopeVariableNode = function(scopeObject, title, subtitle, thisReference) {
      if (title == null) {
        title = null;
      }
      if (subtitle == null) {
        subtitle = null;
      }
      if (thisReference == null) {
        thisReference = null;
      }
      return new ScopeVariable({
        title: title,
        subtitle: subtitle,
        thisReference: thisReference,
        scopeObject: scopeObject
      });
    };

    StateInformation.prototype._newCallstackVariableNode = function(functionName, fileName, lineNumber, callFrame, active, scopeVars) {
      if (active == null) {
        active = false;
      }
      if (scopeVars == null) {
        scopeVars = null;
      }
      return new CallstackVariable({
        functionName: functionName,
        fileName: fileName,
        lineNumber: lineNumber,
        callFrame: callFrame,
        scopeVars: scopeVars,
        active: active
      });
    };

    StateInformation.prototype._createStateTree = function(reason, callFrames) {
      var call, scopeVars, stack, tree, _i, _len, _ref3;

      tree = new StateTree({
        title: "JS VM State",
        reason: reason
      });
      stack = this._createCallStack(callFrames);
      tree.addChild(stack);
      _ref3 = stack.getChildren();
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        call = _ref3[_i];
        scopeVars = this._createScopeVariables(call.getValue());
        if (call.getValue().active) {
          tree.addChild(scopeVars);
        }
        call.getValue().scopeVars = scopeVars;
      }
      return tree;
    };

    StateInformation.prototype._getProperties = function(object, cb) {
      var ret;

      if (cb == null) {
        cb = null;
      }
      if (this.properties[object.objectId] != null) {
        return this.properties[object.objectId];
      } else {
        ret = new AsyncVariable(null, cb, object.objectId);
        this.properties[object.objectId] = ret;
        this.messaging.sendMessage({
          type: "Runtime.getProperties",
          objectId: object.objectId,
          ownProperties: false,
          origin: this.origin
        });
        return ret;
      }
    };

    StateInformation.prototype._createCallStack = function(callFrames) {
      var active, cf, file, fileName, functionName, tree, _i, _len;

      tree = new CallStack;
      active = true;
      for (_i = 0, _len = callFrames.length; _i < _len; _i++) {
        cf = callFrames[_i];
        if (cf.functionName !== "") {
          functionName = cf.functionName;
        } else {
          functionName = "(anonymous function)";
        }
        file = this._getFileByScriptId(cf.location.scriptId);
        fileName = file.filename;
        tree.addChild(this._newCallstackVariableNode(functionName, fileName, cf.location.lineNumber, cf, active));
        if (active) {
          active = false;
        }
      }
      return tree;
    };

    StateInformation.prototype._createScopeVariables = function(callStackNode) {
      var chain, frame, scope, subtitle, thisReference, title, tree, _i, _len;

      tree = new ScopeVariableStack;
      frame = callStackNode.callFrame;
      chain = frame.scopeChain;
      for (_i = 0, _len = chain.length; _i < _len; _i++) {
        scope = chain[_i];
        title = null;
        subtitle = scope.object.description;
        thisReference = null;
        switch (scope.type) {
          case "local":
            title = "Local";
            subtitle = null;
            if (frame["this"]) {
              thisReference = frame["this"];
            }
            break;
          case "closure":
            title = "Closure";
            subtitle = null;
            break;
          case "catch":
            title = "Catch";
            subtitle = null;
            break;
          case "with":
            title = "With block";
            break;
          case "global":
            title = "Global";
        }
        tree.addChild(this._newScopeVariableNode(scope.object, title, subtitle, thisReference));
      }
      return tree;
    };

    return StateInformation;

  })();

  StateInformationManager = (function(_super) {
    __extends(StateInformationManager, _super);

    function StateInformationManager() {
      this.store = [];
      StateInformationManager.__super__.constructor.call(this);
    }

    StateInformationManager.prototype.saveStateInformation = function(stateInfo) {
      this.deleteAllStateInformation();
      this.store[stateInfo.getOrigin()] = stateInfo;
      this.updateHTML();
      return this.showBreakpoint(stateInfo);
    };

    StateInformationManager.prototype.deleteAllStateInformation = function() {
      var origin, x, _ref3, _results;

      _ref3 = this.store;
      _results = [];
      for (origin in _ref3) {
        x = _ref3[origin];
        _results.push(this.deleteStateInformation(origin));
      }
      return _results;
    };

    StateInformationManager.prototype.deleteStateInformation = function(origin) {
      this.store[origin].destroy();
      return delete this.store[origin];
    };

    StateInformationManager.prototype.exists = function(origin) {
      return this.store[origin] != null;
    };

    StateInformationManager.prototype.updatePropDesc = function(origin, objectId, propDescArray) {
      this.store[origin].updatePropDesc(objectId, propDescArray);
      return this.updateHTML();
    };

    StateInformationManager.prototype.showBreakpoint = function(si) {
      var loc;

      loc = si.breakpointHitLocation();
      return window.hoocsd.data.files.showBreakpointAndSourceFile(loc.file, loc.scriptId, loc.line);
    };

    StateInformationManager.prototype.updateHTML = function() {
      var child, info, list, origin, rootel, title, _ref3, _results,
        _this = this;

      rootel = $(this.vdata.stateInfoId());
      rootel.empty();
      list = $("<ul />");
      rootel.append(list);
      _ref3 = this.store;
      _results = [];
      for (origin in _ref3) {
        info = _ref3[origin];
        title = $("<li><h4>" + origin + "</h4></li>");
        child = info.updateHTML();
        list.append(title);
        list.append(child);
        _results.push(title.click(function() {
          var cb;

          cb = function() {
            return child.toggle();
          };
          return _this.click(title, cb);
        }));
      }
      return _results;
    };

    return StateInformationManager;

  })(GuiBase);

  comm_debugger = (function() {
    function comm_debugger(messaging, table) {
      this.messaging = messaging;
      this.table = table;
      this.propReply = __bind(this.propReply, this);
      this.paused = __bind(this.paused, this);
      this.table["debugger.paused"] = this.paused;
      this.table["debugger.getPropertiesReply"] = this.propReply;
      this.stateInfoManager = new StateInformationManager;
    }

    comm_debugger.prototype.paused = function(message) {
      var si;

      if (this.stateInfoManager.exists(message.origin)) {
        this.stateInfoManager.deleteStateInformation(message.origin);
      }
      si = new StateInformation(message.origin, this.messaging, message);
      return this.stateInfoManager.saveStateInformation(si);
    };

    comm_debugger.prototype.propReply = function(message) {
      return this.stateInfoManager.updatePropDesc(message.origin, message.objectId, message.propDescArray);
    };

    return comm_debugger;

  })();

  Messaging = (function() {
    function Messaging(portName, logger) {
      var _this = this;

      this.portName = portName;
      this.logger = logger;
      this.lookup_table = {};
      this.js = new comm_JS(this, this.lookup_table);
      this["debugger"] = new comm_debugger(this, this.lookup_table);
      this.port = chrome.runtime.connect({
        name: this.portName
      });
      this.port.onMessage.addListener(function(m) {
        return _this._MessageEventCallback(m);
      });
    }

    Messaging.prototype.sendMessage = function(message) {
      return this.port.postMessage(message);
    };

    Messaging.prototype.log = function(message) {
      return this.logger.log(message);
    };

    Messaging.prototype._MessageEventCallback = function(message) {
      var error;

      this.logger.log("Received: " + message.type);
      if (message.type == null) {
        this.logger.log("Message cannot be understood...");
        console.log(message);
        void 0;
      }
      try {
        return this.lookup_table[message.type](message);
      } catch (_error) {
        error = _error;
        console.log(error);
        this.logger.log("" + message.type + ": unsupported.");
        console.log("" + message.type + ": unsupported.");
        console.log(message);
        return this.lookup_table[message.type](message);
      }
    };

    return Messaging;

  })();

  Console = (function() {
    function Console(messaging, logger) {
      this.messaging = messaging;
      this.logger = logger;
    }

    Console.prototype.getCmd = function(str) {
      return str.split(' ')[0];
    };

    Console.prototype.getArgs = function(str) {
      var s;

      s = str.split(/\ (.+)?/);
      if (s.length > 1) {
        return s[1];
      } else {
        return "";
      }
    };

    Console.prototype.evaluate = function(command) {
      var args, cmd;

      cmd = this.getCmd(command);
      args = this.getArgs(command);
      switch (cmd) {
        case "sendmessage":
          return this._sendMessage(args);
        case "pause":
          return this._js_pause();
        case "p":
          return this._js_pause();
        case "resume":
          return this._js_resume();
        case "r":
          return this._js_resume();
        case "breakpointsActive":
          return this._js_breakpointsActive(args);
        case "stepover":
          return this._js_stepover();
        case "stepinto":
          return this._js_stepinto();
        case "stepout":
          return this._js_stepout();
        default:
          return this.logger.log("Command [" + cmd + "] not yet implemented");
      }
    };

    Console.prototype._sendMessage = function(args) {
      var error;

      try {
        return this.messaging.sendMessage($.parseJSON(args));
      } catch (_error) {
        error = _error;
        return this.logger.log("Error: " + error);
      }
    };

    Console.prototype._js_resume = function() {
      this.logger.log("Resuming JavaScript execution");
      return this.messaging.sendMessage({
        type: "js.resume",
        origin: window.hoocsd.omniscient
      });
    };

    Console.prototype._js_pause = function() {
      this.logger.log("Pausing JavaScript execution");
      return this.messaging.sendMessage({
        type: "js.pause",
        origin: window.hoocsd.omniscient
      });
    };

    Console.prototype._js_breakpointsActive = function(args) {
      this.logger.log("breakpointsActive " + args + " given");
      return this.messaging.sendMessage({
        type: "js.breakpointsActive",
        value: args === "true",
        origin: window.hoocsd.omniscient
      });
    };

    Console.prototype._js_stepover = function() {
      this.logger.log("Stepover requested");
      return this.messaging.sendMessage({
        type: "Debugger.stepOver",
        origin: window.hoocsd.omniscient
      });
    };

    Console.prototype._js_stepinto = function() {
      this.logger.log("Stepinto requested");
      return this.messaging.sendMessage({
        type: "Debugger.stepInto",
        origin: window.hoocsd.omniscient
      });
    };

    Console.prototype._js_stepout = function() {
      this.logger.log("Stepout requested");
      return this.messaging.sendMessage({
        type: "Debugger.stepOut",
        origin: window.hoocsd.omniscient
      });
    };

    return Console;

  })();

  CircularBuffer = (function() {
    function CircularBuffer(req_size) {
      this.size = req_size + 1;
      this.store = new Array(this.size);
      this.start = 0;
      this.end = 0;
    }

    CircularBuffer.prototype.isFull = function() {
      return (this.end + 1) % this.size === this.start;
    };

    CircularBuffer.prototype.isEmpty = function() {
      return this.end === this.start;
    };

    CircularBuffer.prototype.push = function(data) {
      this.store[this.end] = data;
      this.end = (this.end + 1) % this.size;
      if (this.end === this.start) {
        return this.start = (this.start + 1) % this.size;
      }
    };

    CircularBuffer.prototype.pop = function() {
      var tmp;

      if (this.isEmpty()) {
        throw "Empty circular buffer!";
      }
      tmp = this.start;
      this.start = (this.start + 1) % this.size;
      return this.store[tmp];
    };

    CircularBuffer.prototype.capacity = function() {
      return this.size - 1;
    };

    CircularBuffer.prototype.count = function() {
      var c, s;

      s = this.start;
      c = 0;
      while (s !== this.end) {
        s = (s + 1) % this.size;
        c++;
      }
      return c;
    };

    CircularBuffer.prototype.peek = function(index) {
      if (index == null) {
        index = 0;
      }
      if (!(this.count() > 0 && index < this.count())) {
        throw "Circular Buffer index out of range! " + index;
      }
      return this.store[(this.start + index) % this.size];
    };

    CircularBuffer.prototype.forEach = function(func, context) {
      var index, _i, _ref3, _results;

      _results = [];
      for (index = _i = 0, _ref3 = this.count(); 0 <= _ref3 ? _i < _ref3 : _i > _ref3; index = 0 <= _ref3 ? ++_i : --_i) {
        _results.push(func.call(context, this.peek(index), index));
      }
      return _results;
    };

    CircularBuffer.prototype.toArray = function() {
      var f, x;

      f = function(el, index) {
        return x.push(el);
      };
      x = [];
      this.forEach(f, x);
      return x;
    };

    return CircularBuffer;

  })();

  Logger = (function() {
    function Logger(id, size) {
      this.id = id;
      if (size == null) {
        size = 50;
      }
      this.cb = new CircularBuffer(size);
    }

    Logger.prototype.log = function(message) {
      this.cb.push(message);
      return this.update();
    };

    Logger.prototype.update = function() {
      var x, _i, _len, _ref3, _results;

      $(this.id).empty();
      _ref3 = this.cb.toArray().reverse();
      _results = [];
      for (_i = 0, _len = _ref3.length; _i < _len; _i++) {
        x = _ref3[_i];
        _results.push($(this.id).append("<p>" + x + "</p>"));
      }
      return _results;
    };

    return Logger;

  })();

  $(function() {
    var e, elements, vd, _i, _len;

    vd = new ViewData;
    vd.init();
    elements = ["#content", "#console-output", "#console", "#filelist", "#state-information"];
    for (_i = 0, _len = elements.length; _i < _len; _i++) {
      e = elements[_i];
      setupGuiElements(e);
    }
    $(".boxed-header .ui-icon").click(function() {
      $(this).toggleClass("ui-icon-minusthick").toggleClass("ui-icon-plusthick");
      return $(this).parents(".boxed:first").find(".boxed-content").toggle();
    });
    hoocsd.logger = new Logger("#console-output-text", 20);
    hoocsd.messaging = new Messaging("hoocsd", hoocsd.logger);
    hoocsd.cli = new Console(hoocsd.messaging, hoocsd.logger);
    $("#console-form").submit(function(e) {
      var value;

      e.preventDefault;
      value = $("#console-line")[0].value;
      hoocsd.cli.evaluate(value);
      return false;
    });
    $("#controls-continue").click(function() {
      return hoocsd.cli.evaluate("resume");
    });
    $("#controls-pause").click(function() {
      return hoocsd.cli.evaluate("pause");
    });
    $("#controls-stepover").click(function() {
      return hoocsd.cli.evaluate("stepover");
    });
    $("#controls-stepinto").click(function() {
      return hoocsd.cli.evaluate("stepinto");
    });
    $("#controls-stepout").click(function() {
      return hoocsd.cli.evaluate("stepout");
    });
    $("#controls-breakpoints-disabled").click(function() {
      return hoocsd.cli.evaluate("breakpointsActive false");
    });
    $("#controls-breakpoints-enabled").click(function() {
      return hoocsd.cli.evaluate("breakpointsActive true");
    });
    return setTimeout((function() {
      return hoocsd.messaging.sendMessage({
        type: "js.ListFiles"
      });
    }), 250);
  });

  setupGuiElements = function(element) {
    $(element).draggable({
      handle: ".boxed-header",
      snap: true,
      containment: "parent"
    });
    return $(element).resizable();
  };

}).call(this);
