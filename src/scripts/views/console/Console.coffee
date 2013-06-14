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
      when "pause" then @_js_pause()
      when "p" then @_js_pause()
      when "resume" then @_js_resume()
      when "r" then @_js_resume()
      when "breakpointsActive" then @_js_breakpointsActive args
      when "stepover" then @_js_stepover()
      when "stepinto" then @_js_stepinto()
      when "stepout" then @_js_stepout()
      else @logger.log "Command [#{cmd}] not yet implemented"

  _sendMessage: (args) ->
    try
      @messaging.sendMessage $.parseJSON args
    catch error
      @logger.log "Error: #{error}"

  _js_resume: ->
    @logger.log "Resuming JavaScript execution"
    @messaging.sendMessage
      type: "js.resume"
      origin: window.hoocsd.omniscient

  _js_pause: ->
    @logger.log "Pausing JavaScript execution"
    @messaging.sendMessage
      type: "js.pause"
      origin: window.hoocsd.omniscient

  _js_breakpointsActive: (args) ->
    @logger.log "breakpointsActive #{args} given"
    @messaging.sendMessage
      type: "js.breakpointsActive"
      value: (args is "true")
      origin: window.hoocsd.omniscient

  _js_stepover: ->
    @logger.log "Stepover requested"
    @messaging.sendMessage
      type: "Debugger.stepOver"
      origin: window.hoocsd.omniscient

  _js_stepinto: ->
    @logger.log "Stepinto requested"
    @messaging.sendMessage
      type: "Debugger.stepInto"
      origin: window.hoocsd.omniscient

  _js_stepout: ->
    @logger.log "Stepout requested"
    @messaging.sendMessage
      type: "Debugger.stepOut"
      origin: window.hoocsd.omniscient
