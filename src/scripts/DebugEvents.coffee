# Incoming debug events
onEventCallback = (debuggeeId, method) ->
  console.log "onEventCallback"
  console.log method

  tabId = debuggeeId.tabId
  if method is "Debugger.paused"
    chrome.browserAction.setIcon(
      tabId: tabId
      path: "images/debuggerContinue.png"
    )
    chrome.browserAction.setTitle(
      tabId: tabId
      title: chrome.i18n.getMessage "resumeDesc__"
    )
