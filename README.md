# c2-drop

Falco + Knative drop pod if a connection to a C2 server is detected.
Inspired by:
* https://github.com/n3wscott/falco-drop
* https://falco.org/blog/falcosidekick-response-engine-part-3-knative/


**BUILD IS FAILING** See below.


See this issue: https://github.com/n3wscott/falco-drop/issues/3

I copy/paste the issue here below.

***
Hello, 

I read your Falco blog post and I tried to reproduce and rebuild your container images.
https://falco.org/blog/falcosidekick-response-engine-part-3-knative/

## Steps to build n3wscott/falco-drop without github actions

I clone your repo:
```
git clone https://github.com/n3wscott/falco-drop.git
```

I move to the folder:
```
cd falco-drop
```

I do have Google ko installed:
```
$ ko version
v0.10.0
```

I do have GoLang installed:
```
$ go version
go version go1.17.7 linux/amd64
```

I customize Google ko to point to my own local `registryv2` instance (a local container registry):
```
export KO_DOCKER_REPO=mycustomreg.my.domain.net:5000
```

I manually run Google ko since I do not have Github action or CI/CD tools availables:
```
ko build --insecure-registry ./cmd/drop
```
And this is a success: an image is built and pushed to my registry.

I tested the image with Falco and a k8s cluster : it does the response engine thing.


## Building a small variation of n3wscott/falco-drop app

Now lets say I want to experiment on an other Falco rule. For example, I want to replace `"Terminal shell in container"` with `"Outbound Connection to C2 Servers"`.

Lets duplicate your Knative app:
```
mkdir cmd/c2-drop
cp cmd/drop/main.go cmd/c2-drop/main.go
```

In the file `cmd/c2-drop/main.go`, I replace one line in your code: I replace `"Terminal shell in container"` with `"Outbound Connection to C2 Servers"`. I have something like this:

```go
			if payload.Rule == "Outbound Connection to C2 Servers" {
				if err := kc.CoreV1().Pods(payload.Fields.Namespace).Delete(ctx, payload.Fields.Pod, metav1.DeleteOptions{}); err != nil {
```

Now lets build this new Knative service app with Google ko:
```
ko build --insecure-registry ./cmd/c2-drop/
```
And this is a success: an image is built and pushed to my registry.

I tested the image with Falco and a k8s cluster : it does the response engine thing for C2 server alerts.

## Handle Go modules and vendors myself

Now if I want to create my own Go module, I start by creating the following folder:
```
c2-drop/
├── cmd
    └── c2-drop
        └── main.go
```
Where `cmd/c2-drop/main.go` is a copy paste of the "`Outbound Connection to C2 Servers`" Knative app.

I do have Google ko installed:
```
$ ko version
v0.10.0
```

I do have GoLang installed:
```
$ go version
go version go1.17.7 linux/amd64
```

Then I init my Go module:
```
go mod init github.com/nicop311/c2-drop
```
```
go: creating new go.mod: module github.com/nicop311/c2-drop
go: to add module requirements and sums:
        go mod tidy
```

My `go.mod` looks like this:
```
module github.com/nicop311/c2-drop

go 1.17
```

Then I run `go mod tidy`, but it seems there are some packages not available with Go 1.17:
```
[...]
c2-drop/cmd/c2-drop imports
        knative.dev/pkg/client/injection/kube/client imports
        k8s.io/client-go/applyconfigurations/admissionregistration/v1 imports
        k8s.io/apimachinery/pkg/util/managedfields imports
        k8s.io/kube-openapi/pkg/util/proto tested by
        k8s.io/kube-openapi/pkg/util/proto.test imports
        github.com/onsi/gomega imports
        github.com/onsi/gomega/matchers imports
        github.com/onsi/gomega/matchers/support/goraph/bipartitegraph imports
        github.com/onsi/gomega/matchers/support/goraph/util loaded from github.com/onsi/gomega@v1.10.1,
        but go 1.16 would select v1.16.0

To upgrade to the versions selected by go 1.16, leaving some packages unresolved:
        go mod tidy -e -go=1.16 && go mod tidy -e -go=1.17
If reproducibility with go 1.16 is not needed:
        go mod tidy -compat=1.17
For other options, see:
        https://golang.org/doc/modules/pruning
```

I run this:
```
go mod tidy -e -go=1.16 && go mod tidy -e -go=1.17
```

I end up with that:

```
c2-drop/
├── cmd
│   └── c2-drop
│       └── main.go
├── go.mod
└── go.sum
```

Now I add the vendor folder:
```
go mod vendor
```

I customize Google ko to point to my own local `registryv2` instance (a local container registry):
```
export KO_DOCKER_REPO=mycustomreg.my.domain.net:5000
```

Now I try to build, but I have errors:
```
ko build --insecure-registry ./cmd/c2-drop
```
```
2022/03/01 17:14:10 No matching credentials were found, falling back on anonymous
2022/03/01 17:14:12 Using base gcr.io/distroless/static:nonroot@sha256:80c956fb0836a17a565c43a4026c9c80b2013c83bea09f74fa4da195a59b7a99 for c2-drop/cmd/c2-drop
2022/03/01 17:14:13 Building c2-drop/cmd/c2-drop for linux/amd64
2022/03/01 17:14:14 Unexpected error running "go build": exit status 2
# k8s.io/client-go/tools/cache
vendor/k8s.io/client-go/tools/cache/reflector.go:180:119: cannot use realClock (type *"k8s.io/apimachinery/pkg/util/clock".RealClock) as type "k8s.io/utils/clock".Clock in argument to wait.NewExponentialBackoffManager:
        *"k8s.io/apimachinery/pkg/util/clock".RealClock does not implement "k8s.io/utils/clock".Clock (wrong type for NewTimer method)
                have NewTimer(time.Duration) "k8s.io/apimachinery/pkg/util/clock".Timer
                want NewTimer(time.Duration) "k8s.io/utils/clock".Timer
vendor/k8s.io/client-go/tools/cache/reflector.go:181:119: cannot use realClock (type *"k8s.io/apimachinery/pkg/util/clock".RealClock) as type "k8s.io/utils/clock".Clock in argument to wait.NewExponentialBackoffManager:
        *"k8s.io/apimachinery/pkg/util/clock".RealClock does not implement "k8s.io/utils/clock".Clock (wrong type for NewTimer method)
                have NewTimer(time.Duration) "k8s.io/apimachinery/pkg/util/clock".Timer
                want NewTimer(time.Duration) "k8s.io/utils/clock".Timer
Error: failed to publish images: error building "ko://c2-drop/cmd/c2-drop": exit status 2
2022/03/01 17:14:14 error during command execution:failed to publish images: error building "ko://c2-drop/cmd/c2-drop": exit status 2
```

***

## Building with `go build` (no Google Ko)

After failing to build with Google Ko, I try to build with `go build`

```
go build -v -o c2-drop  cmd/c2-drop/main.go 
```

```
k8s.io/client-go/tools/cache
# k8s.io/client-go/tools/cache
vendor/k8s.io/client-go/tools/cache/reflector.go:180:119: cannot use realClock (type *"k8s.io/apimachinery/pkg/util/clock".RealClock) as type "k8s.io/utils/clock".Clock in argument to wait.NewExponentialBackoffManager:
        *"k8s.io/apimachinery/pkg/util/clock".RealClock does not implement "k8s.io/utils/clock".Clock (wrong type for NewTimer method)
                have NewTimer(time.Duration) "k8s.io/apimachinery/pkg/util/clock".Timer
                want NewTimer(time.Duration) "k8s.io/utils/clock".Timer
vendor/k8s.io/client-go/tools/cache/reflector.go:181:119: cannot use realClock (type *"k8s.io/apimachinery/pkg/util/clock".RealClock) as type "k8s.io/utils/clock".Clock in argument to wait.NewExponentialBackoffManager:
        *"k8s.io/apimachinery/pkg/util/clock".RealClock does not implement "k8s.io/utils/clock".Clock (wrong type for NewTimer method)
                have NewTimer(time.Duration) "k8s.io/apimachinery/pkg/util/clock".Timer
                want NewTimer(time.Duration) "k8s.io/utils/clock".Timer
```


## Knative Go libs seems to be broken

The error seems to be triggered by the lib `"knative.dev/pkg/injection"`.