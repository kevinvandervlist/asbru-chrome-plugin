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
        # It must be the extension now
        origin = "chrome-extension"

    return origin
