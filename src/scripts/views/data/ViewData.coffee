#= require data/FileManager.coffee
#= require data/BreakpointManager.coffee

# Some global state for the debugger
window.asbru = {}

# Data class for some data objects
class ViewData
  constructor: ->

  init: ->
    window.asbru = @defaultGlobalState()

  defaultGlobalState: ->
    dataStores =
      files: new FileManager
      breakpoints: new BreakpointManager

    ret =
      data: dataStores
      logger: null
      messaging: null
      cli: null
      omniscient: "omniscient"

  filelistContentId: ->
    "#filelist-content"

  mainContentId: ->
    "#content-window"

  mainContentBookmarkId: ->
    "#content-window-bookmark-button"

  stateInfoId: ->
    "#state-information-panel"
