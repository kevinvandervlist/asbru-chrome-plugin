class comm_debugger
  constructor: (@messaging, @table) ->
    @table["debugger.paused"] = @paused
    @table["debugger.getPropertiesReply"] = @propReply
    @stateInfo = null

  # Called when the VM is paused.
  paused: (message) =>
    if @stateInfo
      @stateInfo.destroy()

    @stateInfo = new StateInformation @messaging
    @stateInfo.pausedEvent message

  propReply: (message) =>
    @stateInfo.updatePropDesc message.objectId, message.propDescArray
