package main

import (
	"log"
	"net/http"

	"github.com/tdthurston/ilios-final-project/handlers"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/vpcs", vpcHandler)
	mux.HandleFunc("/ec2s", ec2Handler)
	mux.HandleFunc("/eks", eksHandler)
	mux.HandleFunc("/health", HealthCheckHandler)
	log.Println("Listening on :8080")
	err := http.ListenAndServe(":8080", mux)
	if err != nil {
		log.Fatal("ListenAndServe", err)
	}
}

func vpcHandler(w http.ResponseWriter, r *http.Request) {
	vpcs := handlers.VpcInfo()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(vpcs))
}

func ec2Handler(w http.ResponseWriter, r *http.Request) {
	ec2s := handlers.Ec2Info()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(ec2s))
}

func eksHandler(w http.ResponseWriter, r *http.Request) {
	eks := handlers.EksInfo()
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(eks))
}


func HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	handlers.StatusCheck(w, r)
}
