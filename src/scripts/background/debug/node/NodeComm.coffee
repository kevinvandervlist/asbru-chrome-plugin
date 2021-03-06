class NodeComm
  constructor: (@host) ->
    @socket = io.connect @host
    @socket.on "debug", @_onData
    @seqCounter = 1
    @callbacks = []
    @genericCallback = null

  setGenericCallback: (callback) ->
    @genericCallback = callback

  sendMessage: (message, callback = null) =>
    # Add a sequence identifier and increment it afterwards
    message["seq"] = @seqCounter++

    @callbacks[message["seq"]] = callback

    @socket.emit "debug", message

  sendCommand: (command, callback = null) =>
    # Add a sequence identifier and increment it afterwards
    command["seq"] = @seqCounter++

    @callbacks[command["seq"]] = callback

    @socket.emit "debug", command

  _onData: (data) =>
    if data.request_seq? and @callbacks[data.request_seq]?
      cb = @callbacks[data.request_seq]
      delete @callbacks[data.request_seq]
      cb data
    else
      if @genericCallback?
        @genericCallback data
      else
        console.log "Received data without callback: "
        console.log data

  baseURL: ->
    @host
