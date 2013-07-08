#= require gui/FileManagerMarkup.coffee
#= require OriginDataManager.coffee

class FileManager extends OriginDataManager
  constructor: ->
    super()
    @markup = new FileManagerMarkup @

  saveFile: (origin, key, sourceFile) ->
    @put origin, key, sourceFile

  getFile: (key, origin = null) ->
    @get key, origin

  getAllFilesByOrigin: (origin) ->
    @getAllDataByOrigin origin

  showBreakpointAndSourceFile: (file, id, line) ->
    file.show()
    $(".file-#{id}-line-#{line}").addClass "active-breakpoint"
