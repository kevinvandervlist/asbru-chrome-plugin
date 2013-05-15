class comm_JS
  constructor: (@messager) ->

  # js.ListFiles
  # [ { scriptId: int, url: URI, code: <code> }, { ... } .. ]
  ListFiles: (message) ->
    f = (x) =>
      @messager.sendMessage
        type: "js.ListFile"
        scriptId: x.scriptId
        url: x.url
        code: x.code
    f x for x in hoocsd.files

  setBreakpointByUrl: (message) =>
    console.log message

