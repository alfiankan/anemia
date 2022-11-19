import std/[asyncnet, asyncdispatch, strutils, tables]

type HttpRequest* = ref object of RootObj
    httpMethod, httpUri : string
    headers: Table[string, string]
    body: string

proc newRequest(): HttpRequest =
    var request = HttpRequest()
    request.headers = initTable[string, string]()
    return request

method setHttpMethod*(r: HttpRequest, incomingMethod: string) {.base.} =
    r.httpMethod = incomingMethod

method setHttpUri*(r: HttpRequest, incomingHttpUri: string) {.base.} =
    r.httpUri = incomingHttpUri

method addHeader*(r: HttpRequest, name: string, value: string) {.base.} =
    r.headers[name] = ""
    r.headers[name].add(value)

method getBodyContentLength*(r: HttpRequest): (bool, string) =
    # find content length
    let exist = r.headers.hasKey("Content-Length")
    if exist:
        return (true, r.headers["Content-Length"])
    else:
        return (false, "")

method setBodyContent*(r: HttpRequest, body: string) {.base.} =
    r.body =  body
    

proc processClientRequest(client: AsyncSocket) {.async.} =
    var req = newRequest()
    
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

    
    echo "Request coming with ", req.httpMethod, "method and body ", req.body

    await client.send("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<p>hello anemian</p>\r\n")
    client.close()

proc serve() {.async.} =
    let socket = newAsyncSocket()
    socket.setSockOpt(OptReuseAddr, true)
    socket.bindAddr(Port(8888))
    socket.listen()

    while true:
        let client = await socket.accept()
        asyncCheck processClientRequest(client)




asyncCheck serve()
runForever()
#discard trySend(client, "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<p>hello anemian</p>\r\n")

    