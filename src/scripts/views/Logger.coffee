class Logger
  constructor: (@id) ->
    @cb = new CircularBuffer 2

  log: (message) ->
    @cb.push message
    @update()

  update: ->
    f = (el, index) ->
      console.log "I: #{index}, el: #{el}"
    @cb.forEach f, this
    #$(@id).append "<p>#{message}</p>"
