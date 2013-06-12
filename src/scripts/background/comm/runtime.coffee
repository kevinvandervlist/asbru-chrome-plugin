class comm_Runtime
  constructor: (@messager, @table) ->
    @table["Runtime.getProperties"] = @getProperties

  # Get some kind of properties
  # Return the info via a callback and message send
  # https://developers.google.com/chrome-developer-tools/docs/protocol/tot/runtime#command-getProperties
  getProperties: (message) =>
    cb = (res) =>
      # Return if there are no more properties
      return undefined if not res?
      @messager.sendMessage
        type: "debugger.getPropertiesReply"
        objectId: message.objectId
        propDescArray: res.result
        origin: message.origin
    cm =
      objectId: message.objectId
      ownProperties: message.ownProperties
      origin: message.origin

    @messager.sendCommand "Runtime.getProperties", cm, cb

