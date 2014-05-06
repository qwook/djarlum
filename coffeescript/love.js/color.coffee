class Color
  constructor: (@r, @g, @b, @a = 255) ->
    @r = Math.floor(@r)
    @g = Math.floor(@g)
    @b = Math.floor(@b)
    @html_code = "rgb(#{@r}, #{@g}, #{@b})"
