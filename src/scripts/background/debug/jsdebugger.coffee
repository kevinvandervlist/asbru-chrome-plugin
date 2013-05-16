class debug_debugger
  constructor: (@debugger, @table) ->
    @table["Debugger.paused"] = @debuggerPaused
    @table["Debugger.resumed"] = @debuggerResumed
    @table["Debugger.scriptParsed"] = @scriptParsed

  # Event that the execution is paused
  debuggerPaused: (debuggeeId, params) =>
    chrome.browserAction.setIcon(
      tabId: debuggeeId.tabId
      path: "images/debuggerContinue.png"
    )
    chrome.browserAction.setTitle(
      tabId: debuggeeId.tabId
      title: chrome.i18n.getMessage "resumeDesc"
    )
    message =
      message: chrome.i18n.getMessage "pausedMessage"
    @debugger.sendCommand "Debugger.setOverlayMessage", message

  # Event indicating that the execution is resumed
  debuggerResumed: (debuggeeId, params) =>
    @debugger.sendCommand "Debugger.setOverlayMessage"

  # Catch emitted events regarding JS files
  scriptParsed: (debuggeeId, params) =>
    chrome.debugger.sendCommand(
      debuggeeId,
      "Debugger.getScriptSource",
      scriptId: params.scriptId,
      @_cacheParsedScript.bind(null, params))

  # ...make sure the script is cached as well
  _cacheParsedScript: (params, resource) ->
    hoocsd.files.push (
      scriptId: params.scriptId
      url: params.url
      code: resource.scriptSource)
