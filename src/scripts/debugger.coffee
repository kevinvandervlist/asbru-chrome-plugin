attachedTabs = {}
debug_proto_version = "1.0"
newTab = -1

chrome.debugger.onEvent.addListener(onEvent)
chrome.debugger.onDetach.addListener(onDetach)

chrome.browserAction.onClicked.addListener ->
  chrome.windows.getCurrent((win) ->
    chrome.tabs.getSelected(win.id, actionClicked))

actionClicked = (tab) ->
  tabId = tab.id
  debuggeeId =
    tabId: tabId

  if attachedTabs[tabId] is "pausing"
    null

  if not attachedTabs[tabId]
    chrome.tabs.create(
      url: chrome.extension.getURL("views/debugger.html")
      ((tab) ->
        newTab = tab
        console.log tab
      )
    )
    chrome.debugger.attach(debuggeeId, debug_proto_version, onAttach.bind(null, debuggeeId))
  else if attachedTabs[tabId]
    chrome.tabs.remove newTab.id
    chrome.debugger.detach(debuggeeId, onDetach.bind(null, debuggeeId));

onAttach = (debuggeeId) ->
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
  attachedTabs[tabId] = "pausing"
  chrome.debugger.sendCommand(
      debuggeeId, "Debugger.enable", {},
      onDebuggerEnabled.bind(null, debuggeeId)
  )

onDebuggerEnabled = (debuggeeId) ->
  chrome.debugger.sendCommand(debuggeeId, "Debugger.pause")

onEvent = (debuggeeId, method) ->
  tabId = debuggeeId.tabId
  console.log method
  if method is "Debugger.paused"
    attachedTabs[tabId] = "paused"
    chrome.browserAction.setIcon(
      tabId: tabId
      path: "images/debuggerContinue.png"
    )
    chrome.browserAction.setTitle(
      tabId: tabId
      title: chrome.i18n.getMessage "resumeDesc__"
    )

onDetach = (debuggeeId) ->
  console.log "Detaching"
  tabId = debuggeeId.tabId
  delete attachedTabs[tabId]
  chrome.browserAction.setIcon(
    tabId: tabId
    path: "images/debuggerPause.png"
  )
  chrome.browserAction.setTitle(
    tabId: tabId
    title: chrome.i18n.getMessage "pauseDesc"
  )
