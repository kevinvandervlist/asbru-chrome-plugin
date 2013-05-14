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
    s = @code.split("\n")
    parent = $("<ol></ol>")

    for line in s
      linediv = $("<li></li>")
      loc = $("<pre></pre>")

      # Prevent HTML markup at all cost
      loc[0].innerText = line

      linediv.append loc
      parent.append linediv
    @formatted_code = parent
