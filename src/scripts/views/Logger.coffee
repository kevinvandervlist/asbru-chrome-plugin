class Logger
  constructor: (@id) ->
    @cb = new CircularBuffer 2

  log: (message) ->
    @cb.push message
    @update()

  update: ->
    f = (el, index) ->
      x.push el
    x = []
    @cb.forEach f, x

    #$(@id).append "<p>#{message}</p>"
