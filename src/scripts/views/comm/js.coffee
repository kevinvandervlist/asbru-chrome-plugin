class comm_JS
  constructor: (@messaging, @table) ->
    @table["js.ListFile"] = @listFile
    @table["js.setBreakpointSuccess"] = @setBreakpointSuccess

  listFile: (message) =>
    m = new SourceFile message
    @messaging.log message.url

  setBreakpointSuccess: (message) =>
    bp = new BreakPoint message
    window.hoocsd.data.breakPoints.put bp.getIdentifier(), bp
