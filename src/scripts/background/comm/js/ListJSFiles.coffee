# js.ListJSFiles
# [ { scriptId: int, url: URI, code: <code> }, { ... } .. ]
js_ListJSFiles = (message) ->
  f = (js) ->
    sendMessage
      type: "js.ListJSFile"
      scriptId: js.scriptId
      url: js.url
      code: js.code
  f js for js in hoocsd.jsFiles
