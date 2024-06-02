# HATEOAS

Trying out HTMX.

Following [FULL Introduction To HTMX Using Golang by FrontEnd Masters](https://www.youtube.com/watch?v=x7v6SNIgJpE)

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
