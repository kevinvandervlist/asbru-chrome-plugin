#= require data/ViewData.coffee
#= require gui/GuiBase.coffee

class SourceFileMarkup extends GuiBase
  constructor: (@filename, @id, @uri) ->
    @formatted_code = null
    @element = null
    super()

  getFormattedCode: ->
    @formatted_code

  getSourceFileLine: ->
    @element

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

      # Put linediv and the line number in a closure...
      f = (element, line) =>
        callback = =>
          breakpointCallback line, @id, @uri

        linediv.click =>
          @click element, callback

      # ...and call it
      f linediv, cnt


      cnt++

    @element = $("<li>#{@filename}</li>", id: @id)
