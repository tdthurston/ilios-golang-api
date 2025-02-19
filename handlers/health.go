package handlers

import (
	"net/http"
)

func StatusCheck(w http.ResponseWriter, r *http.Request) {
	status := "HTTP 200 - OK"
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(status))
}