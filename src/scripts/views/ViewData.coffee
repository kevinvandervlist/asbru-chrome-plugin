# Some global state for the debugger
window.hoocsd = {}

# Data class for some data objects
class ViewData
  constructor: ->

  init: ->
    window.hoocsd = @defaultGlobalState()

  defaultGlobalState: ->
    dataStores =
      files: new DataStore
      breakPoints: new DataStore

    ret =
      data: dataStores
      logger: null
      messaging: null
      cli: null

  filelistContentId: ->
    "#filelist-content"

  mainContentId: ->
    "#content-window"

  stateInfoId: ->
    "#state-information"