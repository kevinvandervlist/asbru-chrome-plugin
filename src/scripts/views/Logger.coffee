class Logger
  constructor: (@id) ->

  log: (message) ->
    $(@id).append "<p>#{message}</p>"
