FROM ubuntu:18.04 as builder 
RUN apt update && apt install -y make cmake gcc g++ python3 wget git 
RUN mkdir /go  && mkdir /gopath
WORKDIR /go 
RUN wget https://golang.org/dl/go1.14.9.linux-amd64.tar.gz
RUN tar xzvf go1.14.9.linux-amd64.tar.gz  && mv go go-1.14.9 
ENV PATH="/go/go-1.14.9/bin:${PATH}"
ENV GOROOT="/go/go-1.14.9/"
ENV GOPATH="/gopath"
WORKDIR /src 
COPY . /src
RUN GOPROXY=https://goproxy.cn && go mod download && mkdir bin
RUN go build -ldflags "-X main.VERSION=2.0.0 -X 'main.BUILD_TIME=`date`' -X 'main.GO_VERSION=`go version`' -X 'main.GIT_COMMIT_ID=`git log --pretty=format:"%h" -1`' -X 'main.GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`'" -o bin/im ./im
RUN go build -ldflags "-X main.VERSION=2.0.0 -X 'main.BUILD_TIME=`date`' -X 'main.GO_VERSION=`go version`' -X 'main.GIT_COMMIT_ID=`git log --pretty=format:"%h" -1`' -X 'main.GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`'" -o bin/imr ./imr
RUN go build -ldflags "-X main.VERSION=2.0.0 -X 'main.BUILD_TIME=`date`' -X 'main.GO_VERSION=`go version`' -X 'main.GIT_COMMIT_ID=`git log --pretty=format:"%h" -1`' -X 'main.GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`'" -o bin/ims ./ims
RUN go build -ldflags "-X main.VERSION=2.0.0 -X 'main.BUILD_TIME=`date`' -X 'main.GO_VERSION=`go version`' -X 'main.GIT_COMMIT_ID=`git log --pretty=format:"%h" -1`' -X 'main.GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`'" -o bin/ims_truncate ./ims_truncate

# final stage
#FROM ineva/alpine:3.9
FROM ubuntu:18.04
WORKDIR /app
COPY config/im.cfg im.cfg
COPY config/ims.cfg ims.cfg
COPY config/imr.cfg imr.cfg 
COPY private.pem /app
COPY certificate.crt /app
COPY --from=builder /src/bin/im /app/im
COPY --from=builder /src/bin/imr /app/imr
COPY --from=builder /src/bin/ims /app/ims
