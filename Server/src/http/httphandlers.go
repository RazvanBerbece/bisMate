package httphandlers

import (
	"context"

	"encoding/json"

	"log"

	"net/http"

	fbadmin "bismateServer/firebase"
)

// HTTPResponse -- generic response for incoming HTTP requests
type HTTPResponse struct {
	TransactionID int
	Result        int
	Data          string
}

// HTTPServ -- handlers for HTTP requests from client
type HTTPServ struct {
	CurrentToken string
	App          fbadmin.FirebaseApp
}

// HTTPInit -- initialises the struct variables
func (httpserver *HTTPServ) HTTPInit() {
	httpserver.CurrentToken = ""
	httpserver.App.InitFirebase()
}

// HandleConn -- handler for server connections
func (httpserver *HTTPServ) HandleConn(w http.ResponseWriter, r *http.Request) {

	data := HTTPResponse{}
	data.TransactionID = 0
	data.Result = 1
	data.Data = "Hello World!"

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(data)

}

// HandleTokenVerify -- handler for server verify transactions
func (httpserver *HTTPServ) HandleTokenVerify(w http.ResponseWriter, r *http.Request) {

	httpserver.CurrentToken = r.URL.Query().Get("token")
	/*
		operations :
		0 = Change Bio
		1 = Change Display Name
		2 = Add Profile Picture

		d = Delete Account
		c = Change Password

		x = 'Connect' (verify token -> add new entry to connections of token.UID)
		s = Save Messages (periodic on client)
	*/
	operation := r.URL.Query().Get("operation")

	log.Printf("Incoming verify request with op: %s ...\n", operation)

	// Verify logic
	token, err := httpserver.App.Auth.VerifyIDToken(context.Background(), httpserver.CurrentToken)
	if err != nil { // err
		log.Printf("TokenVerify err : %v\n", err)
		// Response logic
		data := HTTPResponse{}
		data.TransactionID = 1
		data.Result = 0
		data.Data = "Error while verifying token."

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusCreated)
		json.NewEncoder(w).Encode(data)
	} else { // success
		log.Print("Verified ID token successfully")
		switch operation {
		case "1":
			// change display name
			log.Printf("token : %v", token)
		default:
			// operation not recognised
			data := HTTPResponse{}
			data.TransactionID = 1
			data.Result = 0
			data.Data = "Operation not recognised."

			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusCreated)
			json.NewEncoder(w).Encode(data)
		}
	}

}
