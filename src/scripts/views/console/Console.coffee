class Console
  constructor: (@messaging, @logger) ->

  # Get a string representing only the command (e.g. arg[0]).
  getCmd: (str) ->
    str.split(' ')[0]

  # Get a single string representing everything but the command
  getArgs: (str) ->
    s = str.split(/\ (.+)?/)
    if s.length > 1 then s[1] else ""

  evaluate: (command) ->
    cmd = @getCmd(command)
    args = @getArgs(command)
    switch cmd
      when "sendmessage" then @_sendMessage args
      when "pause" then @_js_pause "js.pause"
      when "p" then @_js_pause "js.pause"
      when "resume" then @_js_resume "js.resume"
      when "r" then @_js_resume "js.resume"
      else @logger.log "Command [#{cmd}] not yet implemented"

  _sendMessage: (args) ->
    try
      @messaging.sendMessage $.parseJSON args
    catch error
      @logger.log "Error: #{error}"

  _js_resume: ->
    @messaging.sendMessage
      type: "js.resume"

  _js_pause: ->
    @messaging.sendMessage
      type: "js.pause"
