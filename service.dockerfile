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
RUN make clean && make && ls -lha 

# final stage
#FROM ineva/alpine:3.9
FROM ubuntu:18.04
WORKDIR /app
COPY config/im.cfg im.cfg
COPY config/ims.cfg ims.cfg
COPY config/imr.cfg imr.cfg 
COPY private.pem /app
COPY certificate.crt /app
COPY --from=builder /src/im/im /app/im
COPY --from=builder /src/imr/imr /app/imr
COPY --from=builder /src/ims/ims /app/ims
