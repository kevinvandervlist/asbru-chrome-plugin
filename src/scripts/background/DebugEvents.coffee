# Debugger events
chrome.debugger.onEvent.addListener ((debuggeeId, method, params) ->
  switch method
    when "Debugger.paused" then debuggerPaused debuggeeId
    when "Debugger.scriptParsed" then scriptParsed debuggeeId, params
    else console.log "Method #{method} is still unsupported.")

# Update UI state on pause
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

# Catch emitted events regarding JS files
scriptParsed = (debuggeeId, params) ->
  chrome.debugger.sendCommand(
    debuggeeId,
    "Debugger.getScriptSource",
    scriptId: params.scriptId,
    cacheParsedScript.bind(null, params))

cacheParsedScript = (params, resource) ->
  hoocsd.jsFiles.push (
    scriptId: params.scriptId
    url: params.url
    code: resource.scriptSource)