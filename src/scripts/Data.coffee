# Some global state for the debugger
window.hoocsd =
  debugging: false
  attachedTab: null
  debuggerWindow: null

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
  debug_proto_version: ->
    "1.0"

  # Debugger URL name
  debuggerURL: ->
    "views/debugger.html"
