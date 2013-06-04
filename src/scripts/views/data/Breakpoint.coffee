#= require gui/BreakPointMarkup.coffee

class BreakPoint
  constructor: (message) ->
    @breakpointId = message.breakpointId
    @columnNumber = message.columnNumber
    @lineNumber = message.lineNumber
    @scriptId = message.scriptId

    @markup = new BreakPointMarkup
    @markup.setBreakpoint @scriptId, @lineNumber

    # Get the parent file and register the breakpoint with it
    parentFile = window.hoocsd.data.files.get @scriptId
    parentFile.addBreakpoint @lineNumber, @

  remove: (messaging) ->
    @markup.removeBreakpoint @scriptId, @lineNumber
    messaging.sendMessage
      type: "js.removeBreakpoint"
      breakpointId: @breakpointId

  getIdentifier: ->
    @breakpointId
