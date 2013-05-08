test "Circular Buffer initialisation size.", ->
  x = 5
  cb = new CircularBuffer x
  ok cb.capacity() is x and cb.count() is 0

test "Empty Circular Buffer pop", ->
  ret = false
  cb = new CircularBuffer 5
  try cb.pop()
  catch e
    ret = true
  ok ret

test "Circular Buffer push / count / pop / count size.", ->
  cb = new CircularBuffer 5
  a = cb.count() is 0
  cb.push "Foo"
  cb.push "Bar"
  b = cb.count() is 2
  cb.pop()
  c = cb.count() is 1
  d = cb.peek() is "Bar"
  ok a and b and c and d

test "Circular Buffer push/pop behaviour with small buffer", ->
  cb = new CircularBuffer 3
  cb.push "a"
  cb.push "b"
  cb.push "c"
  cb.push "d"
  cb.push "e"

  f = (el, index) ->
    x.push el

  x = []
  cb.forEach f, x

  a = cb.isFull()
  b = cb.peek() is "c"
  c = "c" in x and "d" in x and "e" in x
  cb.pop()
  d = cb.peek() is "d"
  e = cb.peek() is "e"
  f = cb.isEmpty()
  ok a and b and c and d and e and f
