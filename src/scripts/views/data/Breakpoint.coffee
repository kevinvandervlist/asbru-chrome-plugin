#= require gui/BreakPointMarkup.coffee
#= require Origin.coffee

class BreakPoint
  constructor: (message) ->
    @breakpointId = message.breakpointId
    @columnNumber = message.columnNumber
    @lineNumber = message.lineNumber
    @scriptId = message.scriptId

    @markup = new BreakPointMarkup @scriptId, @lineNumber
    @markup.setBreakpoint()

    @origin = Origin.createOriginFromUri @getIdentifier()

    # Get the parent file and register the breakpoint with it
    parentFile = window.hoocsd.data.files.getFile @scriptId
    parentFile.addBreakpoint @lineNumber, @

    @saveBreakpoint()

  saveBreakpoint: ->
    window.hoocsd.data.breakpoints.saveBreakpoint @origin, @getIdentifier(), @

  remove: (messaging) ->
    window.hoocsd.data.breakpoints.removeBreakpoint @origin, @getIdentifier()
    @markup.removeBreakpoint()
    messaging.sendMessage
      type: "js.removeBreakpoint"
      breakpointId: @breakpointId

  getIdentifier: ->
    @breakpointId
