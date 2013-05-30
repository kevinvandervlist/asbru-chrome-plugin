test "Create a simple treenode without children", ->
  x = new TreeNode "foo"
  ok x.hasChildren() is false

test "isLeaf()", ->
  x = new TreeNode "foo"
  y = new TreeNode "bar"
  y.addChild x
  ok (x.isLeaf() is true) and (y.isLeaf() is false)

test "isNode()", ->
  x = new TreeNode "foo"
  y = new TreeNode "bar"
  x.addChild y
  ok (x.isNode() is true) and (y.isNode() is false)

test "Children addition and removal", ->
  x = new TreeNode "foo"
  y = new TreeNode "bar"
  z = new TreeNode "abc"

  x.addChild y
  x.addChild z

  t = []

  t.push child for child in x.getChildren()

  a = (t.length is 2)

  x.clear()

  b = x.hasChildren()

  ok a and not b

