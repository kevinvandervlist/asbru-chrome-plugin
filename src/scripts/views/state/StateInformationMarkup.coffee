class StateInformationMarkup
  constructor: (@stateInformation, @stateTree) ->
    vd = new ViewData
    @divid = vd.stateInfoId()

    @interval = setInterval @_updateCallback, 1000

  destroy: ->
    $(@divid).empty()
    clearInterval @interval

  # If this is called, the @stateTree will be used to render a tree representing JS state
  writeHTML: ->
    html = $("<ul />")

    for node in @stateTree.getChildren()
      switch node.constructor.name
        when "ScopeVariableStack" then html.append @_scopeVariablesStart(node)
        when "CallStack" then html.append @_callStack(node)

    $(@divid).append html

  _updateCallback: =>
    $(@divid).empty()
    @writeHTML()

  _stateTitle: (title, child) ->
    $("<h4>#{title}</h4>").click -> child.toggle()

  _clickableTreeItem: (node, text, child, callback = null) ->
    $("<li>#{text}</li>").click ->
      child.toggle()
      n.toggleVisible() for n in node.getChildren()
      callback() if callback?

  # Callstack stuff
  _callStack: (node) ->
    html = $("<li />")
    stack = $("<ul />")
    title = @_stateTitle(node.value.title, stack)

    html.append title

    for call in node.getChildren()
      stack.append $("<li>#{call.value.functionName} -> #{call.value.fileName}:#{call.value.lineNumber}</li>")

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
      return "#{scopeObject.name}: [#{scopeObject.value.value}] :: #{scopeObject.value.type}"
