$ ->
  window.hoocsd = {}

  # Setup JQUI stuff
  $("#content").draggable(
    handle: ".boxed-header"
    snap: true
  ).resizable()
  $(".boxed-header .ui-icon").click(->
    $(this).toggleClass( "ui-icon-minusthick" ).toggleClass("ui-icon-plusthick")
    $(this).parents(".boxed:first").find(".boxed-content").toggle())

  $("#console-output").resizable()
  $("#console-output").draggable(handle: ".boxed-header").resizable()

  hoocsd.logger = new Logger "#console-output-text", 50
  hoocsd.messaging = new Messaging "hoocsd", hoocsd.logger
  hoocsd.cli = new Console hoocsd.messaging, hoocsd.logger

  hoocsd.messaging.sendMessage type: "js.ListJSFiles"

  $("#console-form").submit((e) ->
    e.preventDefault
    value = $("#console-line")[0].value
    hoocsd.cli.evaluate value
    false)

  hoocsd.messaging.sendMessage type: "js.ListJSFiles"
