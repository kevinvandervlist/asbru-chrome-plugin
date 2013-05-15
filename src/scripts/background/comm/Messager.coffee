class Messager
  constructor: (@debugger) ->
    # Dependencies
    @js = new comm_JS @

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

    switch message.type
      when "js.ListFiles" then @js.ListFiles message
      when "js.setBreakpointByUrl" then @js.setBreakpointByUrl message
      else console.log "Message type #{message.type} is not supported yet."
