# Some global state for the debugger
window.hoocsd = {}

# Data class for some data objects
class ViewData
  constructor: ->

  init: ->
    window.hoocsd = @defaultGlobalState()

  defaultGlobalState: ->
    files: []
    breakPoints: []
    logger: null
    messaging: null
    cli: null

  filelistContentId: ->
    "#filelist-content"

  mainContentId: ->
    "#content-window"
