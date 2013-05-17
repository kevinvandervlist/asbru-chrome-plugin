class debug_runtime
  constructor: (@debugger, @table) ->
    @table["Runtime.executionContextCreated"] = @execContextCreated

  # Store the execution context reference
  execContextCreated: (debuggeeId, params) =>
    hoocsd.context = params.context

