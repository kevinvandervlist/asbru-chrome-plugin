#= require debug/node/inspector_utils/convert.coffee

# Taken from node-inspector; see LICENSE
class CallFramesProvider
  constructor: (@dbg) ->
    @SCOPE_ID_MATCHER = /^scope:(\d+):(\d+)$/
    @convert = new Convert

  fetchCallFrames: (callback) ->
    m =
      type: "request"
      command: "backtrace"
      arguments:
        inlineRefs: true
    cb = (data) =>
      @_convertBacktraceToCallFrames data.body, data.refs, callback

    @dbg._sendCommand m, cb

  _convertBacktraceToCallFrames: (backtraceResponseBody, backtrackResponseRefs, callback) ->
    if backtraceResponseBody.frames?
      debuggerFrames = backtraceResponseBody.frames
    else
      debuggerFrames = []

    async.map debuggerFrames, @_convertDebuggerFrameToInspectorFrame.bind(@, backtrackResponseRefs), callback

  _convertDebuggerFrameToInspectorFrame: (backtrackResponseRefs, frame, done) =>
    scopeChain = frame.scopes.map( (scope) =>
      ret =
        object:
          type: "object"
          objectId: "scope:#{frame.index}:#{scope.index}"
          className: "Object"
          description: "Object"
        type: @convert.v8ScopeTypeToString(scope.type)
    )

    obj =
      callFrameId: frame.index.toString()
      functionName: frame.func.inferredName || frame.func.name
      location:
        scriptId: @convert.v8ScriptIdToInspectorId(frame.func.scriptId)
        lineNumber: frame.line
        columnNumber: frame.column
      scopeChain: scopeChain
      this: @convert.v8RefToInspectorObject(frame.receiver)

    done null, obj

  isScopeId: (objectId) ->
    @SCOPE_ID_MATCHER.test objectId

  getScopeProperties: (objectId, done) ->
    scopeIdMatch = @SCOPE_ID_MATCHER.exec objectId
    if not scopeIdMatch
      if not isNaN objectId
        # We must do a lookup instead of scope request
        @_doHandleLookup done, objectId
      else
        throw "Invalid scope id: #{objectId}" if not scopeIdMatch

    m =
      type: "request"
      command: "scope"
      arguments:
        number: Number(scopeIdMatch[2])
        frameNumber: Number(scopeIdMatch[1]),
        inlineRefs: true

    cb = (data) =>
      @_processScopeProperties done, data.body, data.refs

    @dbg._sendCommand m, cb

  _processScopeProperties: (done, response, refs) ->
    props = response.object.properties

    if props
      # refs is an array, where el.handle should equal p.value.ref
      indexed_refs = []
      indexed_refs[r.handle] = r for r in refs

      props = props.map( (p) =>
        if not indexed_refs[p.value.ref]?
          console.log "WTF, this shouldn't happen"
          console.log response
          console.log indexed_refs
          console.log refs
        name: String(p.name)
        value: @convert.v8ResultToInspectorResult(indexed_refs[p.value.ref])
        isOwn: true
      )

    done null, result: props

  _doHandleLookup: (done, objectId) ->
    console.log "Do a lookup for #{objectId}"

    m =
      type: "request"
      command: "lookup"
      arguments:
        handles: [objectId]
        includeSource: false

    cb = (data) =>
      console.log "Lookup data for #{objectId}: "
      console.log data

      if data.refs and Array.isArray data.refs
        refs = {}
        props = []

        obj = data.body[objectId]
        objProps = obj.properties
        proto = obj.protoObject

        refs[r.handle] = r for r in data.refs

        props = objProps.map( (p) =>
          r = refs[p.ref]
          ret =
            name: String p.name
            value: @convert.v8RefToInspectorObject r
            isOwn: true
        )
        if proto
          props.push
            name: '__proto__'
            value: @convert.v8RefToInspectorObject(refs[proto.ref])
            isOwn: false

      done null, result: props

    @dbg._sendCommand m, cb
