package main

func ec2Handler(w http.ResponseWriter, r *http.Request) {
	ec2s := GetRandomJoke()
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(joke))
}