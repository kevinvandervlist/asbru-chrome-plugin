# Detach debugger callback
chrome.debugger.onDetach.addListener onDetachCallback

# Listener for the icon it the toolbar
chrome.browserAction.onClicked.addListener ->
  chrome.windows.getCurrent((win) ->
    chrome.tabs.getSelected(win.id, clickCallback))

clickCallback = (tab) ->
  debuggeeId = tabId: tab.id
  hoocsd.attachedTab = tab
  if hoocsd.debugging then stopDebugging debuggeeId else startDebugging debuggeeId

# Attach debugger and open main window
startDebugging = (debuggeeId) ->
  data = new Data

  window.hoocsd = data.defaultGlobalState()
  hoocsd.debugging = true

  chrome.debugger.attach(
    debuggeeId
    data.debugProtoVersion()
    onDebuggerAttached.bind(null, debuggeeId))

  chrome.windows.create(
    data.debuggerPopup()
    ((w) -> hoocsd.debuggerWindow = w))

# Debugger attachment callback
onDebuggerAttached = (debuggeeId) ->
  if chrome.runtime.lastError
    console.log chrome.runtime.lastError.message
    null

  tabId = debuggeeId.tabId

  chrome.browserAction.setIcon(
    tabId: tabId
    path: "images/debuggerPausing.png")

  chrome.browserAction.setTitle(
    tabId: tabId
    title: chrome.i18n.getMessage "pauseDesc")

  chrome.debugger.sendCommand(
    debuggeeId,
    "Debugger.enable",
    {},
    onDebuggerEnabled.bind(null, debuggeeId))

# callback for enabling the debugger. Pause ASAP
onDebuggerEnabled = (debuggeeId) ->
  chrome.debugger.sendCommand(debuggeeId, "Debugger.pause")

stopDebugging = (debuggeeId) ->
  chrome.windows.remove hoocsd.debuggerWindow.id
  chrome.debugger.detach(debuggeeId, onDetachCallback.bind(null, debuggeeId))
  hoocsd.debugging = false

# Debugger is detached event
onDetachCallback = (debuggeeId) ->
  tabId = debuggeeId.tabId
  chrome.browserAction.setIcon(
    tabId: tabId
    path: "images/debuggerPause.png")

  chrome.browserAction.setTitle(
    tabId: tabId
    title: chrome.i18n.getMessage "pauseDesc")
