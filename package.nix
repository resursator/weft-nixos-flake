{
  lib,
  stdenv,
  rustPlatform,
  pkg-config,
  alsa-lib,
  libGL,
  vulkan-loader,
  libxkbcommon,
  wayland,
  libX11,
  libXcursor,
  libXi,
  libXrandr,
  libXinerama,
  libXext,
  libXrender,
  libxcb,
  udev,
  writeShellScriptBin,
  src,
  version,
}:

let
  runtimeLibs = [
    alsa-lib
    libGL
    vulkan-loader
    libxkbcommon
    wayland
    libX11
    libXcursor
    libXi
    libXrandr
    libXinerama
    libXext
    libXrender
    libxcb
    udev
    stdenv.cc.cc.lib
  ];

  runtimeLibraryPath = lib.makeLibraryPath runtimeLibs;

  weft = rustPlatform.buildRustPackage {
    pname = "weft";
    inherit version src;

    cargoHash = "sha256-+5rYU1cMqxVotP2fMGVY99USNCgV80LTIK3Z/Hmwiq4=";

    cargoBuildFlags = [
      "--workspace"
    ];

    nativeBuildInputs = [
      pkg-config
    ];

    buildInputs = [
      alsa-lib
    ];

    postBuild = ''
      mkdir -p dist

      target/${stdenv.hostPlatform.rust.rustcTarget}/release/weft \
        --dist dist/Weft

      test -f dist/Weft/weft
      test -d dist/Weft/run/mods
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share
      cp -a dist/Weft $out/share/weft

      runHook postInstall
    '';

    doCheck = false;
  };
in
writeShellScriptBin "weft" ''
  set -eu

  export LD_LIBRARY_PATH="${runtimeLibraryPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

  exec "${weft}/share/weft/weft" "$@"
''
