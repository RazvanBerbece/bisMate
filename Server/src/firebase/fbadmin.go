package fbadmin

import (
	"context"

	"fmt"

	firebase "firebase.google.com/go"

	"firebase.google.com/go/auth"

	"google.golang.org/api/option"

	"log"

	"os"
)

// FirebaseApp -- holds the app reference for fb operations
type FirebaseApp struct {
	App  firebase.App
	Auth auth.Client
}

// InitFirebase -- Initialises the FB instance with the config file
func (fbapp *FirebaseApp) InitFirebase() {

	log.Println("Initialising ...")

	path, err := os.Getwd()
	if err != nil {
		log.Println(err)
	}
	opt := option.WithCredentialsFile(fmt.Sprintf("%s/firebase/conf.json", path))
	app, err := firebase.NewApp(context.Background(), nil, opt)
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

// Operations
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
