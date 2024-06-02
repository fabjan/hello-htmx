# HATEOAS

Trying out HTMX

## Requirements

* [Poly/ML] or [MLton]

[Poly/ML]: https://www.polyml.org
[MLton]: http://mlton.org

## Building

A local build:
```
./build.sh
```

Build a container image:
```
podman build . -t hateoas
```

## Running

A local build:
```
_build/hateoas
```

A container:
```
podman run --rm -it -p3000:3000 hateoas
```

To use the app, visit http://localhost:3000
