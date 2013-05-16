class debug_runtime
  constructor: (@debugger, @table) ->
    @table["Runtime.executionContextCreated"] = @execContextCreated
    @table["Runtime.getProperties"] = @getProperties

  # Store the execution context reference
  execContextCreated: (debuggeeId, params) =>
    hoocsd.context = params.context

  # Get some kind of properties
  # https://developers.google.com/chrome-developer-tools/docs/protocol/tot/runtime#command-getProperties

  getProperties: (debuggeeId, params) =>
    console.log "getProperties request received."
    console.log params
