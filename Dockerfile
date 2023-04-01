FROM golang:latest

RUN go install git.icyphox.sh/vite@latest

WORKDIR /app 

ENTRYPOINT ["vite", "build"]
