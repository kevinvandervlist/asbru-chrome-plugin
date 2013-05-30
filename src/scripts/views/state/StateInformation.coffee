class StateInformation
  constructor: (@messaging) ->
    @properties = {}

  # pausedevent:
  # https://developers.google.com/chrome-developer-tools/docs/protocol/tot/debugger#event-paused
  pausedEvent: (pe) =>
    @tree = @_createStateTree pe.reason, pe.callFrames
    @sim = new StateInformationMarkup @, @tree

  destroy: =>
    # Cleanup
    @sim.destroy() if @sim?

  # Callback to update a property description
  updatePropDesc: (objectId, propDescArray) =>
    @properties[objectId].setValue propDescArray

  # Given a scopeNode (e.g. node in the scopevariables part of the tree)
  # retrieve its child elements and put them in the tree as well
  addChildScopeVariables: (scopeNode) ->
    if scopeNode.hasChildren()
      return
    object = scopeNode.value.scopeObject
    if object.value?
      object = object.value

    thisReference = scopeNode.value.thisReference

    # Callback triggered when we receive a variable update from the chrome debugger.
    cb = (value, id) =>
      proto = @_newProtoNode()
      scopeNode.addChild proto

      for item in value
        itemNode = @_newScopeVariableNode(item, item.name)
        if item.isOwn?
          # Own object
          scopeNode.addChild itemNode
        else
          # __proto__
          proto.addChild itemNode

    # The normal objects retrieval, including above defined callback
    @_getProperties object, cb

    # If there is a thisReference then we should also include it
    if thisReference?
      thisNode = @_newScopeVariableNode(thisReference, "this")
      scopeNode.addChild thisNode
      @addChildScopeVariables @thisNode
    # End of if thisReference?

    @tree

  _newProtoNode: ->
    new ScopeVariable
      title: "__proto__"

  _newScopeVariableNode: (scopeObject, title = null, subtitle = null, thisReference = null) ->
    new ScopeVariable
      title: title
      subtitle: subtitle
      thisReference: thisReference
      scopeObject: scopeObject

  _newCallstackVariableNode: (functionName, fileName, lineNumber, callFrame, active = false, scopeVars = null) ->
    new CallstackVariable
      functionName: functionName
      fileName: fileName
      lineNumber: lineNumber
      callFrame: callFrame
      scopeVars: scopeVars
      active: active

  # Create a tree representing the paused state fo the JS VM
  _createStateTree: (reason, callFrames) ->
    tree = new StateTree
      title: "JS VM State"
      reason: reason

    stack = @_createCallStack callFrames
    tree.addChild stack

    for call in stack.getChildren()
      scopeVars = @_createScopeVariables call.getValue()
      # Only the most specific callstack should show scope variables
      if call.getValue().active
        tree.addChild scopeVars
      # But add all of them to the tree
      call.getValue().scopeVars = scopeVars

    #end of for
    tree

  # get properties of an object. The returning value is an "AsyncVariable", which
  # needs to have a callback (updatePropDesc via comm_debugger) found to it.
  # If the object already exists, return an existing AsyncVariable
  _getProperties: (object, cb = null) ->
    if @properties[object.objectId]?
      return @properties[object.objectId]
    else
      ret = new AsyncVariable null, cb, object.objectId
      @properties[object.objectId] = ret

      @messaging.sendMessage
        type: "Runtime.getProperties"
        objectId: object.objectId
        ownProperties: false
      return ret

  # Create a callstack based on an array of callframes
  _createCallStack: (callFrames) ->
    tree = new CallStack
    active = true

    # Make sure the functionNames have meaningful names
    for cf in callFrames
      if cf.functionName isnt ""
        functionName = cf.functionName
      else
        functionName = "(anonymous function)"

      # Get the filename based on the ID
      id = cf.location.scriptId
      file = window.hoocsd.data.files.get id
      fileName = file.filename

      # Add it to the tree
      tree.addChild @_newCallstackVariableNode(functionName, fileName, cf.location.lineNumber, cf, active)

      # Only the first item should be active
      if active
        active = false
    return tree

  # And this is needed to create scope variables
  _createScopeVariables: (callStackNode) ->
    tree = new ScopeVariableStack

    frame = callStackNode.callFrame
    chain = frame.scopeChain

    for scope in chain
      title = null
      subtitle = scope.object.description
      thisReference = null
      # Handle according to the frame type
      switch scope.type
        when "local"
          title = "Local"
          subtitle = null
          if frame.this
            thisReference = frame.this
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

      tree.addChild @_newScopeVariableNode scope.object, title, subtitle, thisReference
    tree
