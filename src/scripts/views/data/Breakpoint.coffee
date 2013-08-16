#= require gui/BreakPointMarkup.coffee
#= require Origin.coffee

class BreakPoint
  constructor: (message) ->
    @breakpointId = message.breakpointId
    @columnNumber = message.columnNumber
    @lineNumber = message.lineNumber
    @scriptId = message.scriptId
    @origin = message.origin
    @condition = message.condition

    @markup = new BreakPointMarkup @scriptId, @lineNumber
    @markup.setBreakpoint()



    # Get the parent file and register the breakpoint with it
    parentFile = window.asbru.data.files.getFile @scriptId, @origin
    parentFile.addBreakpoint @lineNumber, @

    @saveBreakpoint()

  saveBreakpoint: ->
    window.asbru.data.breakpoints.saveBreakpoint @origin, @getIdentifier(), @

  remove: (messaging) ->
    window.asbru.data.breakpoints.removeBreakpoint @origin, @getIdentifier()
    @markup.removeBreakpoint()
    messaging.sendMessage
      type: "js.removeBreakpoint"
      breakpointId: @breakpointId
      origin: @origin

  getIdentifier: ->
    @breakpointId

  setBreakpoint: ->
    @markup.setBreakpoint()

  getCondition: ->
    @condition
