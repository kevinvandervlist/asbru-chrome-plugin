class Origin
  @createOriginFromUri: (uri) ->
    origin = null

    switch uri.split(':')[0]
      when "file"
        origin = "file"
      when "http", "https"
        split = uri.split '/'
        splice = split.splice 0, 3
        origin = splice.join "/"
      else
        throw "origin for #{uri} is not defined"

    return origin
