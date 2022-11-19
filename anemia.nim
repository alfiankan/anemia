# Anemia is simple HTTP library to save your blood pressure :)
# prototype

# let app: AnemiaApp = newAnemiaApp()

# handler = (req, res) => {
#   res.sendstring("hello anemian")
# }

# app.handle("/", anemia.HTTP_GET, handler)

import std/[asyncnet, asyncdispatch, strutils, tables]
import reqres/[request, response]

type HandlerType = proc(req: HttpRequest, res: HttpResponse): Future[system.void]{.closure.}

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
    var res: HttpResponse = newResponse(client)
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

    echo "Request coming with ",  req.getHttpUri()," ", req.getHttpMethod(), " method and body ", req.getContentBody()
    # handle request now
    var handlerExist: bool = false

    for handler in a.handlers:
      if handler.path == req.getHttpUri() and handler.httpMethod == req.getHttpMethod():
        handlerExist = true
        await handler.handle(req, res)
    if not handlerExist:
      await client.send("HTTP/1.1 405 Method Not Allowed\r\nContent-Type: text/html\r\n\r\n<p>Can't handle request</p>\r\n")

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

proc helloWorld(req: HttpRequest, res: HttpResponse) {.async.} =
  await res.setStatusCode(200).setMessage("OK").sendResponse("Hello World Anemian")


app.addHandler("/hello", "GET", helloWorld)

proc songList(req: HttpRequest, res: HttpResponse) {.async.} =
  await res.setStatusCode(200).setMessage("OK").sendResponse("Midnight Album")

app.addHandler("/songs", "GET", songList)

app.run()
runForever()


