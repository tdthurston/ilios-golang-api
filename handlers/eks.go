package main

func eksHandler(w http.ResponseWriter, r *http.Request) {
	eks := GetMadLib()
	w.Header().Set("Content-Type", "text/plain")
	w.WriteHeader(http.StatusOK)
	_, _ = w.Write([]byte(madLib))
}