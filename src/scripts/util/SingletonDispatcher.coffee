class SingletonDispatcher
  instance = null

  # The single dispatcher
  class Dispatcher
    constructor: ->
      @callbackArray = []

    addCallback: (cb) ->
      @callbackArray.push cb

    removeCallback: (cb) ->
      remove = (array, object) ->
        i = 0
        for element in array
          if element is object
            array.splice(i, 1)[0]
          i++

      remove @callbackArray, cb

    invokeCallbacks: =>
      cb() for cb in @callbackArray
      undefined

    setTimeoutCallback: (ms) ->
      window.setTimeout @invokeCallbacks, ms

    setIntervalCallback: (ms) ->
      setInterval @invokeCallbacks, ms

    setTimeout: (cb, ms) ->
      setTimeout cb, ms

    setInterval: (cb, ms) ->
      setInterval cb, ms

  # This is a static method used to either retrieve the
  # instance or create a new one.
  @get: ->
    instance ?= new Dispatcher

