#= require data/FileManager.coffee
#= require data/BreakpointManager.coffee

# Some global state for the debugger
window.hoocsd = {}

# Data class for some data objects
class ViewData
  constructor: ->
    dataStores =
      files: new FileManager
      breakpoints: new BreakpointManager

    @state =
      data: dataStores
      logger: null
      messaging: null
      cli: null
      omniscient: "omniscient"

  filelistContentId: ->
    "#filelist-content"

  mainContentId: ->
    "#content-window"

  stateInfoId: ->
    "#state-information-panel"
