class Messaging
  constructor: (@portName, @logger) ->
    @port = chrome.runtime.connect name: name
    @port.onMessage.addListener MessageEventCallback

  sendMessage: (message) ->
    hoocsd.port.postMessage message

  MessageEventCallback = (message) ->
    @logger.log "Received: #{message.type}"
    if not message.type?
      @logger.log "Message cannot be understood. Received: "
      @logger.log message
      undefined
    switch message.type
      when "foo" then sendMessage message: "received"
      when "js.ListJSFile" then @handleJSFile message
      else @logger.log "Message type #{message.type} is not supported yet."

  handleJSFile = (message) ->
    @logger.log message
