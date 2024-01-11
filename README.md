# Godot Mugen

Mugen clone using the Godot engine

## Requirements

* Godot 3.5
* Clang
* Rust

## Setup

1. Clone the repository

```sh
git clone git@github.com:jefersondaniel/godot-mugen.git
```

2. Download game data

```sh
wget https://github.com/jefersondaniel/godot-mugen-data/archive/refs/tags/1.0.0.zip -O mugen-data.zip
unzip mugen-data.zip && rm mugen-data.zip
```

3. Compile custom GDNative modules

```sh
cd source/native
cargo build --target x86_64-unknown-linux-gnu --release
```

## Running

Execute Godot on project folder:

```sh
godot
```

## References

I would like to acknowledge the following open-source projects for their contributions and inspiration in the development of this project:

[xnaMugen](https://github.com/scemino/xnamugen): Fork of xnaMugen (MUGEN clone) adapted to Monogame. This project code was used as reference for this implementation.

[Ikemen-Go](https://github.com/ikemen-engine/Ikemen-GO) An open-source fighting game engine that supports MUGEN resources.
