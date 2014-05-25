class Window
  constructor: (@graphics) ->

  getDesktopDimensions: () =>

  getDimensions: () =>
    [@graphics.canvas.width, @graphics.canvas.height]

  getDisplayCount: () =>

  getFullscreen: () =>

  getFullscreenModes: () =>

  getIcon: () =>

  getMode: () =>

  getPixelScale: () =>

  getTitle: () =>

  getHeight: () =>
    @graphics.canvas.height

  getWidth: () =>
    @graphics.canvas.width

  hasFocus: () =>

  hasMouseFocus: () =>

  isCreated: () =>

  isVisible: () =>

  setFullscreen: () =>

  setIcon: () =>

  setMode: (width, height, flags) =>
    @graphics.canvas.setDimensions(width, height)

  setTitle: () =>

