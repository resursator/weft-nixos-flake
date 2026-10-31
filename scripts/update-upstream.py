#!/usr/bin/env python3
"""Update Weft version and Nix hashes."""

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
FLAKE = ROOT / "flake.nix"
PACKAGE = ROOT / "package.nix"

FAKE_HASH = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="

VERSION_RE = re.compile(
    r"\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?"
)

VERSION_PATTERN = re.compile(
    r'^([ \t]*version = ")[^"]+";[ \t]*$',
    re.MULTILINE,
)

SOURCE_HASH_PATTERN = re.compile(
    r'^([ \t]*hash = ")[^"]*(";\s*)$',
    re.MULTILINE,
)

CARGO_HASH_PATTERN = re.compile(
    r'^([ \t]*cargoHash = ")[^"]*(";\s*)$',
    re.MULTILINE,
)


def replace_one(content, pattern, replacement, description):
    updated, count = pattern.subn(
        replacement,
        content,
        count=1,
    )

    if count != 1:
        raise RuntimeError(
            f"Expected exactly one {description}, found {count}"
        )

    return updated


def write_hash(path, pattern, value, description):
    content = path.read_text()

    def replacement(match):
        return f'{match.group(1)}{value}{match.group(2)}'

    content, count = pattern.subn(replacement, content, count=1)

    if count != 1:
        raise RuntimeError(
            f"Expected exactly one {description}, found {count}"
        )

    path.write_text(content)


def run_build(attempt):
    print(f"\n=== Build {attempt}/3 ===", flush=True)

    process = subprocess.run(
        [
            "nix",
            "build",
            ".#packages.x86_64-linux.default",
            "--no-link",
            "--print-build-logs",
        ],
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        check=False,
    )

    log = process.stdout or ""

    if process.returncode == 0:
        print("Build successful.", flush=True)
        return True, None, None

    drv_match = re.search(
        r"hash mismatch in fixed-output derivation '([^']+)'",
        log,
    )
    hash_match = re.search(
        r"got:\s*(sha256-[A-Za-z0-9+/=]+)",
        log,
    )

    if drv_match and hash_match:
        drv_path = drv_match.group(1)

        if drv_path.endswith("-source.drv"):
            hash_type = "source"
        elif drv_path.endswith("-vendor-staging.drv"):
            hash_type = "cargo"
        else:
            print(log, end="", flush=True)
            raise RuntimeError(
                f"Unknown hash mismatch derivation: {drv_path}"
            )

        return False, hash_type, hash_match.group(1)

    print(log, end="", flush=True)
    raise RuntimeError(
        f"Build failed with exit code {process.returncode}; "
        "could not identify a hash mismatch."
    )


def main():
    if len(sys.argv) != 2:
        raise SystemExit(
            f"Usage: {sys.argv[0]} VERSION"
        )

    version = sys.argv[1].removeprefix("v")

    if not VERSION_RE.fullmatch(version):
        raise SystemExit(f"Invalid version: {version}")

    print(f"Updating Weft to {version}")

    flake = FLAKE.read_text()
    package = PACKAGE.read_text()

    flake = replace_one(
        flake,
        VERSION_PATTERN,
        rf'\g<1>{version}";',
        "version field",
    )

    flake = replace_one(
        flake,
        SOURCE_HASH_PATTERN,
        lambda match: f"{match.group(1)}{FAKE_HASH}{match.group(2)}",
        "source hash",
    )

    package = replace_one(
        package,
        CARGO_HASH_PATTERN,
        lambda match: f"{match.group(1)}{FAKE_HASH}{match.group(2)}",
        "cargoHash",
    )

    FLAKE.write_text(flake)
    PACKAGE.write_text(package)

    for attempt in range(1, 4):
        success, hash_type, new_hash = run_build(attempt)

        if success:
            print(
                f"\nSuccessfully updated Weft to {version}"
            )
            return

        print(f"\nUpdating {hash_type} hash: {new_hash}")

        if hash_type == "source":
            write_hash(
                FLAKE,
                SOURCE_HASH_PATTERN,
                new_hash,
                "source hash",
            )
        elif hash_type == "cargo":
            write_hash(
                PACKAGE,
                CARGO_HASH_PATTERN,
                new_hash,
                "cargoHash",
            )

        if attempt == 3:
            raise RuntimeError(
                "Package did not build after three attempts"
            )

    raise RuntimeError("Unexpected updater state")


if __name__ == "__main__":
    main()
