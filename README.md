# Cowboy2Example

- json

```cmd
$ curl -i -H "Accept: application/json" http://localhost:4000
HTTP/1.1 200 OK
content-length: 21
content-type: application/json
date: Tue, 03 Jan 2017 13:34:08 GMT
server: Cowboy
vary: accept

{"rest": "Example!!"}
```

- plain text

```cmd
$ curl -i -H "Accept: text/plain" http://localhost:4000
HTTP/1.1 200 OK
content-length: 22
content-type: text/plain
date: Tue, 03 Jan 2017 13:34:23 GMT
server: Cowboy
vary: accept

REST Example as text!!
```

- html

```cmd
$ curl -i -H "Accept: text/css" http://localhost:4000
HTTP/1.1 406 Not Acceptable
content-length: 0
date: Tue, 03 Jan 2017 13:34:42 GMT
server: Cowboy
```

- html(use browser)

#### URL: http://localhost:4000

- get parameter

```cmd
$ url -i "http://localhost:4000/get-parameter/?echo=EchoHello"
HTTP/1.1 200 OK
content-length: 9
content-type: text/plain; charset=utf-8
date: Thu, 05 Jan 2017 14:35:01 GMT
server: Cowboy

EchoHello
```
