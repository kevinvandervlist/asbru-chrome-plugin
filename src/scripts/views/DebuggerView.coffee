$ ->
  # Initialise global state
  vd = new ViewData
  vd.init()

  # Setup JQUI stuff
  elements = ["#content", "#console-output", "#console", "#filelist"]
  setupGuiElements(e) for e in elements

  # Allow for minimisation
  $(".boxed-header .ui-icon").click(->
    $(this).toggleClass( "ui-icon-minusthick" ).toggleClass("ui-icon-plusthick")
    $(this).parents(".boxed:first").find(".boxed-content").toggle())

  # Instantiate important stuff
  hoocsd.logger = new Logger "#console-output-text", 20
  hoocsd.messaging = new Messaging "hoocsd", hoocsd.logger
  hoocsd.cli = new Console hoocsd.messaging, hoocsd.logger

  # Ask for resources
  hoocsd.messaging.sendMessage type: "ListFiles"

  $("#console-form").submit((e) ->
    e.preventDefault
    value = $("#console-line")[0].value
    hoocsd.cli.evaluate value
    false)

setupGuiElements = (element) ->
  $(element).draggable(
    handle: ".boxed-header"
    snap: true
    containment: "parent"
  )
  $(element).resizable()
