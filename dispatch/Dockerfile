# Build stage
FROM golang:1.23-alpine AS builder

WORKDIR /go/src/app

COPY *.go ./

RUN go mod init dispatch && \
    go get && \
    CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o dispatch .

# Final stage
FROM scratch

COPY --from=builder /go/src/app/dispatch /dispatch

ENTRYPOINT ["/dispatch"]

