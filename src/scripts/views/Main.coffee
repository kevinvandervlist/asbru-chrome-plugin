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

  $("#conditional-breakpoint-form").dialog
    autoOpen: false

  # Allow for minimisation
  $(".boxed-header .ui-icon").click(->
    $(this).toggleClass( "ui-icon-minusthick" ).toggleClass("ui-icon-plusthick")
    $(this).parents(".boxed:first").find(".boxed-content").toggle())

  # Instantiate important stuff
  asbru.logger = new Logger "#console-output-text", 20
  asbru.messaging = new Messaging "asbru", asbru.logger
  asbru.cli = new Console asbru.messaging, asbru.logger

  $("#console-form").submit((e) ->
    e.preventDefault
    value = $("#console-line")[0].value
    asbru.cli.evaluate value
    false)

  # Bind a bunch of buttons to CLI commands
  $("#controls-continue").click -> asbru.cli.evaluate "resume"
  $("#controls-continue-local").click -> asbru.cli.evaluate "resume clientOrigin"
  $("#controls-continue-remote").click -> asbru.cli.evaluate "resume remoteOrigin"
  $("#controls-pause").click -> asbru.cli.evaluate "pause"
  $("#controls-stepover").click -> asbru.cli.evaluate "stepover"
  $("#controls-stepinto").click -> asbru.cli.evaluate "stepinto"
  $("#controls-stepout").click -> asbru.cli.evaluate "stepout"
  $("#controls-breakpoints-disabled").click -> asbru.cli.evaluate "breakpointsActive false"
  $("#controls-breakpoints-enabled").click -> asbru.cli.evaluate "breakpointsActive true"

  # Ask for resources. Timeout is a hack so "it always works"
  setTimeout( ( ->
    asbru.messaging.sendMessage type: "js.ListFiles")
    250)

setupGuiElements = (element) ->
  $(element).draggable(
    handle: ".boxed-header"
    snap: true
    containment: "parent"
  )
  $(element).resizable()
