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

		USER PROFILE DATA
		0 = Get User Profile 						(params -> UID : String)
		ubg = Get Bio 								(params -> UID : String)
		ubs = Set Bio								(params -> Bio : String)
		2 = Change Display Name     				(params -> DisplayName : String)
		pps = Set Profile Picture     				(params -> ImageData : String)
		ppg = Get Profile Picture 					(params -> UID: String)

		ACCOUNT HIGH SECURITY OPS
		d = Delete Account
		c = Change Password							(params -> Pass : String)

		LOCATION HANDLERS
		ws 	= UID Location (PUSH) 					(params -> UID : String, City : String)
		wg 	= UID Location (GET)					(params -> UID : String, City : String)
		wd  = UID Loication (DELETE)				(params -> UID : string, City : String)

		CONNECTION COMPONENT
		xs 	= LikedBy (PUSH)						(params -> UID : String, LikedUID: String)
		xg 	= LikedBy (GET)							(params -> UID : String, LikedUID: String)
		xx  = Likes (GET)							(params -> UID : String)
		xxy = Matches (GET)							(params -> UID : String)

		MESSAGING COMPONENT
		y 	= Get all messages of user with UID
		z 	= Get detailed chat between users
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

		case "ubg":

			// get user bio
			bio, err := httpserver.App.GetUserBio(input)

			if err == "" {
				data := HTTPResponse{}
				data.TransactionID = "ubg"
				data.Result = 1
				data.Data = bio
				data.Message = "Successfully retrieved user bio"

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "ubg"
				data.Result = 0
				data.Data = ""
				data.Message = "Error occured while retrieving user bio"

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "ubs":

			// set user bio
			status := -1
			httpserver.App.SetUserBio(&status, httpserver.CurrentToken.UID, input)

			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "ubs"
				data.Result = 1
				data.Data = input
				data.Message = "Successfully set user bio"

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "ubs"
				data.Result = 0
				data.Data = ""
				data.Message = "Error occured while setting user bio"

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "pps":

			// get data from request form
			err := r.ParseMultipartForm(1000 * 1500)
			if err != nil {
				data := HTTPResponse{}
				data.TransactionID = "pps"
				data.Result = 0
				data.Data = ""
				data.Message = "Error occured while setting user profile picture"

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}

			data := r.FormValue("imageData")

			// set user profile pic
			status := -1
			httpserver.App.SetProfilePicture(&status, httpserver.CurrentToken.UID, data)

			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "pps"
				data.Result = 1
				data.Data = input
				data.Message = "Successfully set user profile picture"

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "pps"
				data.Result = 0
				data.Data = ""
				data.Message = "Error occured while setting user profile picture"

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "ppg":

			// get user profile picture
			imageData, err := httpserver.App.GetProfilePicture(input)

			if err == "" {
				data := HTTPResponse{}
				data.TransactionID = "ppg"
				data.Result = 1
				data.Data = imageData
				data.Message = "Successfully retrieved user profile picture."

				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "ppg"
				data.Result = 0
				data.Data = ""
				data.Message = "Error occured while retrieving user profile picture."

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
		case "wd":
			// delete UID from location entry in DB
			success, fail := httpserver.App.RemoveUIDFromLocation(httpserver.CurrentToken.UID, input)
			if success != "" {
				data := HTTPResponse{}
				data.TransactionID = "wd"
				data.Result = 1
				// Iterate the list
				data.Data = input
				data.Message = fmt.Sprint("Successfully deleted UID from ", input, " !")
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "wd"
				data.Result = 0
				// Iterate the list
				data.Data = input
				data.Message = fmt.Sprint(fail)
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "xs":
			//
			//	Users have two lists in Firebase :
			//		- Liked = UIDs that liked the user
			//		- Connected = successful connections
			//
			// 	User 1 likes User 2 => Add User 1 UID to User 2 Liked list
			// 	User 2 likes User 1 =>
			// 		- Add User 1 to User 2 Connected list
			//		- Add User 2 to User 1 Connected list
			//		- Delete each user from their opposite Liked lists
			status := -1
			httpserver.App.LikeUser(&status, httpserver.CurrentToken.UID, input)
			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "xs"
				data.Result = 1
				data.Message = fmt.Sprintf("Liked user with UID %s.", input)
				data.Data = input
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "xs"
				data.Result = 0
				data.Data = "nil"
				data.Message = fmt.Sprintf("Failed to like user with UID %s.", input)
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "xg":
			status := -1
			list := list.List{}
			httpserver.App.GetLikedByListForUser(&status, httpserver.CurrentToken.UID, &list)
			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "xg"
				data.Result = 1
				data.Message = fmt.Sprintf("Got likedBy for UID %s.", input)
				// Iterate the list
				uidList := []string{}
				for e := list.Front(); e != nil; e = e.Next() {
					uid := string(e.Value.(string))
					uidList = append(uidList, uid)
				}
				data.Data = uidList
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "xg"
				data.Result = 0
				data.Data = "nil"
				data.Message = "Failed to get user likedBy."
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "xx":
			status := -1
			list := list.List{}
			httpserver.App.GetLikesListForUser(&status, httpserver.CurrentToken.UID, &list)
			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "xx"
				data.Result = 1
				data.Message = fmt.Sprintf("Got likes for UID %s.", input)
				// Iterate the list
				uidList := []string{}
				for e := list.Front(); e != nil; e = e.Next() {
					uid := string(e.Value.(string))
					uidList = append(uidList, uid)
				}
				data.Data = uidList
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "xx"
				data.Result = 0
				data.Data = "nil"
				data.Message = "Failed to get user likes."
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			}
		case "xxy":
			// get matches list
			status := -1
			list := list.List{}
			httpserver.App.GetMatches(&status, httpserver.CurrentToken.UID, &list)
			if status == 1 {
				data := HTTPResponse{}
				data.TransactionID = "xxy"
				data.Result = 1
				data.Message = fmt.Sprintf("Got matches for UID %s.", input)
				// Iterate the list
				uidList := []string{}
				for e := list.Front(); e != nil; e = e.Next() {
					uid := string(e.Value.(string))
					uidList = append(uidList, uid)
				}
				data.Data = uidList
				w.Header().Set("Content-Type", "application/json")
				w.WriteHeader(http.StatusCreated)
				json.NewEncoder(w).Encode(data)
			} else {
				data := HTTPResponse{}
				data.TransactionID = "xxy"
				data.Result = 0
				data.Data = "nil"
				data.Message = "Failed to get user matches."
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
