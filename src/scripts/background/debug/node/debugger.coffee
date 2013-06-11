class debug_node_debugger
  constructor: (@dbg, @messager, @table) ->
    @table["Debugger.setBreakpointByUrl"] = @setBreakpointByUrl
    @table["Debugger.resume"] = @resume

  resume: (message, cb) =>
    console.log "TODO: Node resume #{message}"

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

  _setBreakpointSuccess: (message) ->
    @messager.sendMessage
      type: "js.setBreakpointSuccess"
      breakpointId: message
      lineNumber: message.body.line
      columnNumber: message.body.actual_locations[0].column
      #scriptId: @_scriptIdFromURL(window.hoocsd.nodeOrigin + message.body.script_name)
      scriptId: message.body.actual_locations[0].script_id
      origin: window.hoocsd.nodeOrigin

