package main

func healthHandler(w http.ResponseWriter, r *http.Request) {
	joke := GetRandomJoke()
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(joke))
}