class debug_node_event_break
  constructor: (@dbg, @debugger, @table, @cfprovider) ->
    @table["break"] = @break

  break: (data) =>
    @debugger.showOverlay()

    cb = (err, data) =>
      @debugger.sendMessage
        type: "debugger.paused"
        callFrames: data
        reason: "Node paused"
        origin: @dbg.origin()

    @cfprovider.fetchCallFrames cb
