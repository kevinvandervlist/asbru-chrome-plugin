#= require Tree.coffee
# Node types for the state tree
class StateTree extends TreeNode
  constructor: (value) ->
    @visible = true
    super value

  isVisible: => @visible
  setVisible: (state) => @visible = state
  toggleVisible: => @visible = not @visible

class CallStack extends StateTree
  constructor: ->
    super
      title: "Call Stack"

class ScopeVariableStack extends StateTree
  constructor: ->
    super
      title: "Scope Variables"

class ScopeVariable extends StateTree

class CallstackVariable extends StateTree
