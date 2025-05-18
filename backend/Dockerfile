FROM golang:1.24

WORKDIR /app
COPY go.mod go.sum ./
COPY . .
RUN go mod download && go mod verify && go mod vendor
RUN GOOS=linux GOARCH=amd64 go build -o golang-demo && chmod +x golang-demo

CMD ["./golang-demo"]
ENTRYPOINT ["./golang-demo"]

