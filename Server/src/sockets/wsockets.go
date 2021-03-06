package wsockets

import (
	"log"

	"net/http"

	"github.com/gorilla/websocket"

	fbadmin "bismateServer/firebase"

	message "bismateServer/structs"
)

// WSocketServ -- WebSocket struct for real-time components of the bisMate system
type WSocketServ struct {
	clients    map[*websocket.Conn]bool
	clientsIDs map[*websocket.Conn]string
	broadcast  chan message.Message
	upgrader   websocket.Upgrader

	App fbadmin.FirebaseApp
}

// InitSocketServer -- initialises a WSocket structure
func (wserver *WSocketServ) InitSocketServer() {
	wserver.clients = make(map[*websocket.Conn]bool)
	wserver.clientsIDs = make(map[*websocket.Conn]string)
	wserver.broadcast = make(chan message.Message)
	wserver.upgrader = websocket.Upgrader{}

	wserver.App.InitFirebase()
}

// HandleConnections -- handler for server connections
func (wserver *WSocketServ) HandleConnections(w http.ResponseWriter, r *http.Request) {

	currentID := r.URL.Query().Get("clientID")

	// upgrade GET request to WS
	ws, err := wserver.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Fatal(err)
	}

	defer ws.Close() // CLOSE CONN ONLY AFTER HANDLER RETURNS

	// register client
	wserver.clients[ws] = true
	wserver.clientsIDs[ws] = currentID

	// infinite loop for message reading
	for {

		var msg message.Message
		err := ws.ReadJSON(&msg)
		if err != nil { // err on read, clear from conn table
			log.Printf("conn err: %v", err)
			delete(wserver.clients, ws)
			delete(wserver.clientsIDs, ws)
			break
		}

		// Sent messages are saved to the db references of sender and receiver
		saveResult := wserver.App.SaveMsgToRTDatabase(msg)
		if !saveResult {
			log.Println("err occured while saving messages ...")
		}

		// send received message to broadcast chan
		wserver.broadcast <- msg
	}

}

// HandleMessages -- reads from broadcast and relays to specific client over their specific ws connections
func (wserver *WSocketServ) HandleMessages() {
	for {

		msg := <-wserver.broadcast // get next message from broadcast

		for client := range wserver.clients {
			if msg.ToID == wserver.clientsIDs[client] {
				err := client.WriteJSON(msg)
				if err != nil { // err on write, close connections and clear from conn table
					log.Printf("msg write err: %v", err)
					client.Close()
					for clientWithID := range wserver.clientsIDs {
						if client == clientWithID {
							client.Close()
						}
					}
					delete(wserver.clients, client)
					delete(wserver.clientsIDs, client)
				}
			}
		}
	}
}
