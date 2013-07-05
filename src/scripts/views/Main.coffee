#= require comm/Messaging.coffee
#= require console/Console.coffee
#= require data/ViewData.coffee

#= require Logger.coffee
#= require Tree.coffee
$ ->
  # Initialise global state
  vd = new ViewData
  vd.init()

  # Setup JQUI stuff
  elements = ["#content", "#console-output", "#console", "#filelist", "#state-information"]
  setupGuiElements(e) for e in elements

  # Allow for minimisation
  $(".boxed-header .ui-icon").click(->
    $(this).toggleClass( "ui-icon-minusthick" ).toggleClass("ui-icon-plusthick")
    $(this).parents(".boxed:first").find(".boxed-content").toggle())

  # Instantiate important stuff
  hoocsd.logger = new Logger "#console-output-text", 20
  hoocsd.messaging = new Messaging "hoocsd", hoocsd.logger
  hoocsd.cli = new Console hoocsd.messaging, hoocsd.logger

  $("#console-form").submit((e) ->
    e.preventDefault
    value = $("#console-line")[0].value
    hoocsd.cli.evaluate value
    false)

  # Bind a bunch of buttons to CLI commands
  $("#controls-continue").click -> hoocsd.cli.evaluate "resume"
  $("#controls-continue-local").click -> hoocsd.cli.evaluate "resume clientOrigin"
  $("#controls-continue-remote").click -> hoocsd.cli.evaluate "resume remoteOrigin"
  $("#controls-pause").click -> hoocsd.cli.evaluate "pause"
  $("#controls-stepover").click -> hoocsd.cli.evaluate "stepover"
  $("#controls-stepinto").click -> hoocsd.cli.evaluate "stepinto"
  $("#controls-stepout").click -> hoocsd.cli.evaluate "stepout"
  $("#controls-breakpoints-disabled").click -> hoocsd.cli.evaluate "breakpointsActive false"
  $("#controls-breakpoints-enabled").click -> hoocsd.cli.evaluate "breakpointsActive true"

  # Ask for resources. Timeout is a hack so "it always works"
  setTimeout( ( ->
    hoocsd.messaging.sendMessage type: "js.ListFiles")
    250)

setupGuiElements = (element) ->
  $(element).draggable(
    handle: ".boxed-header"
    snap: true
    containment: "parent"
  )
  $(element).resizable()
