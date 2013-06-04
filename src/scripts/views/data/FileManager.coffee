#= require data/OriginDataManager.coffee
#= require gui/FileManagerMarkup.coffee

class FileManager extends OriginDataManager
  constructor: ->
    super()
    @markup = new FileManagerMarkup @

  saveFile: (origin, key, sourceFile) ->
    @put origin, key, sourceFile
    @markup.updateFileListing()

  getFile: (key, origin = null) ->
    @get key, origin

  getAllFilesByOrigin: (origin) ->
    @getAllDataByOrigin origin

