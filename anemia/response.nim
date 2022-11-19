import asyncnet, asyncdispatch, strutils
#prototype   await client.send("HTTP/1.1 200 Berhasil\r\nContent-Type: text/html\r\n\r\n<p>hello anemian</p>\r\n")


type HttpResponse* = ref object of RootObj
    statusCode: int
    message: string
    clientConn: AsyncSocket
    body: string

proc newResponse*(clientConn: AsyncSocket): HttpResponse =
    let r = HttpResponse()
    r.message = "OK"
    r.statusCode = 200
    r.clientConn = clientConn
    return r

method setStatusCode*(r: HttpResponse, code: int): HttpResponse {.base.} =
    r.statusCode = code
    return r

method setMessage*(r: HttpResponse, message: string): HttpResponse {.base.} =
    r.message = message
    return r

method sendResponse*(r: HttpResponse, body: string) {.async, base.} =
    r.body = body
    var rawResponse = "HTTP/1.1 " & intToStr(r.statusCode) & " " & r.message & "\r\nContent-Type: text/html\r\n\r\n" & r.body & "\r\n" 
    await r.clientConn.send(rawResponse)


method getBody*(r: HttpResponse): string {.base.} =
   return r.body

export newResponse 