# Taken from node-inspector; see LICENSE
class Convert
  v8LocationToInspectorLocation: (v8loc) ->
    scriptId: v8loc.script_id.toString()
    lineNumber: v8loc.line
    columnNumber: v8loc.column

  v8NameToInspectorUrl: (v8name) ->
    if @v8name is undefined
      return ""

    if /^\//.test(v8name)
      return "file://#{v8name}"
    else if /^[a-zA-Z]:\\/.test(v8name)
      return "file:///" + v8name.replace(/\\/g, "/")
    else if /^\\\\/.test(v8name)
      return "file://" + v8name.substring(2).replace(/\\/g, "/")

    return v8name

  inspectorUrlToV8Name: (url) ->
    path = url.replace(/^file:\/\//, "")
    if /^\/[a-zA-Z]:\//.test(path)
      return path.substring(1).replace(/\//g, "\\") # Windows disk path
    if /^\//.test(path)
      return path # UNIX-style
    if /^file:\/\//.test(url)
      return "\\\\" + path.replace(/\//g, "\\") # Windows UNC path

    return url

  v8ScopeTypeToString: (v8ScopeType) ->
    switch v8ScopeType
      when 0 then return "global"
      when 1 then return "local"
      when 2 then return "with"
      when 3 then return "closure"
      when 4 then return "catch"
      else return "unknown"

  v8RefToInspectorObject: (ref) ->
    desc = ""
    switch ref.type
      when "object"
        name = /#<(\w+)>/.exec(ref.text)
        if name && name.length > 1
          desc = name[1]
          if (desc is "Array" or desc is "Buffer")
            size = ref.properties.filter( (p) -> /^\d+$/.test(p.name)).length
            desc += "[#{size}]"
        else
          desc = ref.className || "Object"
      when "function" then desc = ref.text || "function()"
      else desc = ref.text || ""

    if desc.length > 100
      desc = desc.substring(0, 100) + "\u2026"

    objectId = ref.handle
    if objectId is undefined
      objectId = ref.ref

    ret =
      type: ref.type
      objectId: String(objectId)
      className: ref.className
      description: desc

  v8ErrorToInspectorError: (message) ->
    nameMatch = /^([^:]+):/.exec(message)
    if nameMatch
      cn = nameMatch[1]
    else
      cn = "Error"

    ret =
      type: "object"
      objectId: "ERROR"
      className: cn
      description: message

  v8ResultToInspectorResult: (result) ->
    if result.type is "object" or result.type is "function"
      return @v8RefToInspectorObject(result)

    ret =
      type: result.type
      value: result.value
      description: String(result.text)

  v8FunctionLookupToFunctionDetails: (handleData) ->
    ret =
      details:
        location:
          scriptId: String(handleData.scriptId)
          lineNumber: handleData.line
          columnNumber: handleData.column
        name: handleData.name || handleData.inferredName

        # There is a list of scope ids in responseBody.scopes, but not scope
        # details :( // We need to issue `scopes` request to fetch scopes
        # details, but we don't have frame number where the function was defined.
        # Let's leave the scopeChain empty for now.
        scopeChain: []
  v8ScriptIdToInspectorId: (scriptId) ->
    String scriptId

  inspectorScriptIdToV8Id: (scriptId) ->
    Number scriptId

# exports.v8NameToInspectorUrl = function(v8name) {
#   if (v8name === undefined) {
#     // Call to `evaluate` creates a new script with no URL
#     // Front-end expects empty string as URL in such case
#     return '';
#   }

#   if (/^\//.test(v8name)) {
#     return 'file://' + v8name;
#   } else if (/^[a-zA-Z]:\\/.test(v8name)) {
#     return 'file:///' + v8name.replace(/\\/g, '/');
#   } else if (/^\\\\/.test(v8name)) {
#     return 'file://' + v8name.substring(2).replace(/\\/g, '/');
#   }

#   return v8name;
# };

# exports.inspectorUrlToV8Name = function(url) {
#   var path = url.replace(/^file:\/\//, '');
#   if (/^\/[a-zA-Z]:\//.test(path))
#     return path.substring(1).replace(/\//g, '\\'); // Windows disk path
#   if (/^\//.test(path))
#     return path; // UNIX-style
#   if (/^file:\/\//.test(url))
#     return '\\\\' + path.replace(/\//g, '\\'); // Windows UNC path

#   return url;
# };

# exports.v8ScopeTypeToString = function(v8ScopeType) {
#   switch (v8ScopeType) {
#     case 0:
#       return 'global';
#     case 1:
#       return 'local';
#     case 2:
#       return 'with';
#     case 3:
#       return 'closure';
#     case 4:
#       return 'catch';
#     default:
#       return 'unknown';
#   }
# };

# exports.v8RefToInspectorObject = function(ref) {
#   var desc = '',
#       size,
#       name,
#       objectId;

#   switch (ref.type) {
#     case 'object':
#       name = /#<(\w+)>/.exec(ref.text);
#       if (name && name.length > 1) {
#         desc = name[1];
#         if (desc === 'Array' || desc === 'Buffer') {
#           size = ref.properties.filter(function(p) { return /^\d+$/.test(p.name);}).length;
#           desc += '[' + size + ']';
#         }
#       }
#       else {
#         desc = ref.className || 'Object';
#       }
#       break;
#     case 'function':
#       desc = ref.text || 'function()';
#       break;
#     default:
#       desc = ref.text || '';
#       break;
#   }
#   if (desc.length > 100) {
#     desc = desc.substring(0, 100) + '\u2026';
#   }

#   objectId = ref.handle;
#   if (objectId === undefined)
#     objectId = ref.ref;

#   return {
#     type: ref.type,
#     objectId: String(objectId),
#     className: ref.className,
#     description: desc
#   };
# };

# exports.v8ErrorToInspectorError = function(message) {
#   var nameMatch = /^([^:]+):/.exec(message);

#   return {
#     type: 'object',
#     objectId: 'ERROR',
#     className: nameMatch ? nameMatch[1] : 'Error',
#     description: message
#   };
# };

# exports.v8ResultToInspectorResult = function(result) {
#   if (result.type === 'object' || result.type === 'function') {
#     return exports.v8RefToInspectorObject(result);
#   }

#   return {
#     type: result.type,
#     value: result.value,
#     description: String(result.text)
#   };
# };

# exports.v8FunctionLookupToFunctionDetails = function(handleData) {
#   return {
#     details: {
#       location: {
#         scriptId: String(handleData.scriptId),
#         lineNumber: handleData.line,
#         columnNumber: handleData.column
#       },
#       name: handleData.name || handleData.inferredName,

#       // There is a list of scope ids in responseBody.scopes, but not scope
#       // details :( // We need to issue `scopes` request to fetch scopes
#       // details, but we don't have frame number where the function was defined.
#       // Let's leave the scopeChain empty for now.
#       scopeChain: []
#     }
#   };
# };

# exports.v8ScriptIdToInspectorId = function(scriptId) {
#   return String(scriptId);
# };

# exports.inspectorScriptIdToV8Id = function(scriptId) {
#   return Number(scriptId);
# };