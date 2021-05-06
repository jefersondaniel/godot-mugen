# Neo Mugen

Mugen clone using the Godot engine

## Requirements

* Godot 3.3
* SCons and godot build dependencies [Godot Docs](https://docs.godotengine.org/en/3.3/development/compiling/compiling_for_x11.html)

## Setup

1. Clone the repo with the submodules

```sh
git clone --recurse-submodules -j2 git@github.com:jefersondaniel/neo-mugen.git
```

2. Compile the godot-cpp library

```sh
cd source/native/godot-cpp
scons generate_bindings=yes -j4
```

3. Compile custom GDNative modules

```sh
cd source/native
scons platform=linux bits=64 -j4
```

Once the setup is done, only the last step needs to be executed to recompile the modules.

## Running

Execute Godot 3.2 on project folder:

```sh
godot
```
