# Anemia is simple HTTP library to save your blood pressure :)
# prototype

# let app: AnemiaApp = newAnemiaApp()

# handler = (req, res) => {
#   res.sendstring("hello anemian")
# }

# app.handle("/", anemia.HTTP_GET, handler)

import std/[asyncnet, asyncdispatch, strutils, tables]
import reqres/request

type HandlerType = proc(req: string, res: string): Future[system.void]{.closure.}

type Httphandler = ref object of RootObj
  path, httpMethod: string
  handle: HandlerType

type AnemiaApp* = ref object of RootObj
  host, port: string
  handlers: seq[Httphandler]
    

proc newAnemiaApp(host: string, port: string): AnemiaApp =
  let app = AnemiaApp()
  app.host = host
  app.port = port
  return app 

method addHandler*(a: AnemiaApp, path: string, httpMethod: string, handle: HandlerType) {.base.} =
  let handler = Httphandler()
  handler.path = path
  handler.httpMethod = httpMethod
  handler.handle = handle
  a.handlers.add(handler)

method processClientRequest*(a: AnemiaApp, client: AsyncSocket) {.async, base.} =
    var req: HttpRequest = newRequest()
    # get top head
    var lineBuffer: string
    lineBuffer = await client.recvLine()
    let headArrSplited = lineBuffer.split(" ")
    req.setHttpMethod(headArrSplited[0])
    req.setHttpUri(headArrSplited[1])

    # populating headers
    while true:
        lineBuffer = await client.recvLine()
        if lineBuffer == "\r\n":
            break
        let splitedHeader = lineBuffer.split(": ")
        #echo splitedHeader
        req.addHeader(splitedHeader[0], splitedHeader[1])

    # read body
    let (bodyExist, bodyLength) = req.getBodyContentLength()
    if bodyExist:
        lineBuffer = await client.recv(parseInt(bodyLength))
        req.setBodyContent(lineBuffer)
    
    echo "Request coming with ", req.getHttpMethod(), "method and body ", req.getContentBody()

    # handle request now
    for handler in a.handlers:
      if handler.path == req.getHttpUri():
        asyncCheck handler.handle()

    await client.send("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<p>hello anemian</p>\r\n")
    client.close()

method serve*(a: AnemiaApp) {.async, base.}=
  let socket = newAsyncSocket()
  socket.setSockOpt(OptReuseAddr, true)
  socket.bindAddr(Port(8888))
  socket.listen()

  while true:
    let client = await socket.accept()
    asyncCheck a.processClientRequest(client)

method run*(a: AnemiaApp) {.base.} =
  asyncCheck a.serve()









## prototype simple application server


let app: AnemiaApp = newAnemiaApp("127.0.0.1", "8888")

proc helloWorld(req: string, res: string) {.async.} =
  await sleepAsync(5000)
  echo "Success"

app.addHandler("/hello", "GET", helloWorld)

proc songList(req: string, res: string) {.async.} =
  await sleepAsync(1000)
  echo "Success"

app.addHandler("/songs", "GET", songList)

app.run()
runForever()


