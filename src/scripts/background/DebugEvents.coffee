# Debugger events
chrome.debugger.onEvent.addListener ((debuggeeId, method, params) ->
  switch method
    when "Debugger.paused" then debuggerPaused debuggeeId
    when "Debugger.resumed" then debuggerResumed debuggeeId
    when "Debugger.scriptParsed" then scriptParsed debuggeeId, params
    when "Runtime.executionContextCreated" then execContextCreated params
    else
      console.log "Method #{method} is still unsupported."
      console.log params)

# Update UI state on pause
debuggerPaused = (debuggeeId) ->
  tabId = debuggeeId.tabId
  chrome.browserAction.setIcon(
    tabId: tabId
    path: "images/debuggerContinue.png"
  )
  chrome.browserAction.setTitle(
    tabId: tabId
    title: chrome.i18n.getMessage "resumeDesc"
  )
  message =
    message: chrome.i18n.getMessage "pausedMessage"
  hoocsd.debugger.sendCommand "Debugger.setOverlayMessage", message

debuggerResumed = (debuggeeId) ->
  hoocsd.debugger.sendCommand "Debugger.setOverlayMessage"

# Catch emitted events regarding JS files
scriptParsed = (debuggeeId, params) ->
  chrome.debugger.sendCommand(
    debuggeeId,
    "Debugger.getScriptSource",
    scriptId: params.scriptId,
    cacheParsedScript.bind(null, params))

cacheParsedScript = (params, resource) ->
  hoocsd.files.push (
    scriptId: params.scriptId
    url: params.url
    code: resource.scriptSource)

# Store the execution context reference
execContextCreated = (params) ->
  hoocsd.context = params.context
