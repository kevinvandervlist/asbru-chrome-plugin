class Console
  constructor: ->

  getCmd: (str) ->
    str.split(' ')[0]

  getArgs: (str) ->
    str.split(/\ (.+)?/)[1]

  evaluate: (command) ->
    cmd = @getCmd(command)
    args = @getArgs(command)
    switch cmd
      when "sendmessage" then sendMessageCmd args
      else console.log "Command #{cmd} not yet implemented"

  # Local, private stuff
  sendMessageCmd = (args) ->
    sendMessage args
