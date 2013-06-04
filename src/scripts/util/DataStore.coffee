class DataStore
  constructor: ->
    @store = {}
    @keys = []

  put: (key, value) ->
    @store[key] = value
    @keys.push key

  get: (key) ->
    @getByKey key

  getByKey: (key) ->
    return @store[key] if @keyExists(key)
    return null

  getAllValues: ->
    ret = []
    ret.push @store[key] for key in @keys
    return ret

  getByValue: (value) ->
    for item in @store
      if item is value
        return item
    return null

  keyExists: (key) ->
    @store[key]?

  valueExists: (value) ->
    @getByValue value isnt null

  remove: (key) ->
    delete @store[key]
    @keys.splice @keys.indexOf(key), 1
