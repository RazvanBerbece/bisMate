package httphandlers

import (
	"context"
	"fmt"

	"encoding/json"

	"log"

	"net/http"

	fbadmin "bismateServer/firebase"

	"firebase.google.com/go/auth"

	"container/list"

	message "bismateServer/structs"
)

// HTTPResponse -- generic response for incoming HTTP requests
type HTTPResponse struct {
	TransactionID string
	Result        int
	Data          interface{}
	Message       string
}

// HTTPServ -- handlers for HTTP requests from client
type HTTPServ struct {
	CurrentToken auth.Token
	App          fbadmin.FirebaseApp
}

// HTTPInit -- initialises the struct variables
func (httpserver *HTTPServ) HTTPInit() {
	httpserver.CurrentToken = auth.Token{}
	httpserver.App.InitFirebase()
}

// HandleConn -- handler for server connections
func (httpserver *HTTPServ) HandleConn(w http.ResponseWriter, r *http.Request) {

	data := HTTPResponse{}
	data.TransactionID = "0"
	data.Result = 1
	data.Data = "0"
	data.Message = "Hello World"

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(data)

}

// HandleTokenVerify -- handler for server verify transactions
func (httpserver *HTTPServ) HandleTokenVerify(w http.ResponseWriter, r *http.Request) {

	receivedToken := r.URL.Query().Get("token") // all ops use the token
	/*
		operations :
		0 = Get User Profile 		(params -> UID : String)
		1 = Change Bio 				(params -> Bio : String)
		2 = Change Display Name     (params -> DisplayName : String)
		3 = Add Profile Picture     (params -> URL : String)

		d = Delete Account
		c = Change Password			(params -> Pass : String)

		ws = Save UID to city 		(params -> UID : String, City : String)
		wg = Get UID list from city (params -> UID : String, City : String)
		x = 'Connect'
		y = Get all messages of user with UID
		z = Get detailed chat between users
	*/
	operation := r.URL.Query().Get("operation")

	// other query params
	// change pass, change display name, change email all have only one param, input = <string>
	// so we use that
	input := r.URL.Query().Get("input")

	log.Printf("Incoming verify request with op: %s ...\n", operation)

	// Verify logic
	token, err := httpserver.App.Auth.VerifyIDToken(context.Background(), receivedToken)
	if err != nil { // err
		log.Printf("TokenVerify err : %v\n", err)
		// Response logic
		data := HTTPResponse{}
		data.TransactionID = "1"
		data.Result = 0
		data.Data = "0"
		data.Message = "Error while verifying token."

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(data)
	} else { // success
		log.Print("Verified ID token successfully")
		httpserver.CurrentToken = *token
		switch operation {
		case "0":
			// get user profile data
			status := -1 // uninit
			user := httpserver.App.GetUserProfile(&status, input)

			if status == 1 { // successfully got user
				data := HTTPResponse{}
				data.TransactionID = "0"
				data.Result = 1
				data.Data = user
				data.Message = "User retrieved successfully."

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else { // failed to get user
				data := HTTPResponse{}
				data.TransactionID = "0"
				data.Result = 0
				data.Data = 0
				data.Message = "Get user failed."

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}

		case "2":
			// change display name
			status := -1 // uninit
			httpserver.App.ChangeDisplayName(input, &status, httpserver.CurrentToken.UID)

			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "2"
				data.Result = 1
				data.Data = input
				data.Message = fmt.Sprint("Successfully changed display name to ", input, " !")

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "2"
				data.Result = 0
				data.Data = "0"
				data.Message = "Failed changing the display name. Try again later."

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "ws":
			// save the UID to Firebase in the specific city instance
			status := -1
			httpserver.App.SaveUIDToLocation(&status, httpserver.CurrentToken.UID, input)
			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "ws"
				data.Result = 1
				data.Data = input
				data.Message = fmt.Sprint("Successfully added UID to ", input, " !")

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "ws"
				data.Result = 0
				data.Data = "0"
				data.Message = "Failed to save UID to city instance."

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "wg":
			// get the UID from Firebase in the specific city instance
			status := -1
			list := list.List{}
			httpserver.App.GetUIDFromLocation(&status, input, &list)
			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "wg"
				data.Result = 1
				// Iterate the list
				UIDList := []string{}
				for e := list.Front(); e != nil; e = e.Next() {
					uid := e.Value.(string)
					UIDList = append(UIDList, uid)
				}
				data.Data = UIDList
				data.Message = fmt.Sprint("Successfully read UIDs from ", input, " !")
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "wg"
				data.Result = 0
				data.Data = "0"
				data.Message = "Failed to get UIDs from city instance."

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "z":
			// get detailed chat between two users (the input is the UID of the target)
			status := -1
			list := list.List{}
			httpserver.App.GetChatWithUID(&status, httpserver.CurrentToken.UID, input, &list)
			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "z"
				data.Result = 1
				data.Message = "Downloaded messages."
				// Iterate the list
				messageList := []message.Message{}
				for e := list.Front(); e != nil; e = e.Next() {
					message := message.Message(e.Value.(message.Message))
					messageList = append(messageList, message)
				}
				data.Data = messageList
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "z"
				data.Result = 0
				data.Data = "0"
				data.Message = "Failed downloading messages."

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}

		default:
			// operation not recognised
			data := HTTPResponse{}
			data.TransactionID = "-1"
			data.Result = 0
			data.Data = "0"
			data.Message = "Operation not recognised."

			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusCreated)
			json.NewEncoder(w).Encode(data)
		}
	}

}
