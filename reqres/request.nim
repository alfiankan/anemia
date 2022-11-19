import std/[tables]

type HttpRequest* = ref object of RootObj
    httpMethod, httpUri : string
    headers: Table[string, string]
    body: string

proc newRequest(): HttpRequest =
    var request = HttpRequest()
    request.headers = initTable[string, string]()
    return request

method getHttpMethod*(r: HttpRequest): string {.base.} =
    return r.httpMethod

method getContentBody*(r: HttpRequest): string {.base.} =
    return r.body
    
method getHttpHeaders*(r: HttpRequest): Table[string, string] {.base.} =
    return r.headers

method setHttpMethod*(r: HttpRequest, incomingMethod: string) {.base.} =
    r.httpMethod = incomingMethod

method setHttpUri*(r: HttpRequest, incomingHttpUri: string) {.base.} =
    r.httpUri = incomingHttpUri

method getHttpUri*(r: HttpRequest): string {.base.} =
    return r.httpUri

method addHeader*(r: HttpRequest, name: string, value: string) {.base.} =
    r.headers[name] = ""
    r.headers[name].add(value)

method getBodyContentLength*(r: HttpRequest): (bool, string) {.base.} =
    # find content length
    let exist = r.headers.hasKey("Content-Length")
    if exist:
        return (true, r.headers["Content-Length"])
    else:
        return (false, "")

method setBodyContent*(r: HttpRequest, body: string) {.base.} =
    r.body =  body
    
export newRequest