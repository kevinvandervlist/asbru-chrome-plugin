# Add an isEqual prototype to arrays...
Array.prototype.isEqual = (other) ->
  this.length is other.length and this.every (elem, i) -> elem is other[i]
