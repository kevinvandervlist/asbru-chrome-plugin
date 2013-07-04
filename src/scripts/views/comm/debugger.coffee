#= require state/StateInformation.coffee
#= require state/StateInformationManager.coffee

class comm_debugger
  constructor: (@messaging, @table) ->
    @table["debugger.paused"] = @paused
    @table["debugger.resume"] = @resume
    @table["debugger.getPropertiesReply"] = @propReply
    @stateInfoManager = new StateInformationManager

  # Called when the VM is paused.
  paused: (message) =>
    si = new StateInformation message.origin, @messaging, message
    @stateInfoManager.saveStateInformation si

  resume: (message) =>
    if @stateInfoManager.exists message.origin
      @stateInfoManager.deleteStateInformation message.origin

  # If in pause a property description is requested, a reply is send back.
  # This reply needs to be bound to the stateinfo again
  propReply: (message) =>
    @stateInfoManager.updatePropDesc message.origin, message.objectId, message.propDescArray

