package main

import (
	wsockets "bismateServer/sockets"
	"log"
	"net/http"
)

func main() {

	log.Println("Server listening on :8000 ...")

	// Configure websocket server
	wserver := wsockets.WSocketServ{}
	wserver.InitSocketServer()

	// Configure websocket route
	http.HandleFunc("/ws", wserver.HandleConnections)

	// Listen for incoming messages
	go wserver.HandleMessages()

	// Start server on localhost:8000 and log errs
	err := http.ListenAndServe(":8000", nil)
	if err != nil {
		log.Fatal("ListenAndServe(): ", err)
	}

}
