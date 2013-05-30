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

test "Specific removal", ->
  x = new TreeNode "foo"
  y = new TreeNode "bar"
  z = new TreeNode "abc"
  q = new TreeNode "q"

  x.addChild q
  x.addChild y
  x.addChild z
  x.removeChild y

  t = []

  t.push child for child in x.getChildren()

  a = (t.length is 2)
  b = true
  for c in x.getChildren
    if c.value is "bar"
      b = false

  x.removeChild z
  x.removeChild q

  c = not x.hasChildren()

  ok a and b and c
