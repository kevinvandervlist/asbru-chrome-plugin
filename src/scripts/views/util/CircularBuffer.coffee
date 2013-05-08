# Based on: CoffeeCollections CircularBuffer
# https://github.com/nlessmann/CoffeeCollections/ :: MIT license
class CircularBuffer
  constructor: (req_size) ->
    @size = req_size + 1
    @store = new Array @size
    @head = 0
    @tail = 0

  next: (pos) ->
    (pos + 1) % @size

  push: (data) ->
    @store[@tail] = data
    @tail = @next(@tail)
    @head = @next(@head) if @tail is @head

  pop: ->
    if @isEmpty() then throw "Empty circular buffer"
    tmp = @head
    @head = @next(@head)
    @store[tmp]

  peek: (index = 0) ->
    if Math.abs(index) > (@size - 2) and index isnt (1 - @size) then throw "Index out of range"

    # Negative means relative to newest, positive to oldest
    ref = if index < 0 then @tail else @head
    slot = (ref + @size + index) % @size

    @store[slot] unless slot >= @tail and slot < @head

  foreach: (func, ctx) ->
    func.call(ctx, @peek(index), index) for index in [0...@count()]

  isEmpty: ->
    @tail is @head

  isFull: ->
    @next(@tail) is @head

  capacity: ->
    @size - 1

  count: ->
    if @tail < @head then @tail + @head else @tail - @head
