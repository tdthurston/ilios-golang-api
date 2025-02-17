package main

import (
	"log"
	"net/http"

	"github.com/tdthurston/ilios-final-project/handlers"
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
	vpcs := handlers.VpcResponse()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(vpcs))
}

/*
func ec2Handler(w http.ResponseWriter, r *http.Request) {
	ec2s := GetRandomJoke()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(joke))
}

func eksHandler(w http.ResponseWriter, r *http.Request) {
	eks := GetMadLib()
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(madLib))
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	joke := GetRandomJoke()
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(joke))
}
*/
