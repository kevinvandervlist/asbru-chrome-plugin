#= require gui/GuiBase.coffee

class StateInformationMarkup extends GuiBase
  constructor: (@stateInformation) ->
    super()
    @html = $("<ul />")

  destroy: ->

  # If this is called, the @stateInformation.getStateTree will be used to render a tree representing JS state
  updateHTML: ->
    @html.empty()

    tree = @stateInformation.getStateTree()

    for node in tree.getChildren()
      switch node.constructor.name
        when "ScopeVariableStack" then @html.append @_scopeVariablesStart(node)
        when "CallStack" then @html.append @_callStack(node)

    return @html

  _stateTitle: (title, child) ->
    element = $("<h4>#{title}</h4>")
    element.click =>
      cb = -> child.toggle()
      @click element, cb
    return element

  _clickableTreeItem: (node, text, child, callback = null) ->
    element = $("<li>#{text}</li>")
    element.click =>
      cb = =>
        child.toggle()
        n.toggleVisible() for n in node.getChildren()
        callback() if callback?
        @updateHTML()
      @click element, cb
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
      # Get the accompanying file
      id = call.value.callFrame.location.scriptId;
      lineNumber = call.value.callFrame.location.lineNumber
      file = window.asbru.data.files.get id, @stateInformation.getOrigin()

      csline = $("<li>#{call.value.functionName} -> #{call.value.fileName}:#{call.value.lineNumber}</li>")
      if call.value.active
        csline.addClass "selected-item"

      stack.append csline

      # Create a callback to change the stack
      f = (active, selected, element, file, lineNumber) =>
        element.click =>
          cb = =>
            # file is the SourceFile object of the current file
            # Use the same hack as in StateInformationManager.coffee...
            window.asbru.data.files.showBreakpointAndSourceFile file, file.id, lineNumber
            @stateInformation.changeCallstackContext(active, selected)
            @updateHTML()
          @click element, cb
        return element
      f activeCallStack, call, csline, file, lineNumber

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
