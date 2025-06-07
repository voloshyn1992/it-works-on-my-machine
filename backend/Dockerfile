FROM golang:1.24 as builder

WORKDIR /app
COPY go.mod go.sum ./
COPY . .
RUN go mod download && go mod verify && go mod vendor
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o golang-demo && chmod +x golang-demo

FROM gcr.io/distroless/static-debian11

WORKDIR /app
USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /app .

ENTRYPOINT ["./golang-demo"]

