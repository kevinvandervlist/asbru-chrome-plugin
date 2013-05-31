class SourceFile
  constructor: (file) ->
    @code = file.code
    @id = file.scriptId
    @uri = file.url
    @filename = @uri.substr(@uri.lastIndexOf("/") + 1)

    # Array to store the breakpoints
    @breakpoints = []

    # Cache a bunch of preformatted code views
    @_formatCode()

    parentFile = window.hoocsd.data.files.put @id, @

  addBreakpoint: (lineNumber, breakpoint) ->
    @breakpoints[lineNumber] = breakpoint

  addToList: ->
    vd = new ViewData
    $("<li>#{@filename}</li>",
      id: @id
    ).click =>
      $(vd.mainContentId()).empty()
      $(vd.mainContentId()).append @formatted_code
    .appendTo "#{vd.filelistContentId()} ul"

  _formatCode: ->
    sourcelist = $("<ol></ol>")
    cnt = 0

    for line in @code.split("\n")
      linediv = $("<li></li>")
      loc = $("<pre></pre>")

      # Prevent HTML markup at all cost
      loc[0].innerText = line

      # But set a class for breakpoint indications
      linediv.addClass "file-#{@id}-line-#{cnt}"

      linediv.append loc
      sourcelist.append linediv

      #@_toggleBreakPoint.call(linediv, cnt, @id, @uri)
      @_toggleBreakPoint linediv, cnt, @id, @uri

      cnt++

    @formatted_code = sourcelist

  # Attach a click handler to enable the creation of breakpoints
  # Make sure callback is in closure because of cnt dependence
  _toggleBreakPoint: (linediv, cnt, id, uri) ->
    # Existing breakpoint?
    linediv.click =>
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
