class comm_debugger
  constructor: (@messager, @table) ->
    @table["Debugger.stepOver"] = @stepOver
    @table["Debugger.stepInto"] = @stepInto
    @table["Debugger.stepOut"] = @stepOut

  stepOver: (message) =>
    @messager.sendCommand "Debugger.stepOver", message

  stepInto: (message) =>
    @messager.sendCommand "Debugger.stepInto", message

  stepOut: (message) =>
    @messager.sendCommand "Debugger.stepOut", message
