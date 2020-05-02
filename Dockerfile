FROM alpine:latest
LABEL maintainer="Lucas David <https://hub.docker.com/u/ludavid>"

ARG build_date
LABEL org.label-schema.build-date=$build_date
LABEL org.label-schema.name="ludavid/buildpack"
LABEL org.label-schema.description="C++ buildpack mainly setup on Clang, CMake and Conan." 

# Update and upgrade, then install clang, python and conan first
RUN apk update --force --no-cache && apk upgrade --force --no-cache \
  && apk add --force --no-cache clang python3 \
  && pip3 install --no-cache-dir --upgrade pip conan
 
# Set up buildpack user, then setup conan default profile and add bincrafters remote repositories
RUN adduser --disabled-password buildpack && adduser buildpack wheel \
    && adduser buildpack sys
USER buildpack
RUN conan profile new default --detect --force \
    && conan remote add bincrafters https://api.bintray.com/conan/bincrafters/public-conan

# Resume build tools installation and clean cache
USER root
RUN apk add --force --no-cache autoconf automake build-base cmake git make && rm -rf /var/cache/apk/*

# Set CC and C++ to Clang compiler
RUN ln -sf /usr/bin/clang /usr/bin/cc && ln -sf /usr/bin/clang++ /usr/bin/c++

USER buildpack
WORKDIR /home/buildpack
