class String
  constructor: (@str) ->

  # Is str a substring of other?
  substringOf: (other) ->
    (new RegExp(@str)).test(other)
