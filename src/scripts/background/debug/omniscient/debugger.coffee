class debug_omniscient_debugger
  constructor: (@debugger, @table, @parent_table, @origin) ->
    @table["Debugger.pause"] = @pause
    @table["Debugger.resume"] = @resume
    @table["Debugger.stepOver"] = @stepOver
    @table["Debugger.stepInto"] = @stepInto
    @table["Debugger.stepOut"] = @stepOut

  # For now, forward resume to all contexts
  resume: (command, message, cb) =>
    for k,v of @parent_table
      if k isnt @origin
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined

  pause: (command, message, cb) =>
    for k,v of @parent_table
      if k isnt @origin
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined

  stepOver: (command, message, cb) =>
    console.log "stepOver omn"
    for k,v of @parent_table
      if k isnt @origin
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined

  stepInto: (command, message, cb) =>
    console.log "stepInto omn"
    for k,v of @parent_table
      if k isnt @origin
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined

  stepOut: (command, message, cb) =>
    console.log "stepOut omn"
    for k,v of @parent_table
      if k isnt @origin
        message["origin"] = k
        v.sendCommand command, message, cb
    undefined
