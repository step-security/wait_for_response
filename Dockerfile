# Build the app
FROM golang:1.27@sha256:205c7636d74e0ffbe3d007162df7d74f859f5a8c8322dfb9f907977686c126cf as builder
WORKDIR /app
# Enable go modules even inside GOPATH
ENV GO111MODULE=on
# Mark neecosem modules as private
# RUN go env -w GOPRIVATE=github.com/newcosem/*

# Copy `go.mod` for definitions and `go.sum` to invalidate the next layer
# in case of a change in the dependencies
#COPY go.mod go.sum ./
# Download dependencies
#RUN go mod download

COPY ./ ./
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go test ./...
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -o wait_for_response /app/main/main.go

# Create a minimal docker container and copy the app into it
FROM alpine:3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=builder /app/wait_for_response .
RUN chmod +x /app/wait_for_response
ENTRYPOINT ["/app/wait_for_response"]
