# c2-drop

Falco + Knative drop pod if a connection to a C2 server is detected.

Inspired by:
* https://github.com/n3wscott/falco-drop
* https://falco.org/blog/falcosidekick-response-engine-part-3-knative/

## Build Container Image

Several methods can be used to build the container image

### `podman build`

```
$ podman build -f Containerfile -t localhost/c2-drop:latest
```

### Google ko `ko build`

```
export KO_DOCKER_REPO=mycustomreg.my.domain.net:5000
```

```
ko build --insecure-registry ./cmd/c2-drop/
```

### [TODO] Build using `make` or Go `mage`

> Note: As of now, a `Makefile` exists but it only builds the Go code. It is
> not used to build the container image.

## Usage

TODO

## Troubleshouting

### Knative and k8s API version

See these issues:

* https://github.com/knative/pkg/issues/2452
* https://github.com/n3wscott/falco-drop/issues/3

Make sure [the k8s API version](https://github.com/knative/pkg/blob/e60d250dc6378c387c8c9d149774ee21e9a827ab/go.mod#L44-L48)
in your `go.mod` file matches the version supported by Knative.