class debug_node_debugger
  constructor: (@dbg, @debugger, @table) ->
    @table["Debugger.setBreakpointByUrl"] = @setBreakpointByUrl
    @table["Debugger.removeBreakpoint"] = @removeBreakpoint
    @table["Debugger.resume"] = @resume
    @table["Debugger.pause"] = @pause
    @table["Debugger.stepOver"] = @stepOver
    @table["Debugger.stepInto"] = @stepInto
    @table["Debugger.stepOut"] = @stepOut

    @bps = []

  _continueCallback: =>
    @debugger.sendMessage
      type: "debugger.resume"
      origin: @dbg.origin()

  stepOver: (message, callback) =>
    m =
      type: "request"
      command: "continue"
      arguments:
        stepaction: "next"
        stepcount: 1
    @dbg._sendCommand m, @_continueCallback

  stepInto: (message, callback) =>
    m =
      type: "request"
      command: "continue"
      arguments:
        stepaction: "in"
        stepcount: 1
    @dbg._sendCommand m, @_continueCallback

  stepOut: (message, callback) =>
    m =
      type: "request"
      command: "continue"
      arguments:
        stepaction: "out"
        stepcount: 1
    @dbg._sendCommand m, @_continueCallback

  resume: (message, callback) =>
    @debugger.hideOverlay()
    m =
      type: "request"
      command: "continue"
    @dbg._sendCommand m, @_continueCallback

  pause: (message, callback) =>
    # Unsupported, do nothing
    return undefined

  setBreakpointByUrl: (command, callback) =>
    cb = (res) =>
      @_setBreakpointSuccess res, command.condition
    cm =
      type: "request"
      command: "setbreakpoint"
      arguments:
        type: "script"
        enabled: true
        target: command.url
        condition: command.condition
        line: command.lineNumber
    @dbg._sendCommand cm, cb

  _setBreakpointSuccess: (message, condition) =>
    # Store in local cache (for cleanup)
    @bps[message.body.breakpoint] = true

    @debugger.sendMessage
      type: "js.setBreakpointSuccess"
      breakpointId: message.body
      lineNumber: message.body.line
      columnNumber: message.body.actual_locations[0].column
      scriptId: message.body.actual_locations[0].script_id
      condition: condition
      origin: @dbg.origin()

  # Request the removal of a breakpoint in node
  removeBreakpoint: (message, callback) =>
    # Remove from local cache
    delete @bps[message.breakpointId.breakpoint]

    m =
      type: "request"
      command: "clearbreakpoint"
      arguments:
        breakpoint: message.breakpointId.breakpoint
    @dbg._sendCommand m, callback

  removeAllBreakpoints: ->
    for id,v of @bps
      @dbg._sendCommand
        type: "request"
        command: "clearbreakpoint"
        arguments:
          breakpoint: id
    return undefined
