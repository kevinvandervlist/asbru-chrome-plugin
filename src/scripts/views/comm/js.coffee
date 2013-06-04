#= require data/Breakpoint.coffee
#= require data/SourceFile.coffee

class comm_JS
  constructor: (@messaging, @table) ->
    @table["js.ListFile"] = @listFile
    @table["js.setBreakpointSuccess"] = @setBreakpointSuccess

  listFile: (message) =>
    new SourceFile message
    @messaging.log message.url

  setBreakpointSuccess: (message) =>
    new BreakPoint message

