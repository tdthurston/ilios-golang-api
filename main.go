package main

import (
	"log"
	"net/http"

	"github.com/tdthurston/ilios-final-project/handlers"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", rootHandler)
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

func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(`
        <!DOCTYPE html>
        <html>
        <head>
            <title>Welcome to Ilios API</title>
        </head>
        <body>
            <h1>Welcome to Ilios API</h1>
            <p>This API provides information about VPCs, EC2 instances, and EKS clusters currently running in your AWS environment.</p>
            <ul>
                <li><a href="/vpcs">/vpcs</a> - Get information about VPCs</li>
                <li><a href="/ec2s">/ec2s</a> - Get information about EC2 instances</li>
                <li><a href="/eks">/eks</a> - Get information about EKS clusters</li>
                <li><a href="/health">/health</a> - Check the health status of the application</li>
            </ul>
        </body>
        </html>
    `))
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
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(eks))
}

func HealthCheckHandler(w http.ResponseWriter, r *http.Request) {
	handlers.StatusCheck(w, r)
}
