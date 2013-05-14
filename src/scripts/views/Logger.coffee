class Logger
  constructor: (@id, size = 50) ->
    @cb = new CircularBuffer size

  log: (message) ->
    @cb.push message
    @update()

  update: ->
    $(@id).empty()
    $(@id).append "<p>#{x}</p>" for x in @cb.toArray().reverse()
