#= require comm/js.coffee
#= require comm/runtime.coffee

class Messager
  constructor: (@debugger) ->
    # Lookup table for extension
    @lookup_table = {}

    # All extension modules
    @js = new comm_JS @, @lookup_table
    @runtime = new comm_Runtime @, @lookup_table

    # Register port for message passing
    chrome.runtime.onConnect.addListener @_onConnectCallback

  disconnect: ->
    @port.disconnect()

  # Send a command to the appropriate debugger
  sendCommand: (command, message, cb = null) ->
    @debugger.sendCommand command, message, cb

  sendNodeMessage: (remoteReq, cb = null) ->
    console.log "TODO: Deprecated"
    window.hoocsd.nodecomm.sendMessage remoteReq, cb

  # Send a message to the popup window
  sendMessage: (message) ->
    @port.postMessage message

  _messageEventCallback: (message) =>
    if not message.type?
      console.log "Message cannot be understood. Received: "
      console.log message
      undefined

    try
      @lookup_table[message.type](message)
    catch error
      console.log "Message type #{message.type} is not supported yet."
      console.log message
      console.log error
      @lookup_table[message.type](message)

  _onConnectCallback: (p) =>
    d = new Data
    if p.name is d.messagePortName()
      @port = p
      @port.onMessage.addListener @_messageEventCallback

  # Remove all handlers on destruction
  removeHandlers: =>
    @port.onMessage.removeListener @_messageEventCallback
    chrome.runtime.onConnect.removeListener @_onConnectCallback
