FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -o main .

FROM alpine:latest

COPY --from=builder /app/main /app/main

EXPOSE 8080

CMD ["/app/main"]