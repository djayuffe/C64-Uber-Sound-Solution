#!/bin/sh
set -eu
python3 tools/verify_upload_asset.py
python3 tools/static_acme_sanity.py
python3 tools/project_hygiene.py
python3 tools/branch_byte_audit.py
python3 tools/branch_range_sanity.py
python3 tools/acme_syntax_sanity.py
python3 tools/full_source_audit.py
python3 tools/asset_block_audit.py
mkdir -p build
acme -f cbm -o build/uber_sound_solution.prg src/uber_intro.asm
echo "OK: build/uber_sound_solution.prg"
