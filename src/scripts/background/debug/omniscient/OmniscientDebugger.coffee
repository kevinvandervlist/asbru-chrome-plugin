#= require debug/omniscient/debugger.coffee

class OmniscientDebugger
  constructor: (@debugger, @parent_table) ->
    # Bind to parent
    @parent_table[window.hoocsd.omniscient] = @

    # Lookup table for extension
    @lookup_table = {}

    # All extension modules
    @dod = new debug_omniscient_debugger @, @lookup_table, @parent_table, window.hoocsd.omniscient

  sendCommand: (command, message, cb) ->
    try
      @lookup_table[command](command, message, cb)
    catch error
      console.log "Omniscient debugger: command #{command} is still unsupported."
      console.log message
      @lookup_table[command](command, message, cb)
