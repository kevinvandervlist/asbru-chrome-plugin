class StateInformation
  constructor: (@messaging) ->
    vd = new ViewData
    @divid = vd.stateInfoId()

  # pausedevent:
  # https://developers.google.com/chrome-developer-tools/docs/protocol/tot/debugger#event-paused
  pausedEvent: (pe) ->
    @messaging.log "Inited for div #{@divid}"
    # console.log message
    # # Array of callframes:
    # cfs = message.callFrames
    # console.log cfs
    # # Reason
    # reason = message.reason

    # # Optional "break-specific auxiliary properties."
    # if message.data?
    #   @messaging.log "break-specific auxiliary properties received!"
    #   console.log message.data

    # # What to do with an individual callframe:
    # analyze_cf = (cf) =>
    #   #if cf
    #   console.log "Functionname: #{cf.functionName}"
    #   @messaging.sendMessage
    #     type: "Runtime.getProperties"
    #     objectId: cf.this.objectId
    #     ownProperties: true

    # analyze_cf cf for cf in cfs

