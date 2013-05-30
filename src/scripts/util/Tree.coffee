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
    remove = (array, object) ->
      i = 0
      for element in array
        if element is object
          console.log array[i]
          array.splice(i, 1)[0]
        i++

    remove @children, node

  isLeaf: ->
    !@hasChildren()

  isNode: ->
    @hasChildren()
