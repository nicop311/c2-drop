# This is a Containerfile/Dockerfile
#==============================================================================#
# Build me localy:
# $ podman build -f Containerfile -t localhost/c2-drop:latest
#==============================================================================#

# Go version
ARG GOLANG_VERSION=1.18

# Registry and images
ARG BUILDER_REGISTRY=docker.io/library
ARG BUILDER_IMAGE=golang
ARG BUILDER_IMAGE_TAG=${GOLANG_VERSION}-alpine

ARG FINAL_REGISTRY=docker.io/library
ARG FINAL_IMAGE=alpine
ARG FINAL_IMAGE_TAG=3.15

#==============================================================================#
# Setup the Go builder image
#==============================================================================#
FROM ${BUILDER_REGISTRY}/${BUILDER_IMAGE}:${BUILDER_IMAGE_TAG} AS gosetup

ENV CGO_ENABLED=0

WORKDIR /opt/knative/c2-drop
COPY cmd cmd
COPY go.mod .
COPY go.sum .

RUN go mod vendor

#==============================================================================#
# Building the Go Knative application
#==============================================================================#
FROM gosetup AS gobuilder

RUN mkdir -p /opt/knative/c2-drop/bin
WORKDIR /opt/knative/c2-drop

RUN go build -v -o /opt/knative/c2-drop/bin/c2-drop  cmd/c2-drop/main.go

#==============================================================================#
# Final image
#==============================================================================#
FROM ${FINAL_REGISTRY}/${FINAL_IMAGE}:${FINAL_IMAGE_TAG} AS Final

RUN mkdir -p /opt/knative/c2-drop/bin
WORKDIR /opt/knative/c2-drop/bin
COPY --from=gobuilder /opt/knative/c2-drop/bin/c2-drop .

ENTRYPOINT ["/opt/knative/c2-drop/bin/c2-drop"]