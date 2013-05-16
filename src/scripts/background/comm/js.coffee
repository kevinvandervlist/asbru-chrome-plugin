class comm_JS
  constructor: (@messager, @table) ->
    @table["js.ListFiles"] = @listFiles
    @table["js.setBreakpointByUrl"] = @setBreakpointByUrl
    @table["js.removeBreakpoint"] = @removeBreakpoint
    @table["js.pause"] = @pause
    @table["js.resume"] = @resume
    @table["js.breakpointsActive"] = @breakpointsActive

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
    dbp = @_dissectBreakpointId breakpointId
    @messager.sendMessage
      type: "js.setBreakpointSuccess"
      breakpointId: breakpointId
      lineNumber: dbp.line
      columnNumber: dbp.col
      scriptId: dbp.id

  # Remove a breakpoint
  # https://developers.google.com/chrome-developer-tools/docs/protocol/1.0/debugger#command-removeBreakpoint
  removeBreakpoint: (message) =>
    @messager.sendCommand "Debugger.removeBreakpoint",
      breakpointId: message.breakpointId

  # Pause javascript execution
  # https://developers.google.com/chrome-developer-tools/docs/protocol/1.0/debugger#command-pause
  pause: (message) =>
    @messager.sendCommand "Debugger.pause"

  # Resume javascript execution
  # https://developers.google.com/chrome-developer-tools/docs/protocol/1.0/debugger#command-resume
  resume: (message) =>
    @messager.sendCommand "Debugger.resume"

  breakpointsActive: (message) =>
    @messager.sendCommand "Debugger.setBreakpointsActive",
      active: message.value

  ## Local stuff

  # Hackily retrieve the scriptId based on a breakpoint URI
  _dissectBreakpointId: (breakpointId) ->
    t = breakpointId.split(":");
    t.reverse()
    col = t.shift()
    line = t.shift()
    t.reverse()
    url = t.shift() + ":" + t.shift()
    scriptId = -1

    f = (x) ->
      if x.url is url
        scriptId = x.scriptId
    f x for x in hoocsd.files

    id: scriptId
    col: col
    line: line
