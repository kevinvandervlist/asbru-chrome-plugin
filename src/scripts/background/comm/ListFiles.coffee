# ListFiles
# [ { scriptId: int, url: URI, code: <code> }, { ... } .. ]
ListFiles = (message) ->
  f = (x) ->
    sendMessage
      type: "ListFile"
      scriptId: x.scriptId
      url: x.url
      code: x.code
  f x for x in hoocsd.files
