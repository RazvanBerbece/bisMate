# bisMate
Connecting-type app for people to match profesionally and discuss/implement business ideas. 

# Progress
- [x] Go Listening Server
- [x] iOS Client Prototype
- [x] Web Socket Connection
- [ ] Basic User Account Operations
- [ ] 'Connect' functionality
- [ ] Messaging
- [ ] Location Handling

## Further Dev Cycles
- [ ] watchOS Client

# Server (REST & Web Sockets)
Server is built using Golang (or Go, for short).

## API Responses
The responses are a struct with the following fields :
• TransactionID : int
• Result : int
• Data : string
• Message : string

## API Calls
1. [localhost:port/ws]("http://localhost:8000/ws") -- Web Socket entry point for device (mainly used for messaging use case)
2. [localhost:port/conn]("http://localhost:8000/conn") -- Tests Go server 
3. localhost:port/operation?token=<String>&operation=<String>&input=<String> -- Uses the token param to verify a transaction (gets User ID from token verification) and then processes the operation specified in the operation parameter using the data in the input field

## Go Frameworks 
- [Gorilla Websocket]("https://github.com/gorilla/websocket")
- [Firebase]("https://firebase.google.com/go")
- [Firebase Auth]("https://firebase.google.com/go/auth")
- [Option Package]("https://google.golang.org/api/option")
- The rest are Go standard packages

# Client (iOS)
The Client is built in Swift (UIKit).

## Cocoapods
- SwiftyJSON
- Firebase (+ Auth)

There is a possibility in the future there will be a lightweight version of the iOS Client developed for the watchOS.
