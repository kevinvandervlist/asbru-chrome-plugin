#= require Data.coffee
#= require debug/Debugger.coffee

# Base global program state structure.
d = new Data
window.asbru = d.defaultGlobalState()

# Listener for the icon it the toolbar - start of the plugin
chrome.browserAction.onClicked.addListener ->
  chrome.windows.getCurrent((win) ->
    chrome.tabs.getSelected(win.id, clickCallback))

# The callback of the above
clickCallback = (tab) ->
  if window.asbru.debugger?
    window.asbru.debugger.stopDebugging()
  else
    # WTF. Somehow this doesn't work:
    # window.asbru.debugger = new Debugger tab
    x = new Debugger tab
    window.asbru.debugger = x
