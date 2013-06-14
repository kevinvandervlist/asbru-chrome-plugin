#= require gui/FileManagerMarkup.coffee
#= require OriginDataManager.coffee

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

  showBreakpointAndSourceFile: (file, id, line) ->
    @markup.showFile file
    $(".file-#{id}-line-#{line}").addClass "active-breakpoint"
