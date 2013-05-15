class Messaging
  constructor: (@portName, @logger) ->
    # Lookup table for extension
    @lookup_table = {}

    # All extension modules
    @js = new comm_JS @, @lookup_table

    # Finally open up connection port and add a listener
    @port = chrome.runtime.connect name: @portName
    @port.onMessage.addListener (m) => @_MessageEventCallback m

  sendMessage: (message) ->
    @port.postMessage message

  log: (message) ->
    @logger.log message

  _MessageEventCallback: (message) ->
    @logger.log "Received: #{message.type}"
    if not message.type?
      @logger.log "Message cannot be understood..."
      console.log message
      undefined

    try
      @lookup_table[message.type] message
    catch error
      @logger.log "Message type #{message.type} is not supported yet."
      console.log "Message type #{message.type} is not supported yet."
      console.log message
