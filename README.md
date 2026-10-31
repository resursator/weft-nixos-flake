# Weft NixOS Flake

[Nix flake](https://nixos.wiki/wiki/Flakes) for packaging [Weft](https://github.com/Weft-Rust/Weft), a voxel sandbox engine, on NixOS and other Nix-enabled Linux systems.

The package builds Weft from source and provides a runtime wrapper that handles writable user data directories, making it possible to run the game without modifying the Nix store.

## Requirements

- Nix with flakes enabled.
- `x86_64-linux` system architecture.

## Installation

### Run without installing

Launch Weft directly using `nix run`:

```bash
nix run github:resursator/weft-nixos-flake
```

Alternatively, specify the package explicitly:

```bash
nix run github:resursator/weft-nixos-flake#weft
```

### Install to your Nix profile

```bash
nix profile install github:resursator/weft-nixos-flake
```

After installation, launch the game with:

```bash
weft
```

### Build locally

Build the package without installing it:

```bash
nix build github:resursator/weft-nixos-flake
```

The resulting executable wrapper will be available at:

```text
./result/bin/weft
```

## User Data

Weft expects its mods and other runtime files to be located alongside the executable. However, the Nix store is immutable, so the game cannot write runtime data directly into its installation directory.

This flake solves that problem by providing a wrapper that creates a writable copy of the game distribution in the user's data directory.

### Data location

The game data is stored at:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/weft-26.10.3/
```

For example, with the default configuration:

```text
~/.local/share/weft-26.10.3/
├── weft
└── run/
    └── mods/
```

### How it works

1. On the first launch, the wrapper copies the packaged game distribution from the Nix store into the user data directory.
2. User write permissions are enabled recursively for the copied files.
3. The game is launched from the writable directory.
4. Subsequent launches reuse the existing directory, preserving user data and modifications between runs.

The data directory is version-specific. Installing a new version creates a separate directory, leaving the previous version's data untouched.

### Custom data directory

You can override the default location using `XDG_DATA_HOME`:

```bash
XDG_DATA_HOME=/mnt/games/data weft
```

This will use:

```text
/mnt/games/data/weft-26.10.3/
```

### Removing user data

Uninstalling the Nix package does not remove user data.

To remove the game data manually:

```bash
rm -rf ~/.local/share/weft-26.10.3
```

If you use a custom `XDG_DATA_HOME`, remove the corresponding directory there instead.

## Updating

The flake currently pins a specific upstream Weft release.

To use a newer version, update the following values in `flake.nix`:

- `version` — upstream release version.
- `rev` — Git tag corresponding to the release.
- `hash` — source archive hash.

Update `cargoHash` in `package.nix` if the Rust dependencies have changed.

After updating, rebuild the package:

```bash
nix build
```

## Technical Details

- **Source:** [Weft-Rust/Weft](https://github.com/Weft-Rust/Weft)
- **Packaging:** `rustPlatform.buildRustPackage`
- **Nixpkgs:** `nixos-unstable`
- **Architecture:** `x86_64-linux`
- **Runtime libraries:** ALSA, OpenGL, Vulkan, Wayland, X11, XKBCommon and udev.

## License

This repository contains Nix packaging definitions for Weft.

Please refer to the [upstream Weft repository](https://github.com/Weft-Rust/Weft) for the original project's license and source code.
