class debug_omniscient_debugger
  constructor: (@debugger, @table, @parent_table, @origin) ->
    @table["Debugger.pause"] = @pause
    @table["Debugger.resume"] = @resume
    @table["Debugger.stepOver"] = @stepOver
    @table["Debugger.stepInto"] = @stepInto
    @table["Debugger.stepOut"] = @stepOut

  # For now, forward resume to all contexts
  resume: (command, message, cb) =>
    if message.target is ""
      for k,v of @parent_table
        if k isnt @origin and v.isPaused()
          message["origin"] = k
          v.sendCommand command, message, cb
    else
      # Not omniscient
      message["origin"] = message.target
      # Hack to retrieve the debugger part of the origin
      dbg = @parent_table[window.asbru[message.target]]
      dbg.sendCommand command, message, cb
    undefined

  pause: (command, message, cb) =>
    for k,v of @parent_table
      if k isnt @origin and not v.isPaused()
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined

  stepOver: (command, message, cb) =>
    for k,v of @parent_table
      if k isnt @origin and v.isPaused()
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined

  stepInto: (command, message, cb) =>
    for k,v of @parent_table
      if k isnt @origin and v.isPaused()
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined

  stepOut: (command, message, cb) =>
    for k,v of @parent_table
      if k isnt @origin  and v.isPaused()
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined
