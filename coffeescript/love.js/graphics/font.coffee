
determineFontHeight = (fontStyle) ->
  body = document.getElementsByTagName("body")[0]
  dummy = document.createElement("div")
  dummyText = document.createTextNode("x")
  dummy.appendChild dummyText
  dummy.setAttribute "style", "font: " + fontStyle
  body.appendChild dummy
  result = dummy.offsetHeight
  body.removeChild dummy
  result


class Font
  constructor: (@filename, @size) ->
    if !@size?
      @size = @filename
      @filename = "Vera"
    console.log(@filename, @size)
    @html_code = "#{@size}px '#{@filename}'"
    @height = determineFontHeight(@html_code)
    console.log(@height)

  getAscent: (self) ->
  getBaseline: (self) ->
  getDescent: (self) ->
  getFilter: (self) ->
  getHeight: (self) ->
    @height
  getLineHeight: (self) ->
  getWidth: (self) ->
  getWrap: (self) ->
  hasGlyphs: (self) ->
  setFilter: (self) ->
  setLineHeight: (self) ->
