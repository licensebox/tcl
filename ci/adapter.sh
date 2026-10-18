#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
exec "${TCLSH:-tclsh8.6}" tests/adapter.tcl
