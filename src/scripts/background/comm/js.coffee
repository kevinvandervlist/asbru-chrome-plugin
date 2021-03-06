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
        origin: x.origin
        url: x.url
        offset: x.offset
        code: x.code

    for origin in window.asbru.files.getOrigins()
      for file in window.asbru.files.getAllFilesByOrigin origin
        f file

    # TODO: Hack
    # Signal completion
    @messager.sendMessage
      type: "js.ListFileComplete"

    return undefined

  # js.setBreakpointByUrl
  # https://developers.google.com/chrome-developer-tools/docs/protocol/1.0/debugger#command-setBreakpointByUrl
  setBreakpointByUrl: (message) =>
    cb = (res) =>
      @_setBreakpointSuccess res.breakpointId, message.origin, message.condition
    cm =
      lineNumber: message.lineNumber
      url: message.url
      urlRegex: message.urlRegex
      origin: message.origin
      columnNumber: message.columnNumber
      condition: message.condition
    @messager.sendCommand "Debugger.setBreakpointByUrl", cm, cb


  # js.setBreakpointSuccess
  # { breakpointId: string, scriptId: int }
  _setBreakpointSuccess: (breakpointId, origin, condition) ->
    dbp = @_dissectBreakpointId_local breakpointId
    @messager.sendMessage
      type: "js.setBreakpointSuccess"
      breakpointId: breakpointId
      lineNumber: dbp.line
      columnNumber: dbp.col
      scriptId: dbp.id
      condition: condition
      origin: origin

  # Remove a breakpoint
  # https://developers.google.com/chrome-developer-tools/docs/protocol/1.0/debugger#command-removeBreakpoint
  removeBreakpoint: (message) =>
    @messager.sendCommand "Debugger.removeBreakpoint",
      breakpointId: message.breakpointId
      origin: message.origin

  # Pause javascript execution
  # https://developers.google.com/chrome-developer-tools/docs/protocol/1.0/debugger#command-pause
  pause: (message) =>
    @messager.sendCommand "Debugger.pause",
      origin: message.origin

  # Resume javascript execution
  # https://developers.google.com/chrome-developer-tools/docs/protocol/1.0/debugger#command-resume
  resume: (message) =>
    @messager.sendCommand "Debugger.resume",
      origin: message.origin
      target: message.target

  breakpointsActive: (message) =>
    @messager.sendCommand "Debugger.setBreakpointsActive",
      origin: message.origin
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

    for origin in window.asbru.files.getOrigins()
      for file in window.asbru.files.getAllFilesByOrigin origin
        f file

    throw "scriptId of breakpointId cannot be found!" if scriptId is -1

    return scriptId
