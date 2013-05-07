chrome.debugger.onEvent.addListener(onEventCallback)
chrome.debugger.onDetach.addListener(onDetachCallback)

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
  hoocsd.debugging = true
  data = new Data

  chrome.debugger.attach(
    debuggeeId
    data.debug_proto_version()
    onDebuggerAttached.bind(null, debuggeeId)
  )

  chrome.windows.create(
    data.debuggerPopup()
    ((window) ->
      hoocsd.debuggerWindow = window
      str = new String data.debuggerURL()
      for view in chrome.extension.getViews()
        do (view) ->
          if str.substringOf view.location.href
            hoocsd.debuggerView = view
    )
  )

# Debugger attachment callback
onDebuggerAttached = (debuggeeId) ->
  if chrome.runtime.lastError
    console.log chrome.runtime.lastError.message
    null

  tabId = debuggeeId.tabId

  chrome.browserAction.setIcon(
    tabId: tabId
    path: "images/debuggerPausing.png"
  )
  chrome.browserAction.setTitle(
    tabId: tabId
    title: chrome.i18n.getMessage "pauseDesc"
  )

  chrome.debugger.sendCommand(
    debuggeeId,
    "Debugger.enable",
    {},
    onDebuggerEnabled.bind(null, debuggeeId)
  )

# callback for enabling the debugger. Pause ASAP
onDebuggerEnabled = (debuggeeId) ->
  chrome.debugger.sendCommand(debuggeeId, "Debugger.pause")


stopDebugging = (debuggeeId) ->
  hoocsd.debugging = false
  hoocsd.attachedTab = null
  hoocsd.debuggerWindow = null
  chrome.windows.remove hoocsd.debuggerWindow.id
  chrome.debugger.detach(debuggeeId, onDetachCallback.bind(null, debuggeeId));

# Debugger is detached event
onDetachCallback = (debuggeeId) ->
  tabId = debuggeeId.tabId
  chrome.browserAction.setIcon(
    tabId: tabId
    path: "images/debuggerPause.png"
  )
  chrome.browserAction.setTitle(
    tabId: tabId
    title: chrome.i18n.getMessage "pauseDesc"
  )
