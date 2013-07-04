#= require gui/SourceFileMarkup.coffee
#= require Origin.coffee
#= require String.coffee

class SourceFile
  constructor: (fileMessage) ->
    @code = fileMessage.code
    @id = fileMessage.scriptId
    @uri = fileMessage.url
    @offset = fileMessage.offset

    @origin = fileMessage.origin
    @filename = @uri.substr(@uri.lastIndexOf("/") + 1)
    @filename = "index" if @filename is ""

    # Create an array consisting of all path elements.
    @path = @_hierarchicalArray fileMessage.url, fileMessage.origin

    # Array to store the breakpoints
    @breakpoints = []

    # Do the actual markup stuff
    @markup = new SourceFileMarkup @filename, @id, @uri, @

    @saveFile()

  # Return an array of path elements, excluding the filename
  getPath: ->
    return [].concat(@path)

  getOffset: ->
    @offset

  getSourceFileLine: ->
    @markup.getSourceFileLine()

  getFormattedCode: ->
    @markup.getFormattedCode()

  getRawSourceCode: ->
    @code

  # Return an array of breakpoints
  getBreakpoints: ->
    @breakpoints

  saveFile: ->
    # Cache this file in the file store:
    window.hoocsd.data.files.saveFile @origin, @id, @

  addBreakpoint: (lineNumber, breakpoint) ->
    @breakpoints[lineNumber] = breakpoint

  removeBreakpoint: (lineNumber, breakpoint) ->
    delete @breakpoints[lineNumber]

  getBreakpointCallback: ->
    @_toggleBreakPoint

  # Attach a click handler to enable the creation of breakpoints
  # Make sure callback is in closure because of cnt dependence
  _toggleBreakPoint: (cnt, id, uri) =>
    # Existing breakpoint?
    if @breakpoints[cnt]?
      @breakpoints[cnt].remove window.hoocsd.messaging
      @breakpoints[cnt] = null
    else
      window.hoocsd.messaging.sendMessage
        type: "js.setBreakpointByUrl"
        origin: @origin
        lineNumber: cnt
        url: uri
        urlRegex: null
        columnNumber: 0
        condition: null
        scriptId: @id

  # Uri is either a base filename, a path or an origin followed by base filename or path.
  _hierarchicalArray: (uri, origin) ->
    # Origin is removed
    ostr = new String origin
    if ostr.substringOf uri
      uri = uri.substring origin.length

    # Optional path; split at /'s
    uri = uri.split("/");

    # If a first item is an empty string, it means that it had an explicit root /. Remove it
    uri.shift() if uri[0] is ""

    # The last element is now the plain filename (only used for visualising).
    uri.pop()

    return uri
