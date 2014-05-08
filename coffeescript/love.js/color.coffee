class Color
  constructor: (@r, @g, @b, @a = 255) ->
    # console.log(@r, @g, @b)
    r = Math.floor(@r % 256)
    g = Math.floor(@g % 256)
    b = Math.floor(@b % 256)
    # a = Math.floor(@a % 255) / 255
    @html_code = "rgb(#{r}, #{g}, #{b})"
