# A simple node
class TreeNode
  constructor: (@value) ->
    @children = []

  getValue: ->
    @value

  getChildren: ->
    @children

  hasChildren: ->
    @children isnt []

  addChild: (node) ->
    @children.push node

  removeChild: (node) ->
    @children.remove node

  isLeaf: ->
    !@hasChildren()

  isNode: ->
    @hasChildren()
