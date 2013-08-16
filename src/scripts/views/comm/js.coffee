#= require data/Breakpoint.coffee
#= require data/SourceFile.coffee

class comm_JS
  constructor: (@messaging, @table) ->
    @table["js.ListFile"] = @listFile
    @table["js.newFilesAvailable"] = @newFilesAvailable
    @table["js.ListFileComplete"] = @listFileComplete
    @table["js.setBreakpointSuccess"] = @setBreakpointSuccess

  listFile: (message) =>
    new SourceFile message
    # TODO: Keep this log console thing?
    #@messaging.log message.url

  listFileComplete: (message) =>
    # TODO: Hack.
    # If all source files are pushed to the client, this function is called.
    # It is triggered by a comm message containing "js.ListFileComplete"...
    window.asbru.data.files.markup.updateFileListing()

  newFilesAvailable: (message) =>
    # TODO: hack
    # There are new files at the backend.
    # Again, this is an ugly hack
    asbru.messaging.sendMessage
      type: "js.ListFiles"

  setBreakpointSuccess: (message) =>
    console.log message
    new BreakPoint message

