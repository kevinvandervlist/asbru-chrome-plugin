#= require debug/node/debugger.coffee

class NodeDebugger
  constructor: (@debugger, @parent_table, @remoteOrigin) ->
    # Bind to parent
    @parent_table[@remoteOrigin] = @

    # Lookup table for extension
    @lookup_table = {}

    # All extension modules
    @node_debugger = new debug_node_debugger @, @messager, @lookup_table

    # Request scripts from remote location, since these are not automatically emitted.
    @_remoteScripts @remoteOrigin

  sendCommand: (command, message, cb) ->
    try
      @lookup_table[command](message, cb)
    catch error
      console.log "Node debugger: command #{command} is still unsupported."
      console.log message
      @lookup_table[command](message, cb)

  _sendCommand: (message, callback) ->
    console.log message
    window.hoocsd.nodecomm.sendMessage message, callback

  _createFile: (scriptId, origin, url, code) ->
    scriptId: scriptId
    origin: origin
    url: url
    code: code

  _remoteScripts: (origin) ->
    request =
      type: "request"
      command: "scripts"
      arguments:
        includeSource: true

    cb = (response) =>
      for element in response.body
        file = @_createFile element.id, origin, element.name, element.source
        window.hoocsd.files.saveFile origin, element.id, file

    @_sendCommand request, cb
