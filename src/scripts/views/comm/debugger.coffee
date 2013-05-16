class comm_debugger
  constructor: (@messaging, @table) ->
    @table["debugger.paused"] = @paused

  # Called when the VM is paused.
  paused: (message) =>
    # Array of callframes:
    cfs = message.callFrames
    console.log cfs
    # Reason
    reason = message.reason

    # Optional "break-specific auxiliary properties."
    if message.data?
      @messaging.log "break-specific auxiliary properties received!"
      console.log message.data

    @messaging.sendMessage
      type: "runtime.getProperties"
      cfs: cfs
