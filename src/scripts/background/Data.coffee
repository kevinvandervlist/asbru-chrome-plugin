#= require node/NodeComm.coffee
#= require FileManager.coffee

# Some global state for the debugger
window.hoocsd = {}

# Data class for some data objects
class Data
  debuggerPopup: ->
    data =
      url: chrome.extension.getURL("views/debugger.html")
      top: 0
      left: 0
      width: 800
      height: 600

  # Chrome debug protocol version
  debugProtoVersion: ->
    "1.0"

  # Debugger URL name
  debuggerURL: ->
    "views/debugger.html"

  # Default global state
  defaultGlobalState: (origin = "file://") ->
    port: null
    files: new FileManager
    debugger: null
    context: null
    clientOrigin: Origin.createOriginFromUri(origin)
    nodecomm: new NodeComm "http://localhost:8080/"

  # Message passing port name
  messagePortName: ->
    "hoocsd"
