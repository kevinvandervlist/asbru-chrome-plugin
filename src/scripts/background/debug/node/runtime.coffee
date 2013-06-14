class debug_node_runtime
  constructor: (@dbg, @debugger, @table, @cfprovider) ->
    @table["Runtime.getProperties"] = @getProperties

  getProperties: (message, callback) =>
    cb = (err, data) =>
      # Return if there are no more properties
      return undefined if not data?
      @debugger.sendMessage
        type: "debugger.getPropertiesReply"
        objectId: message.objectId
        propDescArray: data.result
        origin: message.origin

    @cfprovider.getScopeProperties message.objectId, cb
