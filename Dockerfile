FROM alpine/git AS base

ARG TAG=latest
RUN git clone https://github.com/wietze/ArgFuscator.net.git && \
    cd ArgFuscator.net && \
    ([[ "$TAG" = "latest" ]] || git checkout ${TAG}) && \
    rm -rf .git

FROM --platform=$BUILDPLATFORM ruby AS build

WORKDIR /ArgFuscator.net
COPY --from=base /git/ArgFuscator.net .
RUN apt update && \
    apt install -y node-typescript python3-yaml && \
    tsc --project src/ --outfile gui/assets/js/main.js && \
    mv models gui/assets/models && \
    python3 .github/workflows/json-transform.py && \
    gem install jekyll jekyll-redirect-from && \
    jekyll build --source gui

FROM joseluisq/static-web-server

COPY --from=build /ArgFuscator.net/_site ./public
