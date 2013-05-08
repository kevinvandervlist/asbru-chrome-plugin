$ ->
  window.hoocsd = {}
  initMessaging "hoocsd"

  hoocsd.f = (message) ->
    sendMessage message
