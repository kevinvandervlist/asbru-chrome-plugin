class Messaging
  constructor: (@portName, @logger) ->
    @port = chrome.runtime.connect name: @portName
    @port.onMessage.addListener (m) => @_MessageEventCallback m

  sendMessage: (message) ->
    @port.postMessage message

  _MessageEventCallback: (message) ->
    @logger.log "Received: #{message.type}"
    if not message.type?
      @logger.log "Message cannot be understood. Received: "
      @logger.log message
      undefined
    switch message.type
      when "foo" then sendMessage message: "received"
      when "js.ListJSFile" then @_handleJSFile message
      else @logger.log "Message type #{message.type} is not supported yet."

  _handleJSFile: (message) ->
    @logger.log message
