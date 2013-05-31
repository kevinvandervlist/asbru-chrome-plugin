#= require data/ViewData.coffee
#= require gui/GuiBase.coffee
class SourceFileMarkup extends GuiBase
  constructor: (@filename, @id, @uri) ->
    @formatted_code = null
    @vd = new ViewData

  addToList: ->
    element = $("<li>#{@filename}</li>", id: @id)

    callback = =>
      $(@vd.mainContentId()).empty()
      $(@vd.mainContentId()).append @formatted_code

    element.click =>
      @click element, callback
    .appendTo "#{@vd.filelistContentId()} ul"

  # Create HTML code to represent a source file
  formatCode: (code, breakpointCallback) ->
    @formatted_code = $("<ol></ol>")
    cnt = 0

    for line in code.split("\n")
      linediv = $("<li></li>")
      loc = $("<pre></pre>")

      # Prevent HTML markup at all cost
      loc[0].innerText = line

      # But set a class for breakpoint indications
      linediv.addClass "file-#{@id}-line-#{cnt}"

      linediv.append loc
      @formatted_code.append linediv

      #@_toggleBreakPoint.call(linediv, cnt, @id, @uri)
      breakpointCallback linediv, cnt, @id, @uri

      cnt++
