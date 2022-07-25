# This is a Containerfile/Dockerfile
#==============================================================================#
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
# Building the Go Knative application
#==============================================================================#
FROM ${BUILDER_REGISTRY}/${BUILDER_IMAGE}:${BUILDER_IMAGE_TAG} AS gobuilder

ENV CGO_ENABLED=0

RUN mkdir -p /opt/knative/c2-drop/bin

WORKDIR /opt/knative/c2-drop
COPY . .

RUN go mod vendor
RUN go build -v -o /opt/knative/c2-drop/bin/c2-drop  cmd/c2-drop/main.go


#==============================================================================#
# Final image
#==============================================================================#
FROM ${FINAL_REGISTRY}/${FINAL_IMAGE}:${FINAL_IMAGE_TAG} AS Final

RUN mkdir -p /opt/knative/c2-drop/bin
WORKDIR /opt/knative/c2-drop/bin
COPY --from=gobuilder /opt/knative/c2-drop/bin/c2-drop .

ENTRYPOINT ["/opt/knative/c2-drop/bin/c2-drop"]