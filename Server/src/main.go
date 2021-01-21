package main

import (
	httphandlers "bismateServer/http"
	wsockets "bismateServer/sockets"
	"log"
	"net/http"
)

func main() {

	log.Println("Server listening on :8000 ...")

	// Configure websocket server
	wserver := wsockets.WSocketServ{}
	wserver.InitSocketServer()

	// Configure http handlers
	httpHandlers := httphandlers.HTTPServ{}
	httpHandlers.HTTPInit()

	// Configure websocket route -- clients will send an id query param (clientID : <id here>) that will be used to enable one-on-one chats
	http.HandleFunc("/ws", wserver.HandleConnections)
	http.HandleFunc("/conn", httpHandlers.HandleConn)
	http.HandleFunc("/operation", httpHandlers.HandleTokenVerify)

	// Listen for incoming messages
	go wserver.HandleMessages()

	// Start server on localhost:8000 and log errs
	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		log.Fatal("ListenAndServe(): ", err)
	}

}
