import asyncdispatch, base64
import anemia/[anemia, request, response]

let app: AnemiaApp = newAnemiaApp("127.0.0.1", "5000")

# handler hello anemia user
proc helloWorld(req: HttpRequest, res: HttpResponse) {.async.} =
    await res.setStatusCode(200).setMessage("OK").sendResponse("Hello World Anemian")

# handler taylor swift, i love her
proc songList(req: HttpRequest, res: HttpResponse) {.async.} =
    await res.setStatusCode(200).setMessage("OK").sendResponse("Taylor Swift Midnight Album")

# handler chalange republic of cloud engineering
proc republicEngineering(req: HttpRequest, res: HttpResponse) {.async.} =
    let base64Message: string = encode(req.getContentBody())
    await res.setStatusCode(200).setMessage("OK").sendResponse(base64Message)

app.addGetHandler("/hello", helloWorld)

app.addPostHandler("/songs", songList)

app.addPostHandler("/", republicEngineering)

app.run()
runForever()

