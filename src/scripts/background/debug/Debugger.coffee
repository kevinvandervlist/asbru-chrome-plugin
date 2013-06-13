#= require comm/Messager.coffee
#= require debug/chrome/ChromeDebugger.coffee
#= require debug/node/NodeDebugger.coffee
#= require debug/omniscient/OmniscientDebugger.coffee

class Debugger
  constructor: (@tab) ->
    # Lookup table for origins
    @lookup_table = {}

    # debuggeeId:
    @tabid = tabId: tab.id

    # onDetach debugger callback. TODO: Remove when done
    chrome.debugger.onDetach.addListener @_onDetachCallback

    # Dependencies
    @data = new Data
    window.hoocsd = @data.defaultGlobalState(@tab.url)

    # More dependencies
    @messager = new Messager @

    # Extend for dispatching
    @chrome_dbg = new ChromeDebugger @, @lookup_table, @tabid
    @node_dbg = new NodeDebugger @, @lookup_table, @data.remoteOrigin(), @data.remoteProxy()
    @omniscient_dbg = new OmniscientDebugger @, @lookup_table

    # Attach the debugger and a callback. This makes the local debugger
    # emit "Debugger.scriptParsed" events.
    chrome.debugger.attach(
      @tabid
      @data.debugProtoVersion()
      @_onDebuggerAttached.bind(null, @tabid))

    # Bind this to the correct scope
    f = (w) =>
      @debuggerWindow = w
      chrome.windows.onRemoved.addListener @_onWindowRemoved

    chrome.windows.create(
      @data.debuggerPopup()
      f)

  # Remove all handlers on destruction
  removeHandlers: =>
    for origin, dbg of @lookup_table
      dbg.destroy()
    @messager.removeHandlers()
    chrome.windows.onRemoved.removeListener @_onWindowRemoved
    chrome.debugger.onDetach.removeListener @_onDetachCallback
    chrome.debugger.onEvent.removeListener @_onEventCallback

  # External access to the debugger. Abstract the need of @tabid away
  sendCommand: (command, message, cb = null) ->
    @lookup_table[message.origin].sendCommand command, message, cb

  # Forward messages to the messager
  sendMessage: (message) ->
    @messager.sendMessage message

  # Call this to stop the whole debugging session
  stopDebugging: ->
    # Todo: this throws an error when the window is closed via the x button
    # instead of the program icon.
    # It cannot be caught, so a harmless error is printed.
    chrome.windows.remove @debuggerWindow.id
    chrome.debugger.detach(@tabid, @_onDetachCallback.bind(null, @tabid))

  # Called when a window is removed.
  _onWindowRemoved: (w) =>
    if w is @debuggerWindow.id
      window.hoocsd.debugger.stopDebugging()

  # Debugger attachment callback
  _onDebuggerAttached: (debuggeeId) ->
    if chrome.runtime.lastError
      console.log chrome.runtime.lastError.message
      null

    chrome.browserAction.setIcon(
      tabId: debuggeeId.tabId
      path: "images/debuggerPausing.png")

    chrome.browserAction.setTitle(
      tabId: debuggeeId.tabId
      title: chrome.i18n.getMessage "pauseDesc")

    # Finally enable it straight away.
    chrome.debugger.sendCommand(
      debuggeeId
      "Runtime.enable"
      {})

    chrome.debugger.sendCommand(
      debuggeeId
      "Debugger.enable"
      {})

  # Debugger is detached event
  _onDetachCallback: (debuggeeId) ->
    chrome.browserAction.setIcon(
      tabId: debuggeeId.tabId
      path: "images/debuggerPause.png")

    chrome.browserAction.setTitle(
      tabId: debuggeeId.tabId
      title: chrome.i18n.getMessage "pauseDesc")

    # HACK: cleanup...
    window.hoocsd.debugger.messager.disconnect()
    window.hoocsd.debugger.removeHandlers()

    # ...and reset state
    window.hoocsd = d.defaultGlobalState()
