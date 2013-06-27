// Ported from coffescript, some helpers are still needed.
var __hasProp = {}.hasOwnProperty;
var __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

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


var OriginDataManager = (function() {
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

var FileManager = (function(_super) {
  __extends(FileManager, _super);

  function FileManager() {
    FileManager.__super__.constructor.call(this);
  }

  FileManager.prototype.saveFile = function(origin, key, sourceFile) {
    this.put(origin, key, sourceFile);
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

  return FileManager;

})(OriginDataManager);
