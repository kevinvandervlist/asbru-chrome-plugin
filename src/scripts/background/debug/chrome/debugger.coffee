#= require Origin.coffee

class debug_chrome_debugger
  constructor: (@debugger, @table) ->
    @table["Debugger.paused"] = @debuggerPaused
    @table["Debugger.resumed"] = @debuggerResumed
    @table["Debugger.scriptParsed"] = @scriptParsed
    @table["Debugger.stepOver"] = @stepOver
    @table["Debugger.stepInto"] = @stepInto
    @table["Debugger.stepOut"] = @stepOut

  # Event that the execution is paused
  debuggerPaused: (debuggeeId, params) =>
    @debugger.showOverlay()
    # Push the data to the frontend
    @debugger.sendMessage
      type: "debugger.paused"
      callFrames: params.callFrames
      reason: params.reason
      data: params.data
      origin: window.hoocsd.clientOrigin

  stepOver: (debuggeeId, params) =>
    @debugger.sendCommand "Debugger.stepOver"

  stepInto: (debuggeeId, params) =>
    @debugger.sendCommand "Debugger.stepInto"

  stepOut: (debuggeeId, params) =>
    @debugger.sendCommand "Debugger.stepOut"

  # Event indicating that the execution is resumed
  debuggerResumed: (debuggeeId, params) =>
    @debugger.hideOverlay()

  # Catch emitted events regarding JS files. This happens on attaching the debugger
  scriptParsed: (debuggeeId, params) =>
    @debugger.sendCommand(
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
