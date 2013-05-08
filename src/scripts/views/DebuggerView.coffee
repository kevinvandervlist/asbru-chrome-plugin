$ ->
  window.hoocsd = {}
  hoocsd.logger = new Logger "#console-output"
  hoocsd.messaging = new Messaging "hoocsd" hoocsd.logger
  hoocsd.cli = new Console

  $("#console-form").submit((e) ->
    e.preventDefault
    value = $("#console-line")[0].value
    cli.evaluate value
    false)

  sendMessage type: "js.ListJSFiles"
