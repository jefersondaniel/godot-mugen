# Godot Mugen

[M.U.G.E.N™](https://www.elecbyte.com/mugendocs-11b1/mugen.html) clone using the Godot engine. This project aims to be compatible with HTML5 exports, utilizing GDScript for the majority of the game logic and Rust for native modules.

![Example Match](https://public-data.jefersondaniel.com/godot-mugen-match-20240110.gif)

[Try It](https://jefersondaniel.com/godot-mugen/mugen.html)

# Project Status

This project is an implementation of a basic Mugen clone using the Godot engine. It is still in early development and is not yet fully compatible. I am not actively working on this project, but I am open to contributions. Additionally, I have created a Proof of Concept (POC) using a different architecture based on ECS and Rust, which can be found [here](https://github.com/jefersondaniel/gdnative-rust-poc).

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
