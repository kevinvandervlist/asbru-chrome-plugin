#= require state/StateInformation.coffee
#= require data/ViewData.coffee
#= require gui/GuiBase.coffee

class StateInformationManager extends GuiBase
  constructor: ->
    @store = []
    @contexts = []
    super()

  saveStateInformation: (stateInfo) ->
    @store[stateInfo.getContext()] = stateInfo
    @contexts.push stateInfo.getContext()
    @updateHTML()

  deleteStateInformation: (context) ->
    @store[context].destroy()
    delete @store[context]
    @contexts.splice @contexts.indexOf(context), 1

  exists: (context) ->
    @store[context]?

  updatePropDesc: (context, objectId, propDescArray) ->
    @store[context].updatePropDesc objectId, propDescArray
    @updateHTML()

  updateHTML: ->
    rootel = $(@vdata.stateInfoId())
    rootel.empty()
    list = $("<ul />")
    rootel.append list

    for ctx in @contexts
      title = $("<li><h4>#{ctx}</h4></li>")
      child = @store[ctx].updateHTML()

      list.append title
      list.append child

      title.click =>
        cb = -> child.toggle()
        @click title, cb
