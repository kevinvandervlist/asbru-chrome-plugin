#= require OriginDataManager.coffee
test "Store information in OriginDataManager, be able to retrieve with origin", ->
  man = new OriginDataManager

  origina = "A"
  originb = "B"

  a =
    key: "X"
    value: "Foo"
  b =
    key: "Y"
    value: "Bar"
  c =
    key: "Z"
    value: "Baz"

  man.put origina, a.key, a.value
  man.put origina, b.key, b.value
  man.put originb, c.key, c.value

  resa = a.value is man.get(a.key, origina)
  resb = b.value is man.get(b.key, origina)
  resc = c.value is man.get(c.key, originb)

  ok resa and resb and resc

test "Store information in OriginDataManager, be able to retrieve without origin", ->
  man = new OriginDataManager

  origina = "A"
  originb = "B"

  a =
    key: "X"
    value: "Foo"
  b =
    key: "Y"
    value: "Bar"
  c =
    key: "Z"
    value: "Baz"

  man.put origina, a.key, a.value
  man.put origina, b.key, b.value
  man.put originb, c.key, c.value

  resa = a.value is man.get(a.key)
  resb = b.value is man.get(b.key)
  resc = c.value is man.get(c.key)
  ok resa and resb and resc
