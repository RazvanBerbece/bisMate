package fbadmin

import (
	"context"

	"fmt"

	firebase "firebase.google.com/go"

	"firebase.google.com/go/auth"

	"google.golang.org/api/option"

	"log"

	"os"

	message "bismateServer/structs"

	"container/list"
)

// User -- logic representation of a FB user
type User struct {
	UID           string
	Email         string
	DisplayName   string
	PhoneNumber   string
	PhotoURL      string
	EmailVerified bool
}

// SetUser -- sets a User structure with input data
func (user *User) SetUser(UID string, Email string, DisplayName string, PhoneNumber string, PhotoURL string, EmailVerified bool) {
	user.DisplayName = DisplayName
	user.UID = UID
	user.Email = Email
	user.PhoneNumber = PhoneNumber
	user.PhotoURL = PhotoURL
	user.EmailVerified = EmailVerified
}

// FirebaseApp -- holds the app reference for fb operations
type FirebaseApp struct {
	App  firebase.App
	Auth auth.Client
}

// InitFirebase -- Initialises the FB instance with the config file
func (fbapp *FirebaseApp) InitFirebase() {

	path, err := os.Getwd()
	if err != nil {
		log.Println(err)
	}
	opt := option.WithCredentialsFile(fmt.Sprintf("%s/firebase/conf.json", path))
	// get database config from firebase url
	conf := &firebase.Config{
		DatabaseURL: "https://bismate-1683a-default-rtdb.firebaseio.com/",
	}
	app, err := firebase.NewApp(context.Background(), conf, opt)
	if err != nil {
		log.Printf("err: %v", err)
		return
	}

	fbapp.App = *app
	// get Auth client
	client, err := fbapp.App.Auth(context.Background())
	if err != nil {
		log.Printf("err: %v", err)
	}
	fbapp.Auth = *client

}

// SignUp -- creates a user using Firebase Auth
func (fbapp *FirebaseApp) SignUp(email string, pass string) {

	// build create request and send
	params := (&auth.UserToCreate{}).
		Email(email).
		EmailVerified(false).
		Password(pass).
		DisplayName(email).
		// PhotoURL("http://www.example.com/12345678/photo.png"). default pic maybe ?
		Disabled(false)
	u, err := fbapp.Auth.CreateUser(context.Background(), params)
	if err != nil {
		log.Printf("error creating user: %v\n", err)
	}
	log.Printf("Successfully created user: %v\n", u.UID)

}

// SignIn -- on Client, then will use tokens

// Messaging-Related Operations

// SaveMsgToRTDatabase -- saves a message given as a parameter in the Firebase RT database
func (fbapp *FirebaseApp) SaveMsgToRTDatabase(msg message.Message) bool {

	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		log.Printf("error establishing connection to database: %v", err)
		return false
	}

	// get references and push
	refSender := client.NewRef(fmt.Sprintf("messaging/saved-msg/%s/%s", msg.FromID, msg.ToID))
	if _, errSender := refSender.Push(context.Background(), msg); errSender != nil {
		log.Printf("error saving to database: %v", errSender)
		return false
	}

	refReceiver := client.NewRef(fmt.Sprintf("messaging/saved-msg/%s/%s", msg.ToID, msg.FromID))
	if _, errReceiver := refReceiver.Push(context.Background(), msg); errReceiver != nil {
		log.Printf("error saving to database: %v", errReceiver)
		return false
	}

	return true

}

// GetChatWithUID -- gets the detailed chat between two users specified by their uids
func (fbapp *FirebaseApp) GetChatWithUID(status *int, sourceUID string, destUID string, messages *list.List) {

	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		log.Printf("error establishing connection to database: %v", err)
		*status = 0
		*messages = list.List{}
	}

	// get references and the messages from the reference
	ref := client.NewRef(fmt.Sprintf("messaging/saved-msg/%s/%s", sourceUID, destUID))
	var data map[string]message.Message
	if err := ref.Get(context.Background(), &data); err != nil {
		log.Printf("error getting messages from databse: %v", err)
		*status = 0
		*messages = list.List{}
	}
	// data will be returned as a list of Message type objects
	list := list.New()
	for _, element := range data {
		list.PushBack(element)
	}

	*status = 1
	*messages = *list

}

// User Profile Operations

// GetUserProfile -- gets the user profile using the UID param
func (fbapp *FirebaseApp) GetUserProfile(status *int, UID string) User {

	u, err := fbapp.Auth.GetUser(context.Background(), UID)
	if err != nil {
		log.Printf("error getting user: %v\n", err)
		*status = 0
	}

	// init user structure with response data
	user := User{}
	user.SetUser(u.UID, u.Email, u.DisplayName, u.PhoneNumber, u.PhotoURL, u.EmailVerified)
	*status = 1

	return user

}

// ChangeDisplayName -- changes user's display name
func (fbapp *FirebaseApp) ChangeDisplayName(newName string, status *int, UID string) {

	// build create request and send
	params := (&auth.UserToUpdate{}).
		DisplayName(newName)
	u, err := fbapp.Auth.UpdateUser(context.Background(), UID, params)
	if err != nil {
		log.Printf("error updating user: %v\n", err)
		*status = 0
	}
	log.Printf("Successfully updated user: %v\n", u.UID)
	*status = 1
}

// Location-Related Operations

// SaveUIDToLocation -- saves a UID in Firebase in a city-specific entry
func (fbapp *FirebaseApp) SaveUIDToLocation(status *int, UID string, City string) {

	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		log.Printf("error establishing connection to database: %v", err)
		*status = 0
	}

	// get reference or create it and push UID
	ref := client.NewRef(fmt.Sprintf("locations/saved-locations/%s", City))
	if _, errSender := ref.Push(context.Background(), UID); errSender != nil {
		log.Printf("error saving to database: %v", errSender)
		*status = 0
	}

	*status = 1

}

// GetUIDFromLocation -- gets a list of UIDs from the specific city entry in the DB
func (fbapp *FirebaseApp) GetUIDFromLocation(status *int, City string, UIDList *list.List) {

	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		log.Printf("error establishing connection to database: %v", err)
		*status = 0
	}

	// get references and the messages from the reference
	ref := client.NewRef(fmt.Sprintf("locations/saved-locations/%s", City))
	var data map[string]string
	if err := ref.Get(context.Background(), &data); err != nil {
		log.Printf("error getting messages from databse: %v", err)
		*status = 0
		*UIDList = list.List{}
	}
	// data will be returned as a list of Message type objects
	list := list.New()
	for _, element := range data {
		list.PushBack(element)
	}

	*status = 1
	*UIDList = *list

	*status = 1

}
