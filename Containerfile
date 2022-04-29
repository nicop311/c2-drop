# This is a Containerfile/Dockerfile
ARG BUILDER_IMAGE=golang:1.17-buster
ARG BASE_IMAGE=alpine:3.15

FROM ${BUILDER_IMAGE} AS build-stage

ENV CGO_ENABLED=0

WORKDIR /src
COPY . .

RUN go mod download
RUN go build