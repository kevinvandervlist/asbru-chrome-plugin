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
    throw "Invalid scope id #{objectId}" if not scopeIdMatch

    m =
      type: "request"
      command: "scope"
      arguments:
        number: Number(scopeIdMatch[2])
        frameNumber: Number(scopeIdMatch[1]),
        inlineRefs: true

    cb = (data) =>
      console.log "DATA::::::"
      console.log data
      @_processScopeProperties done, data.body, data.refs

    @dbg._sendCommand m, cb

  _processScopeProperties: (done, response, refs) ->
    props = response.object.properties

    if props
      props = props.map( (p) =>
        name: String(p.name)
        value: @convert.v8ResultToInspectorResult(refs[p.value.ref])
      )

    done null, result: props

# var async = require('async'),
#     convert = require('./convert.js');

# var SCOPE_ID_MATCHER = /^scope:(\d+):(\d+)$/;

# function CallFramesProvider(debuggerClient) {
#   this._debuggerClient = debuggerClient;
# }

# CallFramesProvider.prototype = {

#   fetchCallFrames: function(handleResponse) {
#     this._debuggerClient.request(
#       'backtrace',
#       {
#         inlineRefs: true
#       },
#       function(err, responseBody, responseRefs) {
#         if (err) {
#           handleResponse(err);
#           return;
#         }

#         this._convertBacktraceToCallFrames(responseBody, responseRefs, handleResponse);
#       }.bind(this));
#   },

#   _convertBacktraceToCallFrames: function(backtraceResponseBody, backtrackResponseRefs, handleResponse) {
#     var debuggerFrames = backtraceResponseBody.frames || [];

#     async.map(
#       debuggerFrames,
#       this._convertDebuggerFrameToInspectorFrame.bind(this, backtrackResponseRefs),
#       handleResponse);
#   },

#   _convertDebuggerFrameToInspectorFrame: function(backtrackResponseRefs, frame, done) {
#     var scopeChain = frame.scopes.map(function(scope) {
#        return {
#          object: {
#            type: 'object',
#            objectId: 'scope:' + frame.index + ':' + scope.index,
#            className: 'Object',
#            description: 'Object'
#          },
#          type: convert.v8ScopeTypeToString(scope.type)
#        };
#     });

#     done(null, {
#       callFrameId: frame.index.toString(),
#       functionName: frame.func.inferredName || frame.func.name,
#       location: {
#         scriptId: convert.v8ScriptIdToInspectorId(frame.func.scriptId),
#         lineNumber: frame.line,
#         columnNumber: frame.column
#       },
#       scopeChain: scopeChain,
#       this: convert.v8RefToInspectorObject(frame.receiver)
#     });
#   },

#   isScopeId: function(objectId) {
#     return SCOPE_ID_MATCHER.test(objectId);
#   },

#   getScopeProperties: function(objectId, done) {
#     var scopeIdMatch = SCOPE_ID_MATCHER.exec(objectId);
#     if (!scopeIdMatch) throw new Error('Invalid scope id "' + objectId + '"');

#     this._debuggerClient.request(
#       'scope',
#       {
#         number: Number(scopeIdMatch[2]),
#         frameNumber: Number(scopeIdMatch[1]),
#         inlineRefs: true
#       },
#       this._processScopeProperties.bind(this, done)
#     );
#   },

#   _processScopeProperties: function(done, err, response, refs) {
#     if (err) {
#       done(err);
#       return;
#     }

#     var props = response.object.properties;
#     if (props) {
#       props = props.map(function(p) {
#         return {
#           name: String(p.name),
#           value: convert.v8ResultToInspectorResult(refs[p.value.ref])
#         };
#       });
#     }

#     done(null, { result: props });
#   }
# };

# exports.CallFramesProvider = CallFramesProvider;