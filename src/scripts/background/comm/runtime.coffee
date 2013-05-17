class comm_Runtime
  constructor: (@messager, @table) ->
    @table["Runtime.getProperties"] = @getProperties

  # Get some kind of properties
  # https://developers.google.com/chrome-developer-tools/docs/protocol/tot/runtime#command-getProperties
  getProperties: (message) =>
    cb = (res) =>
      console.log res

    cm =
      objectId: message.objectId
      ownProperties: message.ownProperties

    @messager.sendCommand "Runtime.getProperties", cm, cb
