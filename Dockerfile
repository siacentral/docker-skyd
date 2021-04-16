# build sia
FROM golang:1.15-alpine AS buildgo

ARG SKYD_VERSION=master
ARG RC=master

RUN echo "Install Build Tools" && apk update && apk upgrade && apk add --no-cache gcc musl-dev openssl git make

# prevents cache on git clone if the ref has changed
ADD https://gitlab.com/api/v4/projects/25028778/repository/commits/${SKYD_VERSION} version.json

WORKDIR /app

RUN echo "Clone Sia Repo" && git clone https://gitlab.com/SkynetLabs/skyd.git /app && git fetch && git checkout $SKYD_VERSION

RUN echo "Build skyd" && mkdir /app/releases && go build -a -tags 'netgo' -trimpath \
	-ldflags="-s -w -X 'gitlab.com/SkynetLabs/skyd/build.GitRevision=`git rev-parse --short HEAD`' -X 'gitlab.com/SkynetLabs/skyd/build.BuildTime=`git show -s --format=%ci HEAD`' -X 'gitlab.com/SkynetLabs/skyd/build.ReleaseTag=${RC}'" \
	-o /app/releases ./cmd/skyd ./cmd/skyc

# run sia
FROM alpine:latest

COPY --from=buildgo /app/releases /usr/local/bin

EXPOSE 9981 9982 9983 9984

VOLUME [ "/skyd-data" ]

ENTRYPOINT [ "skyd", "--disable-api-security", "-d", "/skyd-data", "--api-addr", ":9980" ]
