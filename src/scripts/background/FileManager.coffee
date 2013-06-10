#= require OriginDataManager.coffee

class FileManager extends OriginDataManager
  constructor: ->
    super()

  saveFile: (origin, key, sourceFile) ->
    @put origin, key, sourceFile

  getFile: (key, origin = null) ->
    @get key, origin

  getAllFilesByOrigin: (origin) ->
    @getAllDataByOrigin origin

