#= require DataStore.coffee

# File to manage the storage of data based on its origin
class OriginDataManager
  constructor: ->
    @data = []

  put: (origin, key, value) ->
    if not @data[origin]?
      @data[origin] = new DataStore
    @data[origin].put key, value

  get: (key, origin = null) ->
    if origin?
      return @data[origin].get key
    else
      for origin, datastore of @data
        v = datastore.get(key)
        return v if v?
    undefined

  remove: (key, origin = null) ->
    if origin?
      @data[origin].remove key
    else
      for origin, datastore of @data
        datastore.remove(key)
        return undefined
    return undefined

  getAllDataByOrigin: (origin) ->
    @data[origin].getAllValues()

  getOrigins: ->
    ret = []
    for origin, store of @data
      ret.push origin
    return ret