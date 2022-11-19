import std/[asyncnet, asyncdispatch, strutils]

type HttpHeader = ref object of RootObj
    name, value: string

type HttpRequest = ref object of RootObj
    httpMethod, httpUri : string
    headers: seq[HttpHeader]

method setHttpMethod(r: HttpRequest, incomingMethod: string) {.base.} =
    r.httpMethod = incomingMethod

method setHttpUri(r: HttpRequest, incomingHttpUri: string) {.base.} =
    r.httpUri = incomingHttpUri

method addHeader(r: HttpRequest, name: string, value: string) {.base.} =
   let header: HttpHeader = HttpHeader()
   header.name = name
   header.value = value
   r.headers.add(header)

proc processClientRequest(client: AsyncSocket) {.async.} =
    var req = HttpRequest()
    
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


    echo "Request coming with ", req.httpMethod, "method", req.headers[0].name

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

    