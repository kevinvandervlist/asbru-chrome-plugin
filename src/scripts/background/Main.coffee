#= require Data.coffee
#= require debug/Debugger.coffee
#= require tcp/TCPClient.coffee

# Base global program state structure.
d = new Data
window.hoocsd = d.defaultGlobalState()

# Listener for the icon it the toolbar - start of the plugin
chrome.browserAction.onClicked.addListener ->
  chrome.windows.getCurrent((win) ->
    chrome.tabs.getSelected(win.id, clickCallback))

# The callback of the above
clickCallback = (tab) ->
  if window.hoocsd.debugger?
    window.hoocsd.debugger.stopDebugging()
  else
    # WTF. Somehow this doesn't work:
    # window.hoocsd.debugger = new Debugger tab
    x = new Debugger tab
    window.hoocsd.debugger = x

window.hoocsd.nodecomm.sendMessage
  command: "attach"
