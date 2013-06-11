#= require DataStore.coffee

# File to manage the storage of data based on its origin
class OriginDataManager
  constructor: ->
    @data = []
    @origins = []

  put: (origin, key, value) ->
    if not @data[origin]?
      @data[origin] = new DataStore
      @data.length = @data.length + 1
      @origins.push origin

    @data[origin].put key, value

  get: (key, origin = null) ->
    if origin?
      @data[origin].get key
    else
      for availableOrigin in @getOrigins()
        if @data[availableOrigin]? and @data[availableOrigin].get(key)?
          return @data[availableOrigin].get key

  remove: (key, origin = null) ->
    if origin?
      @data[origin].remove key
    else
      for availableOrigin in @getOrigins()
        if @data[availableOrigin]?
          @data[availableOrigin].remove key
          return undefined
    return undefined

  getAllDataByOrigin: (origin) ->
    @data[origin].getAllValues()

  getOrigins: ->
    @origins
