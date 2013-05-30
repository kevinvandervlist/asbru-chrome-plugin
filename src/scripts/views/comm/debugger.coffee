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

  # If in pause a property description is requested, a reply is send back.
  # This reply needs to be bound to the stateinfo again
  propReply: (message) =>
    @stateInfo.updatePropDesc message.objectId, message.propDescArray
