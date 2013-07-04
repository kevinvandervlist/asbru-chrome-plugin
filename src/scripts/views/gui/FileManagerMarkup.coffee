#= require gui/GuiBase.coffee

class FileManagerMarkup extends GuiBase
  constructor: (@fileManager) ->
    super()
    @rootelemstr = "/"

  updateFileListing: ->
    @_update()

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

      closure = (title, child) =>
        title.click =>
          cb = -> child.toggle()
          @click title, cb
      closure title, fileList


      # Create an array with a hierarchical layout
      allPaths = []

      f = (target, nodename, cur, file) ->
        # Create target if it is new
        if not target[nodename]?
          target[nodename] = []
        if cur.length is 0
          # Root node without a path
          target[nodename].push file
        else
          _nodename = cur.shift()
          target[nodename] = f target[nodename], _nodename, cur, file
        return target

      for file in @fileManager.getAllFilesByOrigin origin
        allPaths = f allPaths, @rootelemstr, file.getPath(), file

      # Create a file node line
      fileNodeLine = (file, parent) =>
        element = file.getSourceFileLine()
        element.addClass "filename"
        parent.append element

        # Wrap the click stuff in a closure...
        f = (element, file) =>
          callback = =>
            @showFile file

          element.click =>
            @click element, callback
        # ... and call it
        f element, file

      # Display files in an hierarchical order.
      fileNodeTree = (array, parent) =>
        for key, value of array
          if value instanceof Array
            title = $("<li>#{key}</li>").addClass "foldername"
            child = $("<ul />")
            parent.append title
            parent.append child
            child.hide() if key isnt @rootelemstr
            closure = (title, child) =>
              title.click =>
                cb = -> child.toggle()
                @click title, cb
            closure title, child
            fileNodeTree value, child
          else
            fileNodeLine value, parent
      # And actually call the above
      fileNodeTree allPaths[@rootelemstr], fileList

  showFile: (file) =>
    el = $(@vdata.mainContentId())
    el.empty()
    el.append file.getFormattedCode()
    for k,bp of file.getBreakpoints()
      bp.setBreakpoint()
    return undefined
