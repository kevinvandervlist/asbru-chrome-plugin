class comm_debugger
  constructor: (@messaging, @table) ->
    @table["debugger.paused"] = @paused

  # Called when the VM is paused.
  paused: (message) =>
    si = new StateInformation @messaging
    si.pausedEvent message
