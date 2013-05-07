# Incoming debug events
onEventCallback = (debuggeeId, method, params) ->
  switch method
    when "Debugger.paused" then debuggerPaused debuggeeId
    when "Debugger.scriptParsed" then scriptParsed debuggeeId, params
    else console.log "Method #{method} is still unsupported."

debuggerPaused = (debuggeeId) ->
  tabId = debuggeeId.tabId
  chrome.browserAction.setIcon(
    tabId: tabId
    path: "images/debuggerContinue.png"
  )
  chrome.browserAction.setTitle(
    tabId: tabId
    title: chrome.i18n.getMessage "resumeDesc__"
  )

scriptParsed = (debuggeeId, params) ->
  console.log params
  chrome.debugger.sendCommand(
    debuggeeId,
    "Debugger.getScriptSource",
    scriptId: params.scriptId,
    cb
  )

cb = (res) ->
  console.log res
