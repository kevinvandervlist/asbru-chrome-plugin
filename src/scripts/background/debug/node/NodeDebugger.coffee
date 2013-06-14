#= require debug/node/NodeComm.coffee
#= require debug/node/debugger.coffee
#= require debug/node/runtime.coffee

#= require debug/node/event/break.coffee

#= require debug/node/inspector_utils/CallFramesProvider.coffee

class NodeDebugger
  constructor: (@debugger, @parent_table, @remoteOrigin, @nodeProxy) ->
    # Bind to parent
    @parent_table[@remoteOrigin] = @

    # Lookup and callback table for extension
    @lookup_table = {}
    @event_table = {}

    # Handle communications with the node proxy
    @nodecomm = new NodeComm @nodeProxy
    @nodecomm.setGenericCallback @_eventHandler

    # CF provider for node <-> chrome translation
    @cfprovider = new CallFramesProvider @

    # All extension modules
    @node_debugger = new debug_node_debugger @, @debugger, @lookup_table
    @node_runtime = new debug_node_runtime @, @debugger, @lookup_table, @cfprovider

    # Extensions for events
    @event_break = new debug_node_event_break @, @debugger, @event_table, @cfprovider

    # Request scripts from remote location, since these are not automatically emitted.
    @_remoteScripts @remoteOrigin

  # This is called when the debugger is closed.
  # Use it to clean up state
  destroy: ->
    @node_debugger.removeAllBreakpoints()

  origin: ->
    @remoteOrigin

  sendCommand: (command, message, cb) ->
    try
      @lookup_table[command](message, cb)
    catch error
      console.log "Node debugger: command #{command} is still unsupported."
      console.log message
      @lookup_table[command](message, cb)

  _sendCommand: (message, callback) ->
    @nodecomm.sendMessage message, callback

  _eventHandler: (data) =>
    if data.type is "event"
      try
        @event_table[data.event](data)
      catch error
        console.log "NodeDebugger: event #{data.event} is still unsupported."
        console.log data
        @event_table[data.event](data)
    else
      console.log "_eventHandler: unhandled type #{data.type}. Raw:"
      console.log data

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
