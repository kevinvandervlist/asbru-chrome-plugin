#= require gui/GuiBase.coffee

class BreakPointMarkup extends GuiBase
  constructor: (@id, @lineNumber) ->
    super()

  setBreakpoint: ->
    console.log "Set breakpoint"
    line = $(".file-#{@id}-line-#{@lineNumber}")
    line.addClass "selected-item"

  removeBreakpoint: ->
    line = $(".file-#{@id}-line-#{@lineNumber}")
    line.removeClass "selected-item"
