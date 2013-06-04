class StateInformationMarkup
  constructor: (@stateInformation) ->
    @divid = @vdata.stateInfoId()

  destroy: ->
    $(@divid).empty()

  # If this is called, the @stateInformation.getStateTree will be used to render a tree representing JS state
  writeHTML: ->
    $(@divid).empty()
    html = $("<ul />")

    tree = @stateInformation.getStateTree()

    for node in tree.getChildren()
      switch node.constructor.name
        when "ScopeVariableStack" then html.append @_scopeVariablesStart(node)
        when "CallStack" then html.append @_callStack(node)

    $(@divid).append html

  update: ->
    # Execute one now, and one a tad later
    @_updateCallback()
    setTimeout @_updateCallback, 1000

  _click: (element, callback) ->
    element.effect("highlight", {}, 100, callback);

  _updateCallback: =>
    @writeHTML()

  _stateTitle: (title, child) ->
    element = $("<h4>#{title}</h4>")
    element.click =>
      cb = -> child.toggle()
      @_click element, cb
    return element

  _clickableTreeItem: (node, text, child, callback = null) ->
    element = $("<li>#{text}</li>")
    element.click =>
      cb = =>
        child.toggle()
        n.toggleVisible() for n in node.getChildren()
        callback() if callback?
        @update()
      @_click element, cb
    return element

  # Callstack stuff
  _callStack: (node) ->
    html = $("<li />")
    stack = $("<ul />")
    title = @_stateTitle(node.value.title, stack)

    activeCallStack = null
    for cs in node.getChildren()
      if cs.value.active
        activeCallStack = cs

    html.append title

    for call in node.getChildren()
      csline = $("<li>#{call.value.functionName} -> #{call.value.fileName}:#{call.value.lineNumber}</li>")
      if call.value.active
        csline.addClass "selected-item"

      stack.append csline

      # Create a callback to change the stack
      f = (active, selected, element) =>
        element.click =>
          cb = =>
            @stateInformation.changeCallstackContext(active, selected)
            @update()
          @_click element, cb
        return element
      f activeCallStack, call, csline

    html.append stack
    return html

  _scopeVariablesStart: (node) ->
    html = $("<li />")
    scope = $("<ul />")
    title = @_stateTitle(node.value.title, scope)

    html.append title

    for scopeNode in node.getChildren()
      scope.append @_scopeVariables(scopeNode)

    html.append scope
    return html

  # Scope variables stuff
  _scopeVariables: (node) ->
    html = $("<li />")
    scope = $("<ul />")

    title = node.value.title
    subtitle = node.value.subtitle

    text = title
    text += " (#{subtitle})" if subtitle?

    cb = =>
      @stateInformation.addChildScopeVariables(node)
      scope.append @_scopeVariables child for child in node.getChildren()

    # Add the current element to the tree with cb as callback
    html.append @_clickableTreeItem(node, @_describeNode(node), scope, cb)

    # And recurse for available items
    for child in node.getChildren()
      scope.append @_scopeVariables(child)

    # end for
    html.append scope

    if node.isVisible()
      html.show()
    else
      html.hide()

    return html

  _describeNode: (node) ->
    scopeObject = node.value.scopeObject

    if not scopeObject?
      # pseudo node (e.g. __proto__)
      return "#{node.value.title}"
    else if not scopeObject.value?
      # Custom object with only a title + subtitle
      text = "#{node.value.title}"
      text += " (#{node.value.subtitle})" if node.value.subtitle?
      return text
    if scopeObject.value.objectId?
      # Chain; remote object
      return "#{scopeObject.name}: #{scopeObject.value.description}"
    else
      # Local object
      switch scopeObject.value.type
        when "string" then return "#{scopeObject.name}: \"#{scopeObject.value.value}\""
        when "number" then return "#{scopeObject.name}: #{scopeObject.value.value}"
        else return "#{scopeObject.name}: #{scopeObject.value.value} :: #{scopeObject.value.type}"
