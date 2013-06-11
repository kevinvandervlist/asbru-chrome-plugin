#= require Origin.coffee

class debug_chrome_debugger
  constructor: (@debugger, @table) ->
    @table["Debugger.paused"] = @debuggerPaused
    @table["Debugger.resumed"] = @debuggerResumed
    @table["Debugger.scriptParsed"] = @scriptParsed

  # Event that the execution is paused
  debuggerPaused: (debuggeeId, params) =>
    # Put an overlay on the debugged tab
    message =
      message: chrome.i18n.getMessage "pausedMessage"
    @debugger.sendCommand "Debugger.setOverlayMessage", message
    # Push the data to the frontend
    @debugger.sendMessage
      type: "debugger.paused"
      callFrames: params.callFrames
      reason: params.reason
      data: params.data
      origin: window.hoocsd.clientOrigin

  # Event indicating that the execution is resumed
  debuggerResumed: (debuggeeId, params) =>
    @debugger.sendCommand "Debugger.setOverlayMessage"

  # Catch emitted events regarding JS files. This happens on attaching the debugger
  scriptParsed: (debuggeeId, params) =>
    chrome.debugger.sendCommand(
      debuggeeId,
      "Debugger.getScriptSource",
      scriptId: params.scriptId,
      @_cacheParsedScript.bind(null, params))

  # ...make sure the script is cached as well
  _cacheParsedScript: (params, resource) =>
    origin = Origin.createOriginFromUri params.url
    file = @_createFile params.scriptId, origin, params.url, resource.scriptSource
    window.hoocsd.files.saveFile origin, params.scriptId, file

  _createFile: (scriptId, origin, url, code) ->
    scriptId: scriptId
    origin: origin
    url: url
    code: code
