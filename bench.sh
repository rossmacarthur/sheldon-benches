#!/usr/bin/env bash

main() {
    local root="$PWD/root"

    rustup install 1.45.0
    rustup install 1.47.0

    echo
    echo "----------------------------------------------------------------------------------------------------"

    for sheldon_path in sheldon/*; do
        for rust_version in "1.45.0" "1.47.0"; do
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
