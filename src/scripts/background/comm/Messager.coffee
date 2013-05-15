class Messager
  constructor: (@debugger) ->
      # Lookup table for extension
    @lookup_table = {}

    # All extension modules
    @js = new comm_JS @, @lookup_table

    # Callback closure
    mec = (message) =>
      @_messageEventCallback message

    conn = (p) =>
      if p.name is "hoocsd"
        @port = p
        @port.onMessage.addListener mec

    # Register port for message passing
    chrome.runtime.onConnect.addListener conn

  # Send a command to the chrome debugger
  sendCommand: (command, message, cb = null) ->
    @debugger.sendCommand command, message, cb

  # Send a message to the popup window
  sendMessage: (message) ->
    @port.postMessage message

  _messageEventCallback: (message) ->
    if not message.type?
      console.log "Message cannot be understood. Received: "
      console.log message
      undefined

    try
      @lookup_table[message.type](message)
    catch error
      console.log "Message type #{message.type} is not supported yet."
      console.log message
