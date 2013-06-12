class debug_node_debugger
  constructor: (@dbg, @debugger, @table) ->
    @table["Debugger.setBreakpointByUrl"] = @setBreakpointByUrl
    @table["Debugger.removeBreakpoint"] = @removeBreakpoint
    @table["Debugger.resume"] = @resume
    @table["Debugger.pause"] = @pause

  resume: (message, callback) =>
    m =
      type: "request"
      command: "continue"
    @dbg._sendCommand m, callback

  pause: (message, callback) =>
    # Unsupported, do nothing
    return undefined

  setBreakpointByUrl: (command, callback) =>
    cb = (res) =>
      @_setBreakpointSuccess res
    cm =
      type: "request"
      command: "setbreakpoint"
      arguments:
        type: "script"
        enabled: true
        target: command.url
        line: command.lineNumber
    #target: message.url.substring(window.hoocsd.nodeOrigin.length)
    @dbg._sendCommand cm, cb

  _setBreakpointSuccess: (message) =>
    console.log "Set breakpoint"
    @debugger.sendMessage
      type: "js.setBreakpointSuccess"
      breakpointId: message.body
      lineNumber: message.body.line
      columnNumber: message.body.actual_locations[0].column
      scriptId: message.body.actual_locations[0].script_id
      origin: @dbg.origin()

  # Request the removal of a breakpoint in node
  removeBreakpoint: (message, callback) =>
    m =
      type: "request"
      command: "clearbreakpoint"
      arguments:
        breakpoint: message.breakpoint
    @dbg._sendCommand m, callback
