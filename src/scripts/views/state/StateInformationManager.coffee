#= require state/StateInformation.coffee
#= require data/ViewData.coffee
#= require gui/GuiBase.coffee

class StateInformationManager extends GuiBase
  constructor: ->
    @store = []
    @origins = []
    super()

  saveStateInformation: (stateInfo) ->
    @store[stateInfo.getOrigin()] = stateInfo
    @origins.push stateInfo.getOrigin()
    @updateHTML()

  deleteStateInformation: (origin) ->
    @store[origin].destroy()
    delete @store[origin]
    @origins.splice @origins.indexOf(origin), 1

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

    for ctx in @origins
      title = $("<li><h4>#{ctx}</h4></li>")
      child = @store[ctx].updateHTML()

      list.append title
      list.append child

      title.click =>
        cb = -> child.toggle()
        @click title, cb
