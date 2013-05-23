# Add an isEqual prototype to arrays...
Array.prototype.isEqual = (other) ->
  @length is other.length and @every (elem, i) -> elem is other[i]

# And a remove operation
Array.prototype.remove = (object) ->
  i = 0
  removed = null
  for element in @
    if element.isEqual object
      removed = @splice(i, 1)[0]
    i++
  removed
