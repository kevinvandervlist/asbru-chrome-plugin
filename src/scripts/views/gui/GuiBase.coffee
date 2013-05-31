class GuiBase
  constructor: () ->
    @vdata = new ViewData

  click: (element, callback) ->
    element.effect("highlight", {}, 100, callback);

