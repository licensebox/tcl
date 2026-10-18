CC ?= cc
TCL_CFLAGS ?= $(shell pkg-config --cflags tcl8.6)
TCL_LIBS ?= $(shell pkg-config --libs tcl8.6)
all: liblicensebox_tcl.so
liblicensebox_tcl.so: src/licensebox.c
	$(CC) -shared -fPIC -Wall -Wextra $(TCL_CFLAGS) $< -o $@ -L$(LICENSEBOX_LIB_DIR) -llicensebox $(TCL_LIBS)
package: all
	mkdir -p build/package/licensebox0.1.0
	cp liblicensebox_tcl.so licensebox.tcl pkgIndex.tcl LICENSE README.md build/package/licensebox0.1.0/
	tar -czf build/licensebox-tcl-0.1.0.tar.gz -C build/package licensebox0.1.0
clean:
	rm -f liblicensebox_tcl.so
.PHONY: all package clean
