#!/usr/bin/env bash

RUST_VERSIONS="1.45.2 1.46.0 1.47.0 1.48.0 1.49.0"

main() {
    local root="$PWD/root"

    for rust_version in $RUST_VERSIONS; do
        rustup install "$rust_version"
    done

    echo
    echo "----------------------------------------------------------------------------------------------------"

    for sheldon_path in sheldon/*; do
    # for sheldon_path in "sheldon/profile"; do
        for rust_version in $RUST_VERSIONS; do
            local sheldon_version=$(basename "$sheldon_path")
            local target_dir="target/rust-$rust_version/sheldon-$sheldon_version"
            local bin="$target_dir/release/sheldon"

            mkdir -p "$target_dir"

            echo
            echo "Rust version: $rust_version"
            echo "Sheldon version: $sheldon_version"
            echo "Target directory: $target_dir"
            echo

            CARGO_TARGET_DIR="$target_dir" \
                cargo "+$rust_version" build \
                --manifest-path "$sheldon_path/Cargo.toml" \
                --release \
                || exit 1

            SHELDON_ROOT=$root SHELDON_CONFIG_DIR=$root SHELDON_DATA_DIR=$root $bin source &>/dev/null \
                || exit 1

            echo

            hyperfine \
                --warmup 3 \
                --export-json "results/load_rust-${rust_version}_sheldon-${sheldon_version}.json" \
                "SHELDON_ROOT=$root SHELDON_CONFIG_DIR=$root SHELDON_DATA_DIR=$root $bin source" \
                || exit 1

            echo "----------------------------------------------------------------------------------------------------"
        done
    done
}

main "$@"
