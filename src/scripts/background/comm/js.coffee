#= require Origin.coffee

class comm_JS
  constructor: (@messager, @table) ->
    @table["js.ListFiles"] = @listFiles
    @table["js.setBreakpointByUrl"] = @setBreakpointByUrl
    @table["js.removeBreakpoint"] = @removeBreakpoint
    @table["js.pause"] = @pause
    @table["js.resume"] = @resume
    @table["js.breakpointsActive"] = @breakpointsActive

  # js.ListFiles: local
  # [ { scriptId: int, url: URI, code: <code> }, { ... } .. ]
  # Also try remote site:
  listFiles: (message) =>
    f = (x) =>
      @messager.sendMessage
        type: "js.ListFile"
        scriptId: x.scriptId
        url: x.url
        code: x.code

    for origin in window.hoocsd.files.getOrigins()
      for file in window.hoocsd.files.getAllFilesByOrigin origin
        f file

    return undefined

  # This function must make a distinction between the different targets
  setBreakpointByUrl: (message) =>
    origin = Origin.createOriginFromUri message.url
    if origin is window.hoocsd.clientOrigin
      @setBreakpointByUrl_local message
    else
      @setBreakpointByUrl_remote message

  # js.setBreakpointByUrl
  # https://developers.google.com/chrome-developer-tools/docs/protocol/1.0/debugger#command-setBreakpointByUrl
  setBreakpointByUrl_local: (message) ->
    cb = (res) =>
      @_setBreakpointSuccess_local res.breakpointId
    cm =
      lineNumber: message.lineNumber
      url: message.url
      urlRegex: message.urlRegex
      columnNumber: message.columnNumber
      condition: message.condition
    @messager.sendCommand "Debugger.setBreakpointByUrl", cm, cb

  # Remote; nodejs
  # https://code.google.com/p/v8/wiki/DebuggerProtocol
  setBreakpointByUrl_remote: (message) ->
    cb = (res) =>
      @_setBreakpointSuccess_remote res
    cm =
      type: "request"
      command: "setbreakpoint"
      arguments:
        type: "scriptId"
        target: message.url
        line: message.lineNumber
    @messager.sendNodeMessage cm, cb

  # js.setBreakpointSuccess
  # { breakpointId: string, scriptId: int }
  _setBreakpointSuccess_local: (breakpointId) ->
    dbp = @_dissectBreakpointId_local breakpointId
    @messager.sendMessage
      type: "js.setBreakpointSuccess"
      breakpointId: breakpointId
      lineNumber: dbp.line
      columnNumber: dbp.col
      scriptId: dbp.id
      origin: window.hoocsd.clientOrigin

  _setBreakpointSuccess_remote: (message) ->
    @messager.sendMessage
      type: "js.setBreakpointSuccess"
      breakpointId: message
      lineNumber: message.body.line
      columnNumber: message.body.column
      scriptId: @_scriptIdFromURL(message.body.script_id)
      origin: Origin.createOriginFromUri(message.body.script_id)

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
  _dissectBreakpointId_local: (breakpointId) ->
    t = breakpointId.split(":");
    # The array ends with line:col, so reverse and shift
    t.reverse()
    col = t.shift()
    line = t.shift()
    # The url is the rest, reversed and joined
    t.reverse()
    url = t.join(":")
    scriptId = @_scriptIdFromURL url

    id: scriptId
    col: col
    line: line

  _scriptIdFromURL: (url) ->
    scriptId = -1
    f = (x) ->
      if x.url is url
        scriptId = x.scriptId

    for origin in window.hoocsd.files.getOrigins()
      for file in window.hoocsd.files.getAllFilesByOrigin origin
        f file

    throw "scriptId of breakpointId cannot be found!" if scriptId is -1

    return scriptId