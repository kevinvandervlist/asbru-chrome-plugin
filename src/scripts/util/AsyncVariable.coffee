class AsyncVariable
  constructor: (@value = null, callback = null, @id = null) ->
    @onChange = []
    @onChange.push callback if callback?

  setValue: (v) ->
    @value = v
    cb() for cb in @onChange

  addCallback: (cb) ->
    @onChange.push cb

  clearCallback: ->
    @onChange = null

  getValue: ->
    @value

  getIdentifier: ->
    @id
