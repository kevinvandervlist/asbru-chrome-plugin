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

class Debugger
  constructor: (@tab) ->
    # debuggeeId:
    @tabid = tabId: tab.id

    # onDetach debugger callback. TODO: Remove when done
    chrome.debugger.onDetach.addListener @_onDetachCallback

    # Attach debugger and open main interface window
    @data = new Data

    # make sure global debugger state is clean
    window.hoocsd = @data.defaultGlobalState()

    # Attach the debugger and a callback
    chrome.debugger.attach(
      @tabid
      @data.debugProtoVersion()
      @_onDebuggerAttached.bind(null, @tabid))

    # Bind this to the correct scope
    f = (w) =>
      @debuggerWindow = w

    chrome.windows.create(
      @data.debuggerPopup()
      f)

  # Call this to stop the whole debugging session
  stopDebugging: ->
    chrome.windows.remove @debuggerWindow.id
    chrome.debugger.detach(@tabid, @_onDetachCallback.bind(null, @tabid))

  # Debugger attachment callback
  _onDebuggerAttached: (debuggeeId) ->
    if chrome.runtime.lastError
      console.log chrome.runtime.lastError.message
      null

    chrome.browserAction.setIcon(
      tabId: debuggeeId.tabId
      path: "images/debuggerPausing.png")

    chrome.browserAction.setTitle(
      tabId: debuggeeId.tabId
      title: chrome.i18n.getMessage "pauseDesc")

    # Finally enable it straight away.
    f = (debuggeeId) ->
      chrome.debugger.sendCommand(debuggeeId, "Debugger.pause")

    chrome.debugger.sendCommand(
      debuggeeId,
      "Debugger.enable",
      {},
      f.bind(null, debuggeeId))

  # Debugger is detached event
  _onDetachCallback: (debuggeeId) ->
    chrome.browserAction.setIcon(
      tabId: debuggeeId.tabId
      path: "images/debuggerPause.png")

    chrome.browserAction.setTitle(
      tabId: debuggeeId.tabId
      title: chrome.i18n.getMessage "pauseDesc")
    window.hoocsd.debugger = null
