class DataStore
  constructor: ->
    @store = []

  put: (key, value) ->
    @store[key] = value

  get: (key) ->
    @getByKey key

  getByKey: (key) ->
    return @store[key] if @keyExists(key)
    return null

  getAllValues: ->
    ret = []
    ret.push value for key, value of @store
    return ret

  getByValue: (value) ->
    for key, val of @store
      if value is val
        return value
    return null

  keyExists: (key) ->
    @store[key]?

  valueExists: (value) ->
    @getByValue value isnt null

  remove: (key) ->
    delete @store[key]
