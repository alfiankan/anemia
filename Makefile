run:
	nim c -r simple.nim
build:
	nim c -d:release simple.nim
test:
	curl -i -XPOST http://localhost:5000/ -d 'this week is crazy'
