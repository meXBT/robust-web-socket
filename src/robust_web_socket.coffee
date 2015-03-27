WebSocket = require('ws')

#
#  A client side web socket that always needs to be running.
#
#  If connection is closed or errors out, it will try and reconnect after waiting 1 minute.
#
#

class RobustWebSocket
  socket: null
  pingTimer: null
  pingInterval: null
  debug: false

  constructor: (@endpoint, @onOpen, @onMessage, options={}) ->
    @debug = options?.debug
    @pingInterval = options?.pingInterval || 6000
    @disablePing = options?.disablePing
    @start()

  start: ->
    @log("Opening connection to #{@endpoint}")
    @socket = new WebSocket(@endpoint)
    @socket.on('open', =>
      @log("Opened websocket to #{@endpoint}")
      @onOpen(@socket)
      unless @disablePing
        @pingTimer = setInterval( =>
          @log("=> ping (#{@endpoint} #{new Date().toISOString()})")
          @socket.ping()
        , @pingInterval)
    )
    @socket.on('message', (data) =>
      @onMessage(data)
    )
    @socket.on('close', @onClose)
    @socket.on('error', @onError)
    setTimeout(=>
      @ensureOpen()
    , 60000)
    @socket.on('pong', =>
      @log("<= pong (#{@endpoint} #{new Date().toISOString()})")
    )

  ensureOpen: =>
    unless @socket.readyState is WebSocket.OPEN
      @onCloseOrError("Did not manage to open after 60s")

  onClose: =>
    @log("Socket to #{@endpoint} closed at #{new Date}")
    @onCloseOrError()

  onError: (error) =>
    @log("Socket to #{@endpoint} encountered an error at #{new Date} (#{error})")
    @onCloseOrError()

  onCloseOrError: =>
    clearInterval(@pingTimer)
    @log("Will restart socket in 60s...")
    setTimeout(=>
      @restart()
    , 60000)

  restart: =>
    delete @pingTimer
    delete @socket
    @start()

  log: (msg) ->
    if @debug
      console.log(msg)

module.exports = RobustWebSocket
