package main

import (
	httphandlers "bismateServer/http"
	wsockets "bismateServer/sockets"
	"log"
	"net/http"
)

func main() {

	log.Println("Server listening on :443 ...")

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

	// Start server (HTTPS) on localhost:443 and log errs
	/* WITH TLS <- used in production
	err := http.ListenAndServeTLS(":443", "cert/server.crt", "cert/server.key", nil)
	if err != nil {
		log.Fatal("ListenAndServe(): ", err)
	}
	*/
	// WITHOUT TLS
	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		log.Fatal("ListenAndServe(): ", err)
	}

}
