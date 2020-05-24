ARG goversion=1.14
ARG alpineversion=3.11
FROM golang:$goversion as builder


WORKDIR /app

COPY go.mod .
COPY go.sum .

RUN go mod download

ENV GO111MODULE=on
ENV CGO_ENABLED=0
ARG GOOS=linux

WORKDIR /app
COPY tests ./tests
COPY vendor ./vendor

RUN go test -c -o certifier ./tests

FROM alpine:$alpineversion

RUN apk --no-cache --update add ca-certificates

ARG USER=default
ENV HOME /home/$USER

# install sudo as root
RUN apk add --update sudo

# add new user
RUN adduser -D $USER
USER $USER
WORKDIR $HOME

COPY --from=builder /app/certifier /bin/certifier

ENTRYPOINT [ "/bin/certifier" ]
