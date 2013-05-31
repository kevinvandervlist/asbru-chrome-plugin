class BreakPointMarkup extends GuiBase
  constructor: ->

  setBreakpoint: (id, lineNumber) ->
    line = $(".file-#{@id}-line-#{@lineNumber}")
    line.addClass "selected-item"

  removeBreakpoint: (id, lineNumber) ->
    line = $(".file-#{@id}-line-#{@lineNumber}")
    line.removeClass "selected-item"
