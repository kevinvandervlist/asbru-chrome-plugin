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
    @showBreakpoint stateInfo

  deleteAllStateInformation: ->
    for origin,x of @store
      @deleteStateInformation origin

  deleteStateInformation: (origin) ->
    @store[origin].destroy()
    delete @store[origin]

  exists: (origin) ->
    @store[origin]?

  updatePropDesc: (origin, objectId, propDescArray) ->
    @store[origin].updatePropDesc objectId, propDescArray
    # Make sure to update the view as soon as we received the data
    @updateHTML()

  # Show the source file in which the vm stopped as well as a visual marker on the specific line
  # Kind of hacky though...
  showBreakpoint: (si) ->
    loc = si.breakpointHitLocation()
    window.hoocsd.data.files.showBreakpointAndSourceFile loc.file, loc.scriptId, loc.line

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

      closure = =>
        title.click =>
          cb = -> child.toggle()
          @click title, cb
      closure()
