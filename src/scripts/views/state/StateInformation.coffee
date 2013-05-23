class StateInformation
  constructor: (@messaging) ->
    vd = new ViewData
    @divid = vd.stateInfoId()
    @properties = {}
    window.prop = @properties

  # pausedevent:
  # https://developers.google.com/chrome-developer-tools/docs/protocol/tot/debugger#event-paused
  pausedEvent: (pe) =>
    reason = $("<p>Paused because of: #{pe.reason}</p>")
    $(@divid).append reason

    @tree = @_createStateTree pe.reason, pe.callFrames

    @_writeHTML()

  destroy: =>
    # Cleanup

  updatePropDesc: (objectId, propDescArray) =>
    @properties[objectId].setValue(propDescArray)

  _createStateTree: (reason, callFrames) ->
    tree = new TreeNode "JS VM State"

    stack = @_createCallStack callFrames
    tree.addChild stack

    for call in stack.getChildren()
      scopeVars = @_createScopeVariables call.getValue()
      if call.getValue().active
        tree.addChild scopeVars
      call.getValue().scopeVars = scopeVars

    #end of for
    console.log "binding tree to window.tree"
    window.tree = tree
    tree

  # get properties of an object. The returning value is an "AsyncVariable", which
  # needs to have a callback found to it.
  # If the object already exists, return an existing AsyncVariable
  _getProperties: (object) ->
    if @properties[object.objectId]?
      return @properties[object.objectId]
    else
      ret = new AsyncVariable null, null, object.objectId
      @properties[object.objectId] = ret

      @messaging.sendMessage
        type: "Runtime.getProperties"
        objectId: object.objectId
        ownProperties: true
      return ret

  # Create a callstack based on an array of callframes
  _createCallStack: (callFrames) ->
    tree = new TreeNode
      title: "Call Stack"
      type: "callstack"
    active = true

    for cf in callFrames
      if cf.functionName isnt ""
        functionName = cf.functionName
      else
        functionName = "(anonymous function)"

      id = cf.location.scriptId
      file = window.hoocsd.data.files.get id
      fileName = file.filename

      lineNumber = cf.location.lineNumber

      tree.addChild new TreeNode
        functionName: functionName
        fileName: fileName
        lineNumber: lineNumber
        callFrame: cf
        scopeVars: null
        active: active
        type: "callstack"

      # Only the first item should be active
      if active
        active = false
    return tree

  _createScopeVariables: (callStackNode) ->
    tree = new TreeNode
      title: "Scope Variables"
      type: "scopevariables"

    frame = callStackNode.callFrame
    chain = frame.scopeChain

    for scope in chain
      title = null
      subtitle = scope.object.description
      extraProperties = null
      # Handle according to the frame type
      switch scope.type
        when "local"
          title = "Local"
          subtitle = null
          if frame.this
            extraProperties = @_getProperties frame.this
        when "closure"
          title = "Closure"
          subtitle = null
        when "catch"
          title = "Catch"
          subtitle = null
        when "with"
          title = "With block"
        when "global"
          title = "Global"

      remoteObject = @_getProperties scope.object
      n = new TreeNode
        title: title
        subtitle: subtitle
        extraProperties: extraProperties
        remoteObject: remoteObject
        type: "scopevariables"
      tree.addChild n
    tree

  _writeHTML: ->
    html = $("<ul />")
    console.log "x"
    for node in @tree.getChildren()
      switch node.value.type
        when "scopevariables" then html.append @_writeHTML_scopeVariables(node)
        when "callstack" then html.append @_writeHTML_callStack(node)

    $(@divid).append html

  _writeHTML_scopeVariables: (node) ->
    console.log node

  _writeHTML_callStack: (node) ->
    html = $("<li />")
    html.append $("<h3>#{node.value.title}</h3>")
    stack = $("<ul />")

    for call in node.getChildren()
      stack.append $("<li>#{call.value.functionName} -> #{call.value.fileName}:#{call.value.lineNumber}</li>")

    html.append stack
    console.log html
    return html

#    $(@divid).append reason

    # cfm = pe.callFrames[0]

    # @messaging.sendMessage
    #   type: "Runtime.getProperties"
    #   objectId: cfm.scopeChain[0].object.objectId
    #   ownProperties: true


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

