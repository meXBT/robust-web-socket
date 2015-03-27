# Robust Web Socket

A simple wrapper around the great [ws](https://github.com/websockets/ws) library, which tries to do everything it can to keep a web socket
connection open. Useful if you are listening to websockets which perhaps don't have the most amazing uptime.

## Install

`npm install robust-web-socket`

## Usage

```CoffeeScript
onOpen = (socket) ->
  socket.send("I can haz open")
onMessage = (message) ->
  console.log("I can haz message")
socket = new RobustWebSocket("wss://my.funky.web.socket.com", onOpen, onMessage, {debug: true})
```
