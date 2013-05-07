# Register port for message passing
chrome.runtime.onConnect.addListener ((port) ->
  if port.name is "hoocsd"
    hoocsd.port = port
    port.onMessage.addListener onMessageCallback)

onMessageCallback = (message) ->
  console.log "Message received: "
  console.log message
  hoocsd.port.postMessage foo: "bar"
