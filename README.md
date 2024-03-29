# bisMate
Connecting-type app for people to match profesionally and discuss/implement business ideas. 

# Progress
- [x] Go Server & iOS Client (prototype)
- [x] Basic User Account Operations
- [x] Messaging -- Functional on simulator (doesn't currently work on physical devices)
- [x] Location Uploader
- [x] 'Connect' functionality
- [ ] User Profile Info Enhancement (~~Pic~~, ~~Bio~~, Work Place, Position etc.)
- [ ] Connection Popup Styling and Populating (~~Pic~~, ~~Bio~~, Work Place, Position etc.)
- [ ] Location Remover on Location Change
- [ ] Go Server Secured -- HTTP for now (TLS implemented but there are some config issues)
- [x] Encrypt Data sent to Firebase (ie. Messages) -- Client-side encryption, uses a 512-bit RSA key pair.

## Further Dev Cycles
- [ ] watchOS Client

# Server (REST & Web Sockets)
Server is built using Golang (or Go, for short).

## API Responses
Response {\
&nbsp;&nbsp;&nbsp;&nbsp;"TransactionID" : int,\
&nbsp;&nbsp;&nbsp;&nbsp;"Result" : int,\
&nbsp;&nbsp;&nbsp;&nbsp;"Data" : Any (will be primitive data types or encodable structs),\
&nbsp;&nbsp;&nbsp;&nbsp;"Message" : string,\
}

### Example of response for GetUser(UID):
{\
&nbsp;&nbsp;"Data" : {\
&nbsp;&nbsp;&nbsp;&nbsp;"DisplayName" : "New Name",\
&nbsp;&nbsp;&nbsp;&nbsp;"UID" : "jaq3RAOFuBar41BySERkP0WPugZ2",\
&nbsp;&nbsp;&nbsp;&nbsp;"PhotoURL" : "",\
&nbsp;&nbsp;&nbsp;&nbsp;"Email" : "test1@yahoo.com",\
&nbsp;&nbsp;&nbsp;&nbsp;"EmailVerified" : false,\
&nbsp;&nbsp;&nbsp;&nbsp;"PhoneNumber" : ""\
  },\
&nbsp;&nbsp;"Result" : 1,\
&nbsp;&nbsp;"Message" : "User retrieved successfully.",\
&nbsp;&nbsp;"TransactionID" : 0\
}

## API Endpoints
1. [/ws]("http://localhost:8000/ws") -- Web Socket entry point for device (mainly used for messaging use case)
2. [/conn]("http://localhost:8000/conn") -- Tests Go server 
3. [/operation?token=<String>&operation=<String>&input=<String>]("http://localhost:8000/operation?token=<String>&operation=<String>&input=<String>") -- Uses the token param to verify a transaction (gets User ID from token verification) and then processes the operation specified in the operation parameter using the data in the input field

### Operations (<Number> = Description (Params))
#### User Profile Data
- 0 = Get User Profile                        (UID : String)
- ubg = Get Bio                                 (UID : String)
- ubs = Set Bio                                  (Bio : String)
- 2 = Change Display Name              (DisplayName : String)
- pps = Set Profile Picture                 (Multiform Data : Base64String)
- ppg = Get Profile Picture                 (UID : String)

#### User Account High Security Operations
- d = Delete Account
- c = Change Password                     (Pass : String)

#### Location Handling
- ws = UID Location (City) (PUSH)         (UID : String, City : String)
- wg = UID Location (City) (GET ALL)     (UID : String, City : String)

#### Connections component
- xs = LikedBy (PUSH)                   (UID : String, LikedUID: String)
- xg = LikedBy (GET)                      (UID : String, LikedUID: String)
- xx = Likes (GET)                           (UID : String)
- xxy = Matches (GET)                    (UID : String)

#### Messaging Component
- y = Get chat history of user (list of chats with users)
- z = Get detailed chat history between two users on Firebase database for future retrieval     (Remote_UID : String)

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
- Alamofire
- SwiftyRSA
  
# Testing
Testing has been implemented for the Go side of the project and a GitHub Action was created to run them on every push & merge to main. 
The action will always fail online because the conf.json file which contains the Firebase API credentials & config is not pushed.
Testing for Swift-side to be implemented in the near future.
- [  ] Backend Testing (Firebase, Sockets, other units) -- in progress
- [  ] Frontend Testing (UI, Requests, other units)

There is a possibility in the future that there will be a lightweight version of the iOS Client developed for the watchOS.
