class debug_node_event_break
  constructor: (@dbg, @debugger, @table, @cfprovider) ->
    @table["break"] = @break
    @table["resume"] = @resume

  break: (data) =>
    @debugger.showOverlay()

    cb = (err, data) =>
      @debugger.sendMessage
        type: "debugger.paused"
        callFrames: data
        reason: "Node paused"
        origin: @dbg.origin()
      @dbg.paused = true

    @cfprovider.fetchCallFrames cb

  resume: (data) =>
    @debugger.sendMessage
      type: "debugger.resume"
      origin: @dbg.origin()

    @dbg.paused = true
