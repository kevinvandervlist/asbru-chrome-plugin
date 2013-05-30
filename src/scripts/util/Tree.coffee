# A simple node
class TreeNode
  constructor: (@value) ->
    @children = []

  clear: ->
    @children = []

  getValue: ->
    @value

  getChildren: ->
    @children

  hasChildren: ->
    @children.length isnt 0

  addChild: (node) ->
    @children.push node

  removeChild: (node) ->
    @children.remove node

  isLeaf: ->
    !@hasChildren()

  isNode: ->
    @hasChildren()
