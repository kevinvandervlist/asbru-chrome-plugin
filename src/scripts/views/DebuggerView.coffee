$ ->
  window.hoocsd = {}
  hoocsd.logger = new Logger "#console-output"
  hoocsd.messaging = new Messaging "hoocsd", hoocsd.logger
  hoocsd.cli = new Console hoocsd.messaging, hoocsd.logger

  hoocsd.messaging.sendMessage type: "js.ListJSFiles"

  $("#console-form").submit((e) ->
    e.preventDefault
    value = $("#console-line")[0].value
    hoocsd.cli.evaluate value
    false)

  hoocsd.messaging.sendMessage type: "js.ListJSFiles"
