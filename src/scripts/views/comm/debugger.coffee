#= require state/StateInformation.coffee
#= require state/StateInformationManager.coffee

class comm_debugger
  constructor: (@messaging, @table) ->
    @table["debugger.paused"] = @paused
    @table["debugger.getPropertiesReply"] = @propReply
    @stateInfoManager = new StateInformationManager

    console.log "stateInfoManager temp hack: window.sim"
    window.sim = @stateInfoManager

  # Called when the VM is paused.
  paused: (message) =>
    console.log message
    if @stateInfoManager.exists message.origin
      @stateInfoManager.deleteStateInformation message.origin

    si = new StateInformation message.origin, @messaging, message
    @stateInfoManager.saveStateInformation si

  # If in pause a property description is requested, a reply is send back.
  # This reply needs to be bound to the stateinfo again
  propReply: (message) =>
    @stateInfoManager.updatePropDesc message.origin, message.objectId, message.propDescArray
