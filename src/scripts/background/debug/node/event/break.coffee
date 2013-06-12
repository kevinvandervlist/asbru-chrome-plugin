#= require debug/node/inspector_utils/CallFramesProvider.coffee

class debug_node_event_break
  constructor: (@dbg, @debugger, @table) ->
    @table["break"] = @break
    @cfprovider = new CallFramesProvider @dbg

  break: (data) =>
    console.log "Breakpoint hit in NodeJS!"
    console.log data

    cb = (err, data) =>
      console.log "fetchCallFrames callback: "
      console.log data

    @cfprovider.fetchCallFrames cb

