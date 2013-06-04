#= require state/StateInformation.coffee
#= require state/StateInformationManager.coffee

class comm_debugger
  constructor: (@messaging, @table) ->
    @table["debugger.paused"] = @paused
    @table["debugger.getPropertiesReply"] = @propReply
    @stateInfoManager = new StateInformationManager

  # Called when the VM is paused.
  paused: (message) =>
    console.log message
    if @stateInfoManager.exists message.origin
      @stateInfoManager.deleteStateInformation message.origin

    si = new StateInformation message.origin, @messaging
    @stateInfoManager.saveStateInformation si
    si.pausedEvent message

  # If in pause a property description is requested, a reply is send back.
  # This reply needs to be bound to the stateinfo again
  propReply: (message) =>
    @stateInfo.updatePropDesc message.objectId, message.propDescArray
