# Todo: refactor to socket.io counterpart to call debughelper
# Based on: https://github.com/GoogleChrome/chrome-app-samples/blob/master/telnet

class TCPClient
  constructor: (@host, @port) ->
    console.log "TODO TODO TODO"
    @callbacks =
      connect: null
      disconnect: null
      recv: null
      set: null

    @socketId = null
    @isConnected = false

  connect: (callback) ->
    # First resolve the hostname to an IP.
    dns.lookup @host, 4, (err, addr, fam) =>
      @addr = addr;
      experimental.socket.create 'tcp', {}, @_onCreate.bind(this)
      @callbacks.connect = callback;

  sendMessage: (msg, callback) ->
    @_stringToArrayBuffer "#{msg}\n", (arrayBuffer) =>
      experimental.socket.write @socketId, arrayBuffer, @_onWriteComplete
    @callbacks.sent = callback;

  addResponseListener: (callback) ->
    @callbacks.recv = callback

  disconnect: ->
    experimental.socket.disconnect @socketId
    @isConnected = false

  _onCreate: (createInfo) =>
    trow "Unable to create socket" if createInfo.socketId <= 0

    @socketId = createInfo.socketId
    experimental.socket.connect @socketId, @addr, @port, @_onConnectComplete
    @isConnected = true

  _onConnectComplete: (resultCode) =>
    setInterval @_periodicallyRead, 500

    if @callbacks.connect
      @callbacks.connect()

  _periodicallyRead: =>
    experimental.socket.read @socketId, null, @_onDataRead

  _onDataRead: (readInfo) =>
    if readInfo.resultCode > 0 and @callbacks.recv
      @_arrayBufferToString readInfo.data, (str) =>
        @callbacks.recv str

  _onWriteComplete: (writeInfo) =>
    if @callbacks.sent?
      @callbacks.sent writeInfo

  _arrayBufferToString: (buf, callback) ->
    bb = new Blob (new Uint8Array buf)
    f = new FileReader
    f.onload = (e) ->
      callback e.target.result
    f.readAsText bb

  _stringToArrayBuffer: (str, callback) ->
    bb = new Blob [str]
    f = new FileReader
    f.onload = (e) ->
      callback e.target.result
    f.readAsArrayBuffer bb

