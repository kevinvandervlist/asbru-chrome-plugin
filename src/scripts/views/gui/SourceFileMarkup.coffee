#= require data/ViewData.coffee
#= require gui/GuiBase.coffee

class SourceFileMarkup extends GuiBase
  constructor: (@filename, @id, @uri, @sourceFile) ->
    @formatted_code = null
    @element = $("<li>#{@filename}</li>", id: @id)
    super()

  # Create HTML code to represent a source file
  getFormattedCode: ->
    code = @sourceFile.getRawSourceCode()
    breakpointCallback = @sourceFile.getBreakpointCallback()

    @formatted_code = $("<ol start=\"#{@sourceFile.getOffset()}\"></ol>")
    cnt = @sourceFile.getOffset()

    for line in code.split("\n")
      linediv = $("<li></li>")
      loc = $("<pre></pre>")

      # Prevent HTML markup at all cost
      loc[0].innerText = line

      # But set a class for breakpoint indications
      linediv.addClass "file-#{@id}-line-#{cnt}"

      linediv.append loc
      @formatted_code.append linediv

      # Put linediv and the line number in a closure...
      f = (element, line) =>
        callback = =>
          breakpointCallback line, @id, @uri

        linediv.click =>
          @click element, callback

      # ...and call it
      f linediv, cnt

      cnt++

    return @formatted_code

  getSourceFileLine: ->
    @element

  show: ->
    el = $(@vdata.mainContentId())
    el.empty()
    el.append @sourceFile.getFormattedCode()
    for k,bp of @sourceFile.getBreakpoints()
      bp.setBreakpoint()
    return undefined
