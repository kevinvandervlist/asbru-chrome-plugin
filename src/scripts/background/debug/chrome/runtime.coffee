class debug_chrome_runtime
  constructor: (@debugger, @table) ->
    @table["Runtime.executionContextCreated"] = @execContextCreated

  # Store the execution context reference
  execContextCreated: (debuggeeId, params) =>
    window.asbru.context = params.context

