#= require debug/chrome/debugger.coffee
#= require debug/chrome/runtime.coffee

class ChromeDebugger
  constructor: (@debugger, @parent_table, @tabid) ->
    # Bind to parent
    @parent_table[window.hoocsd.clientOrigin] = @

    # Lookup table for extension
    @lookup_table = {}

    # Dependencies
    @data = new Data

    # All extension modules
    @dcj = new debug_chrome_debugger @, @lookup_table
    @dcr = new debug_chrome_runtime @, @lookup_table

    # Bind an eventlistener
    chrome.debugger.onEvent.addListener @_onEventCallback

  sendCommand: (command, message, cb = null) ->
    chrome.debugger.sendCommand @tabid, command, message, cb

  showOverlay: (message) ->
    @debugger.showOverlay(message)

  hideOverlay: ->
    @debugger.hideOverlay()

  # This is called when the debugger is closed.
  # Use it to clean up state
  destroy: ->

  # Forward messages to the messager
  sendMessage: (message) ->
    @debugger.sendMessage message

  # Callbakc for chrome events
  _onEventCallback: (debuggeeId, method, params) =>
    try
      @lookup_table[method](debuggeeId, params)
    catch error
      console.log "ChromeDebugger: method #{method} is still unsupported."
      console.log params
      @lookup_table[method](debuggeeId, params)