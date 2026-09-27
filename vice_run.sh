#!/bin/sh
# Copyright (C) 2026 Ulf Bertilsson
# SPDX-License-Identifier: GPL-3.0-only
set -eu
PRG=${1:-build/uber_sound_solution.prg}
if command -v x64sc >/dev/null 2>&1; then
    exec x64sc -autostartprgmode 1 -autostart "$PRG"
elif command -v x64 >/dev/null 2>&1; then
    exec x64 -autostartprgmode 1 -autostart "$PRG"
else
    echo "VICE x64sc/x64 not found." >&2
    exit 1
fi
