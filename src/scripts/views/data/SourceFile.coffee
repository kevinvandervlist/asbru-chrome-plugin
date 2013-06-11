#= require gui/SourceFileMarkup.coffee
#= require Origin.coffee

class SourceFile
  constructor: (fileMessage) ->
    @code = fileMessage.code
    @id = fileMessage.scriptId
    @uri = fileMessage.url
    @origin = fileMessage.origin
    @filename = @uri.substr(@uri.lastIndexOf("/") + 1)
    @filename = "index" if @filename is ""

    # Array to store the breakpoints
    @breakpoints = []

    # Do the actual markup stuff
    @markup = new SourceFileMarkup @filename, @id, @uri, @

    @saveFile()

  getSourceFileLine: ->
    @markup.getSourceFileLine()

  getFormattedCode: ->
    @markup.getFormattedCode()

  getRawSourceCode: ->
    @code

  saveFile: ->
    # Cache this file in the file store:
    window.hoocsd.data.files.saveFile @origin, @id, @

  addBreakpoint: (lineNumber, breakpoint) ->
    @breakpoints[lineNumber] = breakpoint

  removeBreakpoint: (lineNumber, breakpoint) ->
    @breakpoints[lineNumber] = null

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

  _createOriginFromUri: (uri) ->
    console.log "TODO: Dead code?"
    origin = null

    switch uri.split(':')[0]
      when "file"
        origin = "file"
      when "http", "https"
        split = uri.split '/'
        splice = split.splice 0, 3
        origin = splice.join "/"
      else
        throw "origin for #{uri} is not defined"

    return origin
