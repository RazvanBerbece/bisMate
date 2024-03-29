package main

import (
	httphandlers "bismateServer/http"
	wsockets "bismateServer/sockets"
	"log"
	"net/http"
)

func main() {

	// Configure websocket server
	port := ":8000"
	wserver := wsockets.WSocketServ{}
	wserver.InitSocketServer()

	log.Printf("Server listening on localhost%s ...", port)

	// Configure http handlers
	httpHandlers := httphandlers.HTTPServ{}
	httpHandlers.HTTPInit()

	// Configure websocket route -- clients will send an id query param (clientID : <id here>) that will be used to enable one-on-one chats
	http.HandleFunc("/ws", wserver.HandleConnections)
	http.HandleFunc("/conn", httpHandlers.HandleConn)
	http.HandleFunc("/operation", httpHandlers.HandleTokenVerify)

	// Listen for incoming messages
	go wserver.HandleMessages()

	// Start server (HTTPS) on localhost:443 / localhost:8000 and log errs
	/* WITH TLS <- used in production
	err := http.ListenAndServeTLS(port, "cert/server.crt", "cert/server.key", nil)
	if err != nil {
		log.Fatal("ListenAndServe(): ", err)
	}
	*/
	// WITHOUT TLS
	err := http.ListenAndServe(port, nil)
	if err != nil {
		log.Fatal("ListenAndServe(): ", err)
	}

}
