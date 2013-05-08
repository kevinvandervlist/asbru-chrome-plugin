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
      else @logger.log "Command #{cmd} not yet implemented"

  _sendMessage: (args) ->
    try
      @messaging.sendMessage $.parseJSON args
    catch error
      @logger.log "Error: #{error}"
