# Copyright (C) 2026 Ulf Bertilsson
# SPDX-License-Identifier: GPL-3.0-only

.PHONY: all verify build clean

ACME ?= acme
OUTPUT := build/uber_sound_solution.prg
SOURCE := src/uber_intro.asm

all: verify build

verify:
	python3 tools/project_hygiene.py
	python3 tools/branch_range_sanity.py
	python3 tools/acme_syntax_sanity.py
	python3 tools/asset_block_audit.py

build: $(OUTPUT)

$(OUTPUT): $(SOURCE) assets/uber_bitmap.bin assets/uber_screen.bin assets/uber_color.bin assets/uber_custom_font.bin
	mkdir -p build
	$(ACME) --strict-segments -f cbm -o $@ $(SOURCE)
	@echo "OK: $@"

clean:
	rm -rf build
