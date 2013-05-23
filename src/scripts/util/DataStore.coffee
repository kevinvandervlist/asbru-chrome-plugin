class DataStore
  constructor: ->
    @store = {}

  put: (key, value) ->
    @store[key] = value

  get: (key) ->
    @getByKey key

  getByKey: (key) ->
    return @store[key] if @keyExists(key)
    return null

  getByValue: (value) ->
    for item in @store
      if item is value
        return item
    return null

  keyExists: (key) ->
    @store[key]?

  valueExists: (value) ->
    @getByValue value isnt null
