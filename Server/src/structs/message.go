package message

// Message -- message object
type Message struct {
	Message string `json:"text"`
	FromID  string `json:"fromID"`
	ToID    string `json:"toID"`
}
