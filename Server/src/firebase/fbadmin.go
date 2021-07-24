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

	// Create connecting logic storage units in Firebase for the user
	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		log.Printf("error establishing connection to database: %v", err)
	}

	// get liked and connected references and push empty lists
	refLiked := client.NewRef(fmt.Sprintf("connections/%s/liked", u.UID))
	if _, errSender := refLiked.Push(context.Background(), ""); errSender != nil {
		log.Printf("error initialising databse: %v", errSender)
	}
	refConnected := client.NewRef(fmt.Sprintf("connections/%s/connected", u.UID))
	if _, errSender := refConnected.Push(context.Background(), ""); errSender != nil {
		log.Printf("error initialising databse: %v", errSender)
	}

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
	// get ordered instances of messages
	results, err := ref.OrderByChild("time").GetOrdered(context.Background())
	if err != nil {
		log.Printf("error getting messages from databse: %v", err)
		*status = 0
		*messages = list.List{}
	}
	// data will be returned as a list of Message type objects
	list := list.New()
	for _, element := range results {
		var msg message.Message
		if err := element.Unmarshal(&msg); err != nil {
			log.Printf("error unmarhsaling result: %v", err)
			*status = 0
			*messages = *list
		}
		list.PushBack(msg)
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

	ref := client.NewRef(fmt.Sprintf("locations/saved-locations/%s/%s", City, UID))

	// check if UID is already in current city instance, skip if it is
	var data map[string]bool
	if err := ref.Get(context.Background(), &data); err != nil {
		log.Printf("error getting messages from databse: %v", err)
		*status = 0
	}
	if len(data) == 0 {
		// push UID
		if _, errSender := ref.Push(context.Background(), true); errSender != nil {
			log.Printf("error saving to database: %v", errSender)
			*status = 0
		}
		// remove from other locations on update
		// TODO
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
		*UIDList = list.List{}
	}

	// get references and the messages from the reference
	ref := client.NewRef(fmt.Sprintf("locations/saved-locations/%s", City))
	var data map[string]bool
	if err := ref.Get(context.Background(), &data); err != nil {
		log.Printf("error getting messages from database: %v", err)
		*status = 0
		*UIDList = list.List{}
	}

	// data will be returned as a list of strings
	list := list.New()
	for key := range data { // each key is an UID
		list.PushBack(key)
	}

	*UIDList = *list
	*status = 1

}

// Connection-related operations

// LikeUser -- Adds sourceUID to destUID liked list
func (fbapp *FirebaseApp) LikeUser(status *int, sourceUID string, destUID string) {

	// Create connecting logic storage units in Firebase for the user
	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		*status = 0
		log.Printf("error establishing connection to database: %v", err)
	}

	// the UIDs in the LikedBy HAVE to be unique (ie: a user can't be liked twice by the same user)
	var data map[string]string
	uidExists := false
	refLikedBy := client.NewRef(fmt.Sprintf("connections/%s/likedBy", destUID))
	if errSender := refLikedBy.Get(context.Background(), &data); errSender != nil {
		*status = 0
		log.Printf("error getting likedBy list: %v", errSender)
	}
	for key := range data {
		if data[key] == sourceUID {
			uidExists = true
			break
		}
	}

	if uidExists { // don't push
		*status = 1
	} else { // UID not in list, push
		// get likedBy reference and push UID
		if _, errSender := refLikedBy.Push(context.Background(), sourceUID); errSender != nil {
			*status = 0
			log.Printf("error adding user to likedBy list: %v", errSender)
		}

		// save like for sourceUID
		refSaved := client.NewRef(fmt.Sprintf("connections/%s/likes", sourceUID))
		if _, errSender := refSaved.Push(context.Background(), destUID); errSender != nil {
			*status = 0
			log.Printf("error getting liked list: %v", errSender)
		}

		// check if liked by the other user and move UIDs to matches list if so
		var data map[string]string
		refMatchClient := client.NewRef(fmt.Sprintf("connections/%s/likedBy", sourceUID))
		if errSender := refMatchClient.Get(context.Background(), &data); errSender != nil {
			*status = 0
			log.Printf("error adding user to likedBy list: %v", errSender)
		}

		// iterate likedBy list for current user
		// if likedBy holds the UID which was just liked, we have a match
		for key := range data {
			if data[key] == destUID {

				// push to matches list of both users
				refMatchUserOne := client.NewRef(fmt.Sprintf("connections/%s/matches", sourceUID))
				refMatchUserTwo := client.NewRef(fmt.Sprintf("connections/%s/matches", destUID))
				if _, errSenderOne := refMatchUserOne.Push(context.Background(), destUID); errSenderOne != nil {
					*status = 0
					log.Printf("error adding user to matches list: %v", errSenderOne)
					return
				}
				if _, errSenderTwo := refMatchUserTwo.Push(context.Background(), sourceUID); errSenderTwo != nil {
					*status = 0
					log.Printf("error adding user to matches list: %v", errSenderTwo)
					return
				}

				// sanitise database
				// delete likes from sourceUID and destUID
				fbapp.DeleteLikesAfterMatch(status, sourceUID, destUID)
				fbapp.DeleteLikesAfterMatch(status, destUID, sourceUID)

				break
			}
		}

		*status = 1
	}

}

