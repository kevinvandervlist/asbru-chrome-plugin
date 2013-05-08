initMessaging = (name) ->
  hoocsd.port = chrome.runtime.connect name: name
  hoocsd.port.onMessage.addListener MessageEventCallback
  sendMessage type: "js.ListJSFiles"

sendMessage = (message) ->
  hoocsd.port.postMessage message

MessageEventCallback = (message) ->
  console.log "Received: #{message.type}"
  if not message.type?
    console.log "Message cannot be understood. Received: "
    console.log message
    undefined
  switch message.type
    when "foo" then sendMessage message: "received"
    when "js.ListJSFiles" then console.log message
    else console.log "Message type #{message.type} is not supported yet."
