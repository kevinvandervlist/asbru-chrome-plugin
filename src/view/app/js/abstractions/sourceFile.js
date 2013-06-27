// Represent a sourcefile.
var SourceFile = (function() {
  function SourceFile(fileMessage) {
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
  }

  SourceFile.prototype.getPath = function() {
    return [].concat(this.path);
  };

  SourceFile.prototype.getOffset = function() {
    return this.offset;
  };

  SourceFile.prototype.getRawSourceCode = function() {
    return this.code;
  };

  SourceFile.prototype.getBreakpoints = function() {
    return this.breakpoints;
  };

  SourceFile.prototype.addBreakpoint = function(lineNumber, breakpoint) {
    this.breakpoints[lineNumber] = breakpoint;
  };

  SourceFile.prototype.removeBreakpoint = function(lineNumber, breakpoint) {
    delete this.breakpoints[lineNumber];
  };

  SourceFile.prototype._hierarchicalArray = function(uri, origin) {
    var ostr;

    ostr = new String(origin);

    // substring of?
    if ((new RegExp(origin)).test(uri)) {
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
