#= require state/StateInformation.coffee

class StateInformationManager
  constructor: ->
    @store = []

  saveStateInformation: (stateInfo) ->
    @store[stateInfo.getContext()] = stateInfo

  deleteStateInformation: (context) ->
    @store[context].destroy()
    delete @store[context]

  exists: (context) ->
    @store[context]?
