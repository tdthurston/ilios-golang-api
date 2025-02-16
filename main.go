package main

import (
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/vpcs", vpcHandler)
//	mux.HandleFunc("/ec2s", ec2Handler)
//	mux.HandleFunc("/eks", eksHandler)
//	mux.HandleFunc("/health", healthHandler)
	log.Println("Listening on :8080")
	err := http.ListenAndServe(":8080", mux)
	if err != nil {
		log.Fatal("ListenAndServe", err)
	}
}

func vpcHandler(w http.ResponseWriter, r *http.Request) {
	vpcs := VpcResponse()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(vpcs))
}