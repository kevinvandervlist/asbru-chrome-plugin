#= require state/StateInformation.coffee
#= require data/ViewData.coffee
#= require gui/GuiBase.coffee

class StateInformationManager extends GuiBase
  constructor: ->
    @store = []
    super()

  saveStateInformation: (stateInfo) ->
    @store[stateInfo.getOrigin()] = stateInfo
    @updateHTML()

  deleteStateInformation: (origin) ->
    @store[origin].destroy()
    delete @store[origin]

  exists: (origin) ->
    @store[origin]?

  updatePropDesc: (origin, objectId, propDescArray) ->
    @store[origin].updatePropDesc objectId, propDescArray
    # Make sure to update the view as soon as we received the data
    @updateHTML()

  updateHTML: ->
    rootel = $(@vdata.stateInfoId())
    rootel.empty()
    list = $("<ul />")
    rootel.append list

    for origin, info of @store
      title = $("<li><h4>#{origin}</h4></li>")
      child = info.updateHTML()

      list.append title
      list.append child

      title.click =>
        cb = -> child.toggle()
        @click title, cb
