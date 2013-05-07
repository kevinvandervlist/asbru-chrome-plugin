initMessaging = (name) ->
  hoocsd.port = chrome.runtime.connect name: name
  hoocsd.port.onMessage.addListener MessageEventCallback
  sendMessage shit: "Face"

sendMessage = (message) ->
  hoocsd.port.postMessage message

MessageEventCallback = (message) ->
  if not message.type?
    console.log "Message cannot be understood. Received: "
    console.log message
    undefined
  switch message.type
    when "foo" then sendMessage message: "received"
    else console.log "Message type #{message.type} is not supported yet."
