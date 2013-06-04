#= require gui/GuiBase.coffee

class BreakPointMarkup extends GuiBase
  setBreakpoint: (id, lineNumber) ->
    console.log "Set breakpoint"
    line = $(".file-#{id}-line-#{lineNumber}")
    line.addClass "selected-item"

  removeBreakpoint: (id, lineNumber) ->
    line = $(".file-#{id}-line-#{lineNumber}")
    line.removeClass "selected-item"
