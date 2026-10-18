#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
make
"${TCLSH:-tclsh8.6}" tests/binding_test.tcl
make package
TCLLIBPATH="$PWD/build/package/licensebox0.1.0" "${TCLSH:-tclsh8.6}" <<'TCL'
package require licensebox
if {![string match m1:* [licensebox::native_binding demo]]} {error "package consumer failed"}
TCL
