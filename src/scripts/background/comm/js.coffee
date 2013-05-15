class comm_JS
  constructor: (@messager, @table) ->
    @table["js.ListFiles"] = @listFiles
    @table["js.setBreakpointByUrl"] = @setBreakpointByUrl

  # js.ListFiles
  # [ { scriptId: int, url: URI, code: <code> }, { ... } .. ]
  listFiles: (message) =>
    f = (x) =>
      @messager.sendMessage
        type: "js.ListFile"
        scriptId: x.scriptId
        url: x.url
        code: x.code
    f x for x in hoocsd.files

  # js.setBreakpointByUrl
  # https://developers.google.com/chrome-developer-tools/docs/protocol/1.0/debugger#command-setBreakpointByUrl
  setBreakpointByUrl: (message) =>
    cb = (res) =>
      @_setBreakpointSuccess res.breakpointId
    cm =
      lineNumber: message.lineNumber
      url: message.url
      urlRegex: message.urlRegex
      columnNumber: message.columnNumber
      condition: message.condition
    @messager.sendCommand "Debugger.setBreakpointByUrl", cm, cb

  # js.setBreakpointSuccess
  # { breakpointId: string, scriptId: int }
  _setBreakpointSuccess: (breakpointId) ->
    @messager.sendMessage
      type: "js.setBreakpointSuccess"
      breakpointId: breakpointId
      scriptId: @_getScriptIdFromUrl breakpointId

  # Hackily retrieve the scriptId based on a breakpoint URI
  _getScriptIdFromUrl: (breakpointId) ->
    t = breakpointId.split(":");
    url = t.shift() + ":" + t.shift()
    scriptId = -1

    f = (x) ->
      if x.url is url
        scriptId = x.scriptId
    f x for x in hoocsd.files

    scriptId
