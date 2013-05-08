# Register port for message passing
chrome.runtime.onConnect.addListener ((port) ->
  if port.name is "hoocsd"
    hoocsd.port = port
    port.onMessage.addListener MessageEventCallback)

sendMessage = (message) ->
  console.log "Sending message #{message.type}:"
  console.log message
  hoocsd.port.postMessage message

MessageEventCallback = (message) ->
  if not message.type?
    console.log "Message cannot be understood. Received: "
    console.log message
    undefined
  else switch message.type
    when "js.ListJSFiles" then js_ListJSFiles message
    else console.log "Message type #{message.type} is not supported yet."
