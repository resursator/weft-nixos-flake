# Weft NixOS Flake

[Nix flake](https://nixos.wiki/wiki/Flakes) for packaging [Weft](https://github.com/Weft-Rust/Weft), a voxel sandbox engine, on NixOS and other Nix-enabled Linux systems.

The package builds Weft from source and provides a launcher configured with the required runtime libraries.

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

The resulting executable will be available at:

```text
./result/bin/weft
```

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
