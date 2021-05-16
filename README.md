# Neo Mugen

Mugen clone using the Godot engine

## Requirements

* Godot 3.3
* Clang
* Rust

## Setup

1. Clone the repo with the submodules

```sh
git clone git@github.com:jefersondaniel/neo-mugen.git
```

2. Download game data

```sh
wget https://f000.backblazeb2.com/file/jefersondaniel-public/mugen/neo-mugen-default-data.zip
unzip neo-mugen-default-data.zip && rm neo-mugen-default-data.zip
```

3. Compile custom GDNative modules

```sh
cd source/native
cargo build
```

## Running

Execute Godot on project folder:

```sh
godot
```
