# We need some build tools to compile the SML code
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y mlton

COPY src src
COPY *.mlb polybuild.sml build.sh .

RUN SML_COMPILER=mlton-static ./build.sh

# but we don't need them to run the finished program
FROM alpine:3.18

WORKDIR /app

COPY --from=0 _build/hateoas .

CMD /app/hateoas
