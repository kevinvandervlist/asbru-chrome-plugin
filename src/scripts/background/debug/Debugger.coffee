class Debugger
  constructor: (@tab) ->
    # Lookup table for extension
    @lookup_table = {}

    # debuggeeId:
    @tabid = tabId: tab.id

    # onDetach debugger callback. TODO: Remove when done
    chrome.debugger.onDetach.addListener @_onDetachCallback

    # Dependencies
    @data = new Data
    @messager = new Messager @

    # make sure global debugger state is clean
    window.hoocsd = @data.defaultGlobalState()

    # All extension modules
    @debugger = new debug_debugger @, @lookup_table
    @runtime = new debug_runtime @, @lookup_table

    # Attach the debugger and a callback
    chrome.debugger.attach(
      @tabid
      @data.debugProtoVersion()
      @_onDebuggerAttached.bind(null, @tabid))

    # Bind this to the correct scope
    f = (w) =>
      @debuggerWindow = w

    chrome.windows.create(
      @data.debuggerPopup()
      f)

  # Bind an eventlistener
    chrome.debugger.onEvent.addListener ((debuggeeId, method, params) =>
      try
        @lookup_table[method](debuggeeId, params)
      catch error
        console.log "Method #{method} is still unsupported."
        console.log params)

  # External access to the debugger. Abstract the need of @tabid away
  sendCommand: (command, message, cb = null) ->
    chrome.debugger.sendCommand @tabid, command, message, cb

  # Forward messages to the messager
  sendMessage: (message) ->
    @messager.sendMessage message

  # Call this to stop the whole debugging session
  stopDebugging: ->
    chrome.windows.remove @debuggerWindow.id
    chrome.debugger.detach(@tabid, @_onDetachCallback.bind(null, @tabid))

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
    window.hoocsd.debugger = null
