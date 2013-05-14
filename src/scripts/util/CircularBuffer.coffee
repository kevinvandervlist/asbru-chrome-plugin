class CircularBuffer
  constructor: (req_size) ->
    @size = req_size + 1
    @store = new Array @size
    @start = 0
    @end = 0

  isFull: ->
    (@end + 1 ) % @size is @start

  isEmpty: ->
    @end is @start

  push: (data) ->
    @store[@end] = data
    @end = (@end + 1) % @size
    if @end is @start # Full -- circle is round
      @start = (@start + 1) % @size

  pop: ->
    throw "Empty circular buffer!" if @isEmpty()
    tmp = @start
    @start = (@start + 1) % @size
    @store[tmp]

  capacity: ->
    @size - 1

  count: ->
    s = @start
    c = 0

    while s != @end
      s = (s + 1) % @size
      c++
    c

  peek: (index = 0) ->
    throw "Circular Buffer index out of range! #{index}" unless @count() > 0 and index < @count()
    @store[(@start + index) % @size]

  forEach: (func, context) ->
    func.call(context, @peek(index), index) for index in [0...@count()]

  toArray: ->
    f = (el, index) ->
      x.push el
    x = []
    @forEach f, x
    x
