class NodeComm
  constructor: (@host) ->
    @socket = io.connect @host
    @socket.on "debug", @_onData
    @seqCounter = 1
    @callbacks = []

  sendMessage: (message, callback = null) =>
    # Add a sequence identifier and increment it afterwards
    message["seq"] = @seqCounter++

    @callbacks[message["seq"]] = callback

    @socket.emit "debug", message

    console.log "Sending: "
    console.log message

  _onData: (data) =>
    if data.request_seq? and @callbacks[data.request_seq]?
      @callbacks[data.request_seq](data)
    else
      console.log "Received data without callback: "
      console.log data

  baseURL: ->
    @host
