## Godot MUGEN Architecture

This document provides an up-to-date overview of the Godot 4.4 + Rust-based MUGEN project, describing the main modules, data flow, and best practices for extending the codebase. Use this as a runbook and onboarding reference for new contributors.

---

### 1. Architecture Overview

**Separation of Concerns**

- **Rust (Native, crates/game & crates/mugen_data):**
  - Game simulation and state machine (`GameManager`, `GameState`)
  - Asset parsing and configuration loading (SFF, ACT, DEF → strongly typed structs)
  - Core logic for rollback, error handling, and state transitions
  - Data adapters (e.g., `SpriteAdapter`, `BackgroundAdapter`, `BackgroundGroupAdapter`)

- **Godot/GDScript (Frontend, gdscript/):**
  - Scene composition and UI nodes (e.g., `title_screen.gd`, `BackgroundNode`)
  - Rendering and input handling
  - Polling native state and reacting to state changes
  - Minimal glue code; heavy logic stays in Rust

**Initialization and Core Flow**

1. **Startup:**
   - The Rust `GameManager` singleton is registered as a Godot singleton via GDExtension.
   - Godot's `main.gd` sets up the configuration directory and connects to state change signals.
2. **Configuration Loading:**
   - `GameManager` starts in `PreStart` state.
   - Transitions to `LoadingConfiguration`, where assets and configuration files are loaded via Rust (`CoreAssets`, `TitleScreenData`).
   - On successful load, transitions to `TitleScreen`.
3. **Scene Flow:**
   - GDScript listens for state changes and swaps scenes accordingly (e.g., showing `title_screen.gd` when state is `TitleScreen`).
   - UI nodes (e.g., `BackgroundNode`) are constructed from Rust adapters and populated with data.
4. **Gameplay:**
   - Future states (e.g., Select, Fight) will follow the same pattern: Rust manages state, Godot renders and handles input.

**Error Handling:**
- Errors in asset loading or state transitions are surfaced via `GameManager.error_message` and handled gracefully in GDScript.
- Fatal errors trigger a transition to a dedicated error state.

---

### 2. Main Modules and Data Structures

| Name                        | Layer    | Purpose                                                                 |
| --------------------------- | -------- | ----------------------------------------------------------------------- |
| `GameManager`               | Rust     | Singleton, global state, asset loading, state transitions               |
| `GameState`                 | Rust     | Enum for core states (PreStart, LoadingConfiguration, TitleScreen, etc.)|
| `CoreAssets`                | Rust     | Loads and holds references to all game assets                           |
| `TitleScreenData`           | Rust     | Data for title screen UI, backgrounds                                   |
| `BackgroundAdapter`         | Rust     | Adapter for background data, exposed to Godot                           |
| `BackgroundGroupAdapter`    | Rust     | Adapter for a group of backgrounds                                      |
| `BackgroundNode`            | Godot    | Node2D for rendering backgrounds (instantiated from adapters)           |
| `main.gd`                   | Godot    | Entry point, state polling, scene switching                             |
| `title_screen.gd`           | Godot    | Title screen UI logic, background setup                                 |

---

### 3. Implementation Guidelines

#### When adding a new feature or screen:

1. **Model data in Rust (`crates/mugen_data`)**
   - Define or extend typed structs/enums as needed.
2. **Expose Adapters in Rust (`crates/game/src/adapters`)**
   - Create a `*Adapter` to wrap Rust structs for Godot.
3. **Create Scene Nodes in Godot (`gdscript/`)**
   - For rendering or input, implement a `*Node` (`Node2D` or `Control`) referencing the Rust adapter.
4. **State Management**
   - Add new states to `GameState` and handle transitions in `GameManager`.
   - Use signals and error reporting for robust state changes.

---

### 4. Naming Conventions & Best Practices

- **Rust pure types:** No suffix (e.g., `BackgroundInfo`, `SpriteHandle`, `SystemDef`).
- **Godot-exposed adapters:** `*Adapter` (e.g., `BackgroundAdapter`, `SpriteAdapter`).
- **Godot scene nodes:** Descriptive names ending in `Node` or `Screen` (e.g., `BackgroundNode`, `TitleScreen`).
- **Singletons:** Register via GDExtension and always unregister on deinit to avoid leaks.
- **Error Handling:** Always surface errors to `GameManager.error_message` for GDScript to handle.

---

This overview should serve as a reference for implementing new screens, assets, or logic. Consistency in naming and clear separation between Rust and GDScript will keep the codebase maintainable and performant.

3. **Global Services**

   * GameManager is a singleton that provides access to the game state and other global services

4. **Naming Conventions**

   * Rust-side pure types: no suffix (`BackgroundInfo`, `SpriteHandle`, `SystemDef`). Defined in the folder `crates/mugen_data`
   * Godot-exposed adapters: `*Adapter` (e.g., `BackgroundAdapter`, `SpriteAdapter`). Defined in the folder `crates/game/src/adapters`.
   * Godot scene nodes: descriptive names ending in `Node` or `Screen` (e.g., `BackgroundNode`, `TitleScreen`)

This overview should serve as a reference when you implement new screens, assets, or logic. Consistency in naming and clear separation between Rust and GDScript will keep the codebase maintainable and performant.
