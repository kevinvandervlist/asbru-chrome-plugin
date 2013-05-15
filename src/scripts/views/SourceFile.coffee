class SourceFile
  constructor: (file) ->
    @code = file.code
    @id = file.scriptId
    @uri = file.url
    @filename = @uri.substr(@uri.lastIndexOf("/") + 1)

    @_formatCode()

    window.hoocsd.files.push @

  addToList: (docid, contentid) ->
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

      linediv.append loc
      sourcelist.append linediv

      # Attach a click handler to enable the creation of breakpoints
      # Make sure callback is in closure because of cnt dependence
      f = (cnt, id, uri) ->
        linediv.click =>
          window.hoocsd.messaging.sendMessage
            type: "js.setBreakpointByUrl"
            lineNumber: cnt
            url: uri
            urlRegex: ".*"
            columnNumber: 0
            condition: ""
      f.call(linediv, cnt, @id, @uri)

      cnt++

    @formatted_code = sourcelist

