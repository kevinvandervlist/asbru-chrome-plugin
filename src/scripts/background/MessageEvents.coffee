# Register port for message passing
chrome.runtime.onConnect.addListener ((port) ->
  if port.name is "hoocsd"
    hoocsd.port = port
    port.onMessage.addListener MessageEventCallback)

sendMessage = (message) ->
  hoocsd.port.postMessage message

MessageEventCallback = (message) ->
  console.log "Message received: "
  console.log message
  hoocsd.port.postMessage type: "Hello!"
