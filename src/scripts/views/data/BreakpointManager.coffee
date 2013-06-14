#= require data/OriginDataManager.coffee

class BreakpointManager extends OriginDataManager

  saveBreakpoint: (origin, key, breakpoint) ->
    @put origin, key, breakpoint

  removeBreakpoint: (origin, key) ->
    @remove key, origin

  getFile: (key, origin = null) ->
    @get key, origin

  getAllBreakpointByOrigin: (origin) ->
    @getAllDataByOrigin origin
