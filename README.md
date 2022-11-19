# 🩸 Anemia HTTP [ON PROGRESS]
## A simple Nim HTTP library for your blood 🩸
![Untitled Diagram drawio](https://user-images.githubusercontent.com/40946917/202859136-7e6b88a0-a1f2-4269-af2f-5ce1c99fc809.png)



> Disclaimer, i'm not expertise yet in Nim but it is my first time trying to use Nim, and its fun. so sorry if my code was not expected as Nim expert, i just want achieve how http work actually

> the entire code style is influenced by golang, 

Todo 1 :
    
    Create a simple HTTP server which can process HTTP Get request and return arbitrary response. 
    Requirements:
    This simple server is expected to receive 1 type of HTTP GET request only. No router is necessary to route request to correct handler (yet)
    You may return any arbitrary response back to the client as long as it complies with HTTP.
    Use of existing framework or high level libraries are not allowed. You must only use socket API for any languages of your choice to send and receive data to and from the network.
    Your web server should be able to process the message concurrently without waiting current request to be completed.
    You may use this challenge as part of your software design learning. If you are tasked to create this capabilities, how should you design the interface?
    do not steal any code from internet

Todo 2 :
    
    Create a simple HTTP server which can process HTTP Post request and return response based on data from payload

    Requirements:
    Use of existing framework or high level library are not allowed. You must only use socket API for any languages of your choice to receive and send data from and to the network.
    You should be able to handle POST request to / endpoint with some data as the the request body. The payload will be arbitrary string. After the request is processed, you should response with the base64 value from the request body.
    Request
    POST / http/1.1
    ...... //http headers

    this week is crazy

    Response
    HTTP/1.1 200 OK
    ..... //http headers

    dGhpcyB3ZWVrIGlzIGNyYXp5

    If you have solution from first challenge, you may continue using that code. If not, you can create new code repository.
    do not steal any code from internet

## Prototype
```nim
import asyncdispatch, base64
import anemia/[anemia, request, response]

let app: AnemiaApp = newAnemiaApp("127.0.0.1", "5000")

# handler chalange republic of cloud engineering
proc republicEngineering(req: HttpRequest, res: HttpResponse) {.async.} =
    let base64Message: string = encode(req.getContentBody())
    await res.setStatusCode(200).setMessage("OK").sendResponse(base64Message)

app.addPostHandler("/", republicEngineering)

app.run()
runForever()
```
## How to build and run
- install nim 1.6.8 or aboce
- install Make
- run `make build` in terminal to build sample server
- run `./simple` in terminal to run sample server

## How to test
- run `make test `
## Test Result
```bash                  
❯ curl -i -XPOST http://localhost:5000/ -d 'this week is crazy'
HTTP/1.1 200 OK
Content-Type: text/html

dGhpcyB3ZWVrIGlzIGNyYXp5
```

## Benchmark
```bash
All VUs finished. Total time: 7 seconds

--------------------------------
Summary report @ 22:34:39(+0700)
--------------------------------

http.codes.200: ................................................................ 5000
http.request_rate: ............................................................. 1000/sec
http.requests: ................................................................. 5000
http.response_time:
  min: ......................................................................... 0
  max: ......................................................................... 13
  median: ...................................................................... 0
  p95: ......................................................................... 1
  p99: ......................................................................... 3
http.responses: ................................................................ 5000
vusers.completed: .............................................................. 5000
vusers.created: ................................................................ 5000
vusers.created_by_name.0: ...................................................... 5000
vusers.failed: ................................................................. 0
vusers.session_length:
  min: ......................................................................... 0.4
  max: ......................................................................... 24.1
  median: ...................................................................... 0.7
  p95: ......................................................................... 2.2
  p99: ......................................................................... 8.4
```
