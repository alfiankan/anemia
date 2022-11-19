import std/[asyncnet, asyncdispatch, strutils]

type HttpRequest = ref object of RootObj
    httpMethod, httpUri : string

method setHttpMethod(r: HttpRequest, incomingMethod: string) {.base.} =
    r.httpMethod = incomingMethod

method setHttpUri(r: HttpRequest, incomingHttpUri: string) {.base.} =
    r.httpUri = incomingHttpUri

proc processClientRequest(client: AsyncSocket) {.async.} =
    var req = HttpRequest()
    
    # get top head
    var headLine = await client.recvLine()
    let headArrSplited = headLine.split(" ")
    req.setHttpMethod(headArrSplited[0])
    req.setHttpUri(headArrSplited[1])

    echo "Request coming with ", req.httpMethod, "method"

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

    