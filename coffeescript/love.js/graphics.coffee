class Graphics
  constructor: (@width = 800, @height = 600) ->
    @canvas = new Canvas(@width, @height)
    document.body.appendChild(@canvas.element)
    @context = @canvas.context

    @default_canvas = @canvas
    @default_context = @context
    @default_font = new Font("Vera", 12)

    @setColor(255, 255, 255)
    @setBackgroundColor(0, 0, 0)
    @setFont(@default_font)
    @context.textBaseline = "top"
    # @context.imageSmoothingEnabled = false

  # DRAWING
  arc: (mode, x, y, radius, startAngle, endAngle, segments) =>
    @context.beginPath()
    @context.moveTo(x, y)
    @context.arc(x, y, radius, startAngle, endAngle)
    @context.closePath()
    switch mode
      when "fill" then @context.fill()
      when "line" then @context.stroke()

  circle: (mode, x, y, radius, segments) =>
    @context.beginPath()
    @context.arc(x, y, radius, 0, 2 * Math.PI)
    @context.closePath()
    switch mode
      when "fill" then @context.fill()
      when "line" then @context.stroke()

  clear: () =>
    @context.save()
    @context.setTransform(1,0,0,1,0,0)
    @context.fillStyle = @background_color.html_code
    @context.fillRect(0, 0, @canvas.width, @canvas.height)
    @context.restore()

  draw: (drawable, quad) =>
    switch true
      when quad not instanceof Quad then drawDrawable.apply(this, arguments)
      when quad instanceof Quad then drawWithQuad.apply(this, arguments)

  line: (points...) =>
    @context.beginPath()
    @context.moveTo(points[0], points[1])
    for i in [2...points.length] by 2
      [x, y] = [points[i], points[i + 1]]
      @context.lineTo(x, y)
    @context.stroke()

  point: (x, y) =>
    @context.fillRect(x, y, 1, 1)

  polygon: (mode, points...) =>
    @context.beginPath()
    @context.moveTo(points[0], points[1])
    for i in [2...points.length] by 2
      [x, y] = [points[i], points[i + 1]]
      @context.lineTo(x, y)
    @context.closePath()
    switch mode
      when "fill" then @context.fill()
      when "line" then @context.stroke()

  print: (text, x, y) =>
    @context.fillText(text, x, y)

  # TODO: word wrap? UGH
  printf: (text, x, y, limit, align = "left") =>
    @context.save()
    @context.translate(x + limit / 2, y)
    switch align
      when "center" then @context.textAlign = "center"
      when "left" then @context.textAlign = "left"
      when "right" then @context.textAlign = "right"
    @context.fillText(text, 0, 0)
    @context.restore()

  rectangle: (mode, x, y, width, height) =>
    switch mode
      when "fill" then @context.fillRect(Math.floor(x), Math.floor(y), width, height)
      when "line" then @context.strokeRect(Math.floor(x), Math.floor(y), width, height)

  # OBJECT CREATION
  newCanvas: (width, height) =>
    new Canvas(width, height)

  newFont: (filename, size = 12) =>
    new Font(filename, size)

  newImage: (path) =>
    new Image(path)


  newQuad: (x, y, width, height, sw, sh) =>
    new Quad(x, y, width, height, sw, sh)

  # STATE
  setColor: (r, g, b, a = 255) =>
    if typeof(r) == "number"
      @current_color = new Color(r, g, b, a)
    else # we were passed a sequence
      @current_color = new Color(r.getMember(1), r.getMember(2), r.getMember(3), r.getMember(4))
    @context.fillStyle = @current_color.html_code
    @context.strokeStyle = @current_color.html_code
    @context.globalAlpha = @current_color.a / 255


  setBackgroundColor: (r, g, b, a = 255) =>
    if typeof(r) == "number"
      @background_color = new Color(r, g, b, a)
    else # we were passed a sequence
      @background_color = new Color(r.getMember(1), r.getMember(2), r.getMember(3), r.getMember(4))

  setCanvas: (canvas) =>
    if canvas == undefined or canvas == null
      @default_canvas.copyContext(@canvas.context)
      @canvas = @default_canvas
      @context = @default_context
    else
      canvas.copyContext(@canvas.context)
      @canvas = canvas
      @context = canvas.context

  setFont: (font) =>
    if font
      @context.font = font.html_code
    else
      @context.font = @default_font.html_code

  # COORDINATE SYSTEM
  origin: () =>
    @context.setTransform(1,0,0,1,0,0)

  pop: () =>
    @context.restore()

  push: () =>
    @context.save()

  rotate: (r) =>
    @context.rotate(r)

  scale: (sx, sy = sx) =>
    @context.scale(sx, sy)

  shear: (kx, ky) =>
    @context.transform(1, ky, kx, 1, 0, 0)

  translate: (dx, dy) =>
    @context.translate(dx, dy)

  # WINDOW
  getWidth: () =>
    @default_canvas.width

  getHeight: () =>
    @default_canvas.height

  # PRIVATE
  drawDrawable = (drawable, x = 0, y = 0, r = 0, sx = 1, sy = sx, ox = 0, oy = 0, kx = 0, ky = 0) ->
    halfWidth = drawable.element.width / 2
    halfHeight = drawable.element.height / 2

    @context.save()
    @context.translate(x, y)
    @context.rotate(r)
    @context.scale(sx, sy)
    @context.transform(1, ky, kx, 1, 0, 0) # shearing
    @context.translate(-ox, -oy)
    @context.drawImage(drawable.element, 0, 0)
    @context.restore()

  drawWithQuad = (drawable, quad, x = 0, y = 0, r = 0, sx = 1, sy = sx, ox = 0, oy = 0, kx = 0, ky = 0) ->
    halfWidth = drawable.element.width / 2
    halfHeight = drawable.element.height / 2

    @context.save()
    @context.translate(x, y)
    @context.rotate(r)
    @context.scale(sx, sy)
    @context.transform(1, ky, kx, 1, 0, 0) # shearing
    @context.translate(-ox, -oy)
    @context.drawImage(drawable.element, quad.x, quad.y, quad.width, quad.height, 0, 0, quad.width, quad.height)
    @context.restore()

