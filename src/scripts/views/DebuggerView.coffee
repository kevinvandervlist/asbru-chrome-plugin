$ ->
  window.hoocsd = {}

  # Setup JQUI stuff
  elements = ["#content", "#console-output", "#console"]
  setupGuiElements(e) for e in elements

  # Allow for minimisation
  $(".boxed-header .ui-icon").click(->
    $(this).toggleClass( "ui-icon-minusthick" ).toggleClass("ui-icon-plusthick")
    $(this).parents(".boxed:first").find(".boxed-content").toggle())

  hoocsd.logger = new Logger "#console-output-text", 20
  hoocsd.messaging = new Messaging "hoocsd", hoocsd.logger
  hoocsd.cli = new Console hoocsd.messaging, hoocsd.logger

  hoocsd.messaging.sendMessage type: "js.ListJSFiles"

  $("#console-form").submit((e) ->
    e.preventDefault
    value = $("#console-line")[0].value
    hoocsd.cli.evaluate value
    false)

  hoocsd.messaging.sendMessage type: "js.ListJSFiles"

setupGuiElements = (element) ->
  $(element).draggable(
    handle: ".boxed-header"
    snap: true
    containment: "parent"
  )
  $(element).resizable()
