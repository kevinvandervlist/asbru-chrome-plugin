class debug_omniscient_debugger
  constructor: (@debugger, @table, @parent_table, @origin) ->
    @table["Debugger.pause"] = @debuggerResume
    @table["Debugger.resume"] = @debuggerResume

  # For now, forward resume to all contexts
  debuggerResume: (command, message, cb) =>
    for k,v of @parent_table
      if k isnt @origin
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined

  debuggerPause: (command, message, cb) =>
    for k,v of @parent_table
      if k isnt @origin
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined
