## Godot MUGEN Hybrid Architecture

This document outlines the high-level architecture for our Godot 4.4 + Rust-based MUGEN project, describes the core data structures and Godot nodes, and provides guidelines for selecting implementation approaches when adding new features.

---

### 1. Overall Architecture

* **Separation of Concerns**

  * **Rust (Native)**

    * Game simulation & state (rollback-safe)
    * MUGEN asset parsing (SFF, ACT, DEF files)
    * Configuration loading & typed structs (SystemDef, SelectDef, BackgroundInfo, etc.)
    * Core state-machine (GameManager and GameState)
    * Data adapters (SpriteAdapter, BackgroundAdapter)

  * **GDScript (Godot Frontend)**

    * Scene composition & UI nodes
    * Rendering
    * Polling native state & reacting (TitleMenuState, SelectState)
    * Minimal glue code—no heavy logic in GDScript

* **Core Flow**

  1. **Boot**: `GameManager` singleton starts in `PreStart`
  2. **Load Config**: Rust’s `MugenConfigLoader` loads DEF files → typed `MugenConfig`
  3. **State Transition**: `GameManager.update()` → `TitleScreen`
  4. **Title**: `title_screen.gd` uses `BackgroundNode` + `TitleScreenData` via adapters
  5. **Select**: on menu confirm, transition to `SelectScreen` with `SelectState`
  6. **Fight**: enters gameplay state (native) with full rollback support

---

### 2. Core Data Structures

| Name                        | Language | Purpose                                                                 |
| --------------------------- | -------- | ----------------------------------------------------------------------- |
| `MugenConfigLoader`         | Rust     | Load & parse DEF files into `MugenConfig`                               |
| `SystemDef` / `SelectDef`   | Rust     | Typed representation of system & select settings                        |
| `Background`                | Rust     | Holds one `[TitleBG #]` section (spriteno, tile, velocity, mask, start) |
| `SpriteHandle`              | Rust     | Identifies (SFF ID, group, index) for any sprite                        |
| `TitleScreenData`           | Rust     | Config for menu UI (position, spacing, fonts, actions)                  |
| `TitleScreenState`          | Rust     | Menu selection logic & input handling                                   |
| `GameState` / `GameManager` | Rust     | Global state-machine driving scenes & error handling                    |

---

### 3. Implementation Guidelines

When starting a new feature or screen, follow these steps:

1. **Check the relevant rust data model in `crates/mugen_data`**

2. **Expose an Adapter, Node or Both**

   * If you only need to data structures → create a `*Adapter` that wraps the Rust struct
   * If you need rendering or input logic → create a `*Node` (`Node2D` or `Control`) with a reference to the `something: Gd<SomethingAdapter>` property

3. **Global Services**

   * GameManager is a singleton that provides access to the game state and other global services

4. **Naming Conventions**

   * Rust-side pure types: no suffix (`BackgroundInfo`, `SpriteHandle`, `SystemDef`). Defined in the folder `crates/mugen_data`
   * Godot-exposed adapters: `*Adapter` (e.g., `BackgroundAdapter`, `SpriteAdapter`). Defined in the folder `crates/game/src/adapters`.
   * Godot scene nodes: descriptive names ending in `Node` or `Screen` (e.g., `BackgroundNode`, `TitleScreen`)

This overview should serve as a reference when you implement new screens, assets, or logic. Consistency in naming and clear separation between Rust and GDScript will keep the codebase maintainable and performant.
