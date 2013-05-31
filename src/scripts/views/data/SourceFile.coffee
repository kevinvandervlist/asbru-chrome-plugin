#= require gui/GuiBase.coffee
#= require gui/SourceFileMarkup.coffee
class SourceFile
  constructor: (file) ->
    @code = file.code
    @id = file.scriptId
    @uri = file.url
    @filename = @uri.substr(@uri.lastIndexOf("/") + 1)

    # Array to store the breakpoints
    @breakpoints = []

    # Do the actual markup stuff
    @markup = new SourceFileMarkup @filename, @id, @uri
    @markup.formatCode @code, @_toggleBreakPoint
    @markup.addToList()

    # Cache this file in the file store:
    window.hoocsd.data.files.put @id, @

  addBreakpoint: (lineNumber, breakpoint) ->
    @breakpoints[lineNumber] = breakpoint

  # Attach a click handler to enable the creation of breakpoints
  # Make sure callback is in closure because of cnt dependence
  _toggleBreakPoint: (cnt, id, uri) =>
    console.log @
    # Existing breakpoint?
    if @breakpoints[cnt]?
      @breakpoints[cnt].remove window.hoocsd.messaging
      @breakpoints[cnt] = null
    else
      window.hoocsd.messaging.sendMessage
        type: "js.setBreakpointByUrl"
        lineNumber: cnt
        url: uri
        urlRegex: null
        columnNumber: 0
        condition: null
        scriptId: @id

  # # Attach a click handler to enable the creation of breakpoints
  # # Make sure callback is in closure because of cnt dependence
  # _toggleBreakPoint: (linediv, cnt, id, uri) =>
  #   # Existing breakpoint?
  #   linediv.click =>
  #     if @breakpoints[cnt]?
  #       @breakpoints[cnt].remove window.hoocsd.messaging
  #       @breakpoints[cnt] = null
  #     else
  #       window.hoocsd.messaging.sendMessage
  #         type: "js.setBreakpointByUrl"
  #         lineNumber: cnt
  #         url: uri
  #         urlRegex: null
  #         columnNumber: 0
  #         condition: null
  #         scriptId: @id
