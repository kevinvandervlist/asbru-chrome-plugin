#= requ gui/BreakPointMarkup.coffee

class BreakPoint
  constructor: (message) ->
    @breakpointId = message.breakpointId
    @columnNumber = message.columnNumber
    @lineNumber = message.lineNumber
    @scriptId = message.scriptId
    @origin = message.origin

    #@markup = new BreakPointMarkup @scriptId, @lineNumber
    #@markup.setBreakpoint()



    # Get the parent file and register the breakpoint with it
    parentFile = window.hoocsd.data.files.getFile @scriptId, @origin
    parentFile.addBreakpoint @lineNumber, @

    @saveBreakpoint()

  saveBreakpoint: ->
    window.hoocsd.data.breakpoints.saveBreakpoint @origin, @getIdentifier(), @

  remove: (messaging) ->
    window.hoocsd.data.breakpoints.removeBreakpoint @origin, @getIdentifier()
    #@markup.removeBreakpoint()
    messaging.sendMessage
      type: "js.removeBreakpoint"
      breakpointId: @breakpointId
      origin: @origin

  getIdentifier: ->
    @breakpointId

  setBreakpoint: ->
    #@markup.setBreakpoint()