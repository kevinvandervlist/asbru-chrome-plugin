#= require DataStore.coffee
#= require gui/FileManagerMarkup.coffee

class FileManager
  constructor: ->
    @files = []
    @origins = []
    @markup = new FileManagerMarkup @

  saveFile: (origin, key, sourceFile) ->
    if not @files[origin]?
      @files[origin] = new DataStore
      @files.length = @files.length + 1
      @origins.push origin

    @files[origin].put key, sourceFile
    @markup.updateFileListing()

  getFile: (origin, key) ->
    @files[origin].get key

  getAllFilesByOrigin: (origin) ->
    @files[origin].getAllValues()

  getOrigins: ->
    @origins
