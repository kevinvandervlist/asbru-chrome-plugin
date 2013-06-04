#= require gui/GuiBase.coffee

class FileManagerMarkup extends GuiBase
  constructor: (@fileManager) ->
    super()
    @dispatcher.addCallback @_update

  updateFileListing: ->
    @dispatcher.setTimeoutCallback 10

  _update: =>
    flci = $("#{@vdata.filelistContentId()}")
    flci.empty()
    originList = $("<ul />")

    flci.append originList

    for origin in @fileManager.getOrigins()
      title = $("<li><h4>#{origin}</h4></li>")
      fileList = $("<ul />")
      originList.append title
      originList.append fileList

      for file in @fileManager.getAllFilesByOrigin origin
        element = file.getSourceFileLine()
        fileList.append element
        # Wrap the click stuff in a closure...
        f = (element, file) =>
          callback = =>
            $(@vdata.mainContentId()).empty()
            $(@vdata.mainContentId()).append file.getFormattedCode()

          element.click =>
            @click element, callback
        # ... and call it
        f element, file
