class BreakPoint
  constructor: (message) ->
    @breakpointId = message.breakpointId
    @columnNumber = message.columnNumber
    @lineNumber = message.lineNumber
    @scriptId = message.scriptId

    line = $(".file-#{@scriptId}-line-#{@lineNumber}")
    line.css "background-color", "#BDDEFF"

    parentFile = window.hoocsd.files[@scriptId]
    parentFile.addBreakpoint @lineNumber, @

  remove: (messaging) ->
    line = $(".file-#{@scriptId}-line-#{@lineNumber}")
    line.css "background-color", ""
    messaging.sendMessage
      type: "js.removeBreakpoint"
      breakpointId: @breakpointId
