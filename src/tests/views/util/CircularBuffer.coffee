test "Circular Buffer initialisation size.", ->
  cb = new CircularBuffer 10
  ok cb.capacity() is 10
