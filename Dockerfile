FROM golang:latest

RUN go install github.com/toozej/go-vite@latest

WORKDIR /app 

ENTRYPOINT ["go-vite", "build"]
