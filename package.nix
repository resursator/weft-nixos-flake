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

    cargoHash = "sha256-eVt2lWmjn9kJPNtDYbhZb4fuhSzkEt4zlsCKEoBOH8E=";

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
      test -n "$(ls dist/Weft/run/mods)"
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

  data_home="''${XDG_DATA_HOME:-$HOME/.local/share}"
  weft_data="$data_home/weft-${version}"

  if [ ! -d "$weft_data/run/mods" ]; then
    mkdir -p "$data_home"
    cp -a "${weft}/share/weft" "$weft_data"
    chmod -R u+rwX "$weft_data"
  fi

  export LD_LIBRARY_PATH="${runtimeLibraryPath}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

  cd "$weft_data"
  exec "$weft_data/weft" "$@"
''
