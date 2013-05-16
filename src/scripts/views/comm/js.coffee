class comm_JS
  constructor: (@messaging, @table) ->
    @table["js.ListFile"] = @listFile
    @table["js.setBreakpointSuccess"] = @setBreakpointSuccess

  listFile: (message) =>
    m = new SourceFile message
    m.addToList()
    @messaging.log message.url

  setBreakpointSuccess: (message) =>
    window.hoocsd.breakPoints.push new BreakPoint message
