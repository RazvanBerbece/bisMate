# bisMate
Connecting-type app for people to match profesionally and discuss/implement business ideas. 

# Progress
- [x] Go Listening Server
- [x] iOS Client Prototype
- [x] Web Socket Connection
- [x] Basic User Account Operations
- [ ] 'Connect' functionality
- [x] Messaging
- [ ] Location Handling

## Further Dev Cycles
- [ ] watchOS Client

# Server (REST & Web Sockets)
Server is built using Golang (or Go, for short).

## API Responses
Response {
    "TransactionID" : int,
    "Result" : int,
    "Data" : Any (will be primitive data types or encodable structs),
    "Message" : string,
}

### Example of response for GetUser(UID):
{
  "Data" : {
    "DisplayName" : "New Name",
    "UID" : "jaq3RAOFuBar41BySERkP0WPugZ2",
    "PhotoURL" : "",
    "Email" : "test1@yahoo.com",
    "EmailVerified" : false,
    "PhoneNumber" : ""
  },
  "Result" : 1,
  "Message" : "User retrieved successfully.",
  "TransactionID" : 0
}

## API Endpoints
1. [/ws]("http://localhost:8000/ws") -- Web Socket entry point for device (mainly used for messaging use case)
2. [/conn]("http://localhost:8000/conn") -- Tests Go server 
3. [/operation?token=<String>&operation=<String>&input=<String>]("http://localhost:8000/operation?token=<String>&operation=<String>&input=<String>") -- Uses the token param to verify a transaction (gets User ID from token verification) and then processes the operation specified in the operation parameter using the data in the input field

### Operations
- 0 = Get User Profile
- 1 = Change Bio
- 2 = Change Display Name
- 3 = Add Profile Picture

- d = Delete Account
- c = Change Password

- x = 'Connect' (verify token -> add new entry to connections of token.UID)
- s = Save Messages (periodic on client)

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
- Starscream

There is a possibility in the future there will be a lightweight version of the iOS Client developed for the watchOS.
