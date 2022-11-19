import std/[asyncdispatch]

proc tunggu() {.async.} =
    await sleepAsync(2000)
    echo "body"

proc anemia() {.async.} =
    echo "header"
    asyncCheck tunggu()
    echo "footer"

asyncCheck anemia()
runForever()