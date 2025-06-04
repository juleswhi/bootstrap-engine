<div align="center">

# Bootstrap Engine

Game Engine For Bootstrap

</div>


## Building

### Linux

Ensure Zig 0.14 is installed

- Clone The Repository And Build

```sh
git clone https://github.com/juleswhi/bootstrap-engine

cd bootstrap-engine
zig build run
```

### Windows

Current executables are located in the releases tab.

If you want to build it yourself, clone and ensure the latest version of zig
is installed.

```
zig build -Dtarget=x86_64-windows -Doptimize=ReleaseFast
```