// GetLikedListForUser -- Gets the LikedBy list for the user with UID
func (fbapp *FirebaseApp) GetLikedByListForUser(status *int, UID string, UIDList *list.List) {

	// Create connecting logic storage units in Firebase for the user
	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		*status = 0
		*UIDList = list.List{}
		log.Printf("error establishing connection to database: %v", err)
	}

	// get list from liked ref
	var data map[string]string
	refLiked := client.NewRef(fmt.Sprintf("connections/%s/likedBy", UID))
	if err := refLiked.Get(context.Background(), &data); err != nil {
		*status = 0
		*UIDList = list.List{}
		log.Printf("error adding user to liked list: %v", err)
	}

	// data will be returned as a list of strings
	list := list.New()
	for key := range data {
		list.PushBack(data[key])
	}

	*UIDList = *list
	*status = 1

}

// GetLikesListForUser -- Gets the Likes list for the user with UID
func (fbapp *FirebaseApp) GetLikesListForUser(status *int, UID string, UIDList *list.List) {

	// Create connecting logic storage units in Firebase for the user
	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		*status = 0
		*UIDList = list.List{}
		log.Printf("error establishing connection to database: %v", err)
	}

	// get list from liked ref
	var data map[string]string
	refLiked := client.NewRef(fmt.Sprintf("connections/%s/likes", UID))
	if err := refLiked.Get(context.Background(), &data); err != nil {
		*status = 0
		*UIDList = list.List{}
		log.Printf("error adding user to liked list: %v", err)
	}

	// data will be returned as a list of strings
	list := list.New()
	for key := range data {
		list.PushBack(data[key])
	}

	*UIDList = *list
	*status = 1

}

// GetMatches -- Gets the list of matches under sourceUID
func (fbapp *FirebaseApp) GetMatches(status *int, sourceUID string, UIDList *list.List) {

	// Create connecting logic storage units in Firebase for the user
	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		*status = 0
		*UIDList = list.List{}
		log.Printf("error establishing connection to database: %v", err)
		return
	}

	// Get the likes list data
	var matchesDict map[string]string
	refLikes := client.NewRef(fmt.Sprintf("connections/%s/matches", sourceUID))
	if errLikes := refLikes.Get(context.Background(), &matchesDict); errLikes != nil {
		*status = 0
		*UIDList = list.List{}
		log.Printf("error getting dict: %v", errLikes)
		return
	}

	list := list.List{}
	for key := range matchesDict {
		list.PushBack(matchesDict[key])
	}

	*UIDList = list
	*status = 1

}

// DeleteLikesAfterMatch -- Deletes a UID from the user's likedBy and likes lists in the Firebase Database
func (fbapp *FirebaseApp) DeleteLikesAfterMatch(status *int, sourceUID string, matchUID string) {

	// Create connecting logic storage units in Firebase for the user
	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		*status = 0
		log.Printf("error establishing connection to database: %v", err)
		return
	}

	// Get the likes list data
	var likesDict map[string]string
	refLikes := client.NewRef(fmt.Sprintf("connections/%s/likes", sourceUID))
	if errLikes := refLikes.Get(context.Background(), &likesDict); errLikes != nil {
		*status = 0
		log.Printf("error getting dict: %v", errLikes)
		return
	}

	// Delete the data of the match from the likes list
	for extKey := range likesDict {
		if likesDict[extKey] == matchUID {
			refDeleteLikes := client.NewRef(fmt.Sprintf("connections/%s/likes/%s", sourceUID, extKey))
			if errDeleteLikes := refDeleteLikes.Delete(context.Background()); errDeleteLikes != nil {
				*status = 0
				log.Printf("error deleting user from likes list: %v", errDeleteLikes)
				return
			}
		}
	}

	// Get the likedBy list data
	var likedByDict map[string]string
	refLikedBy := client.NewRef(fmt.Sprintf("connections/%s/likedBy", sourceUID))
	if errLikedBy := refLikedBy.Get(context.Background(), &likedByDict); errLikedBy != nil {
		*status = 0
		log.Printf("error getting dict: %v", errLikedBy)
		return
	}

	// Delete the data of the match from the likes list
	for extKey := range likedByDict {
		if likedByDict[extKey] == matchUID {
			refDeleteLikedBy := client.NewRef(fmt.Sprintf("connections/%s/likedBy/%s", sourceUID, extKey))
			if errDeleteLikedBy := refDeleteLikedBy.Delete(context.Background()); errDeleteLikedBy != nil {
				*status = 0
				log.Printf("error deleting user from likedBy list: %v", errDeleteLikedBy)
				return
			}
		}
	}

	*status = 1

}

// GetUserBio -- Gets a user bio from FB Realtime DB using UID
func (fbapp *FirebaseApp) GetUserBio(UID string) (string, string) {

	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		log.Printf("error establishing connection to database: %v", err)
		return "", "Connection to DB failed"
	}

	var bio string

	// get references and the messages from the reference
	ref := client.NewRef(fmt.Sprintf("users/%s", UID))
	// get ordered instances of messages
	if err := ref.Child("bio").Get(context.Background(), &bio); err != nil {
		log.Printf("error getting user bio from database: %v", err)
		return "", "Get User Bio failed"
	}

	return bio, ""

}

// SetUserBio -- Saves a user bio to FB Realtime DB under UID/bio
func (fbapp *FirebaseApp) SetUserBio(status *int, UID string, bio string) {

	// get app for database
	client, err := fbapp.App.Database(context.Background())
	if err != nil {
		log.Printf("error establishing connection to database: %v", err)
		*status = 0
	}

	// get references and push
	refSender := client.NewRef(fmt.Sprintf("users/%s", UID))
	if errSender := refSender.Child("bio").Set(context.Background(), bio); errSender != nil {
		log.Printf("error saving to database: %v", errSender)
		*status = 0
	}

	*status = 1

}
