# Node types for the state tree
class StateTree extends TreeNode

class CallStack extends TreeNode
  constructor: ->
    super
      title: "Call Stack"

class ScopeVariableStack extends TreeNode
  constructor: ->
    super
      title: "Scope Variables"

class ScopeVariable extends TreeNode
  constructor: (value) ->
    @visible = true
    super value

  isVisible: => @visible
  setVisible: (state) => @visible = state
  toggleVisible: => @visible = not @visible

class CallstackVariable extends TreeNode
