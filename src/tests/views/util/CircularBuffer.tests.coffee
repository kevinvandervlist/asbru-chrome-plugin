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
  x = 5
  cb = new CircularBuffer x
  a = cb.count() is 0
  cb.push "Foo"
  cb.push "Bar"
  b = cb.count() is 2
  cb.pop()
  c = cb.count() is 1
  d = cb.peek() is "Bar"
  ok a and b and c and d
