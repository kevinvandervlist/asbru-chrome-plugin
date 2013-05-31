class BreakPoint
  constructor: (message) ->
    @breakpointId = message.breakpointId
    @columnNumber = message.columnNumber
    @lineNumber = message.lineNumber
    @scriptId = message.scriptId

    line = $(".file-#{@scriptId}-line-#{@lineNumber}")
    line.addClass "selected-item"

    parentFile = window.hoocsd.data.files.get @scriptId
    parentFile.addBreakpoint @lineNumber, @

  remove: (messaging) ->
    line = $(".file-#{@scriptId}-line-#{@lineNumber}")
    line.removeClass "selected-item"
    messaging.sendMessage
      type: "js.removeBreakpoint"
      breakpointId: @breakpointId

  getIdentifier: ->
    @breakpointId
