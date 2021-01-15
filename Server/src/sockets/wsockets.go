package wsockets

import (
	"log"

	"net/http"

	"github.com/gorilla/websocket"

	"fmt"
)

// Message -- message object
type Message struct {
	Message string `json:"message"`
}

// WSocketServ -- WebSocket struct for real-time components of the bisMate system
type WSocketServ struct {
	clients   map[*websocket.Conn]bool
	broadcast chan Message
	upgrader  websocket.Upgrader
}

// InitSocketServer -- initialises a WSocket structure
func (wserver WSocketServ) InitSocketServer() {
	wserver.clients = make(map[*websocket.Conn]bool)
	wserver.broadcast = make(chan Message)
	wserver.upgrader = websocket.Upgrader{}
}

// HandleConnections -- handler for server connections
func (wserver WSocketServ) HandleConnections(w http.ResponseWriter, r *http.Request) {

	fmt.Println("Incoming connection ...")

	// upgrade GET request to WS
	ws, err := wserver.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Fatal(err)
	}

	defer ws.Close() // CLOSE CONN ONLY AFTER HANDLER RETURNS

	// register client
	wserver.clients[ws] = true

	// infinite loop
	for {
		var msg Message

		err := ws.ReadJSON(&msg)
		if err != nil {
			log.Printf("err: %v", err)
			delete(wserver.clients, ws)
			break
		}

		fmt.Printf("msg : %v", msg)

		// send received message to broadcast chan
		wserver.broadcast <- msg
	}

}

// HandleMessages -- reads from broadcast and relays to all client over their specific ws connections
func (wserver WSocketServ) HandleMessages() {
	for {

		msg := <-wserver.broadcast // get next message from broadcast

		for client := range wserver.clients {
			err := client.WriteJSON(msg)
			if err != nil {
				log.Printf("err: %v", err)
				client.Close()
				delete(wserver.clients, client)
			}
		}
	}
}
