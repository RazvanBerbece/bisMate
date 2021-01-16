package wsockets

import (
	"log"

	"net/http"

	"github.com/gorilla/websocket"

	"strconv"
)

// Message -- message object
type Message struct {
	Message string `json:"text"`
	FromID  int64  `json:"fromID"`
	ToID    int64  `json:"ToID"`
}

// WSocketServ -- WebSocket struct for real-time components of the bisMate system
type WSocketServ struct {
	clients    map[*websocket.Conn]bool
	clientsIDs map[*websocket.Conn]int64
	broadcast  chan Message
	upgrader   websocket.Upgrader
}

// InitSocketServer -- initialises a WSocket structure
func (wserver *WSocketServ) InitSocketServer() {
	wserver.clients = make(map[*websocket.Conn]bool)
	wserver.clientsIDs = make(map[*websocket.Conn]int64)
	wserver.broadcast = make(chan Message)
	wserver.upgrader = websocket.Upgrader{}
}

// HandleConnections -- handler for server connections
func (wserver *WSocketServ) HandleConnections(w http.ResponseWriter, r *http.Request) {

	log.Printf("Incoming connection with ID %s ...\n", r.URL.Query().Get("clientID"))
	currentID, err := strconv.ParseInt(r.URL.Query().Get("clientID"), 0, 64)
	if err != nil {
		log.Println("ID err")
	}
	log.Printf("Current ID : %d", currentID)

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

		var msg Message
		err := ws.ReadJSON(&msg)
		if err != nil {
			log.Printf("conn err: %v", err)
			delete(wserver.clients, ws)
			break
		}

		// fmt.Println(msg.FromID)
		// fmt.Println(msg.ToID)

		// send received message to broadcast chan
		wserver.broadcast <- msg
	}

}

// HandleMessages -- reads from broadcast and relays to all client over their specific ws connections
func (wserver *WSocketServ) HandleMessages() {
	for {

		msg := <-wserver.broadcast // get next message from broadcast

		for client := range wserver.clients {
			if msg.ToID == wserver.clientsIDs[client] {
				err := client.WriteJSON(msg)
				if err != nil {
					log.Printf("msg write err: %v", err)
					client.Close()
					delete(wserver.clients, client)
				}
			}
		}
	}
}
