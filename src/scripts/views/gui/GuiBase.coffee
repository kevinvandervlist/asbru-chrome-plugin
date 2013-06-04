#= require SingletonDispatcher.coffee

class GuiBase
  constructor: () ->
    @vdata = new ViewData
    @dispatcher = SingletonDispatcher.get()

  click: (element, callback) ->
    element.effect("highlight", {}, 100, callback);

