# dmenu - dynamic menu
# Justfile version of Makefile

# Config
set shell := ["sh", "-cu"]

# These could be loaded from config.mk via `include`, but for now we inline:
CFLAGS := "-std=c99 -pedantic -Wall -Os"
LDFLAGS := "-lX11 -lXft -lXinerama"
PREFIX := "/usr/local"
MANPREFIX := "$(PREFIX)/share/man"
VERSION := "5.3"  # Change this if needed

SRC := ["drw.c", "dmenu.c", "stest.c", "util.c"]
OBJ := SRC.map(f => f.replace(".c", ".o"))

# Rule: Build everything
default: dmenu stest

# Rule: Compile .c -> .o
# Automatically triggered
@rule compile:
    for file in {{SRC}}:
        object = file.replace(".c", ".o")
        run(f"cc -c {CFLAGS} {file} -o {object}")

# Rule: dmenu binary
dmenu: compile
    cc -o dmenu dmenu.o drw.o util.o {{LDFLAGS}}

# Rule: stest binary
stest: compile
    cc -o stest stest.o {{LDFLAGS}}

# Rule: config.h
config.h:
    cp config.def.h config.h

# Clean build
clean:
    rm -f dmenu stest *.o dmenu-{{VERSION}}.tar.gz

# Create tarball
dist: clean
    mkdir -p dmenu-{{VERSION}}
    cp LICENSE Makefile README arg.h config.def.h config.mk dmenu.1 \
       drw.h util.h dmenu_path dmenu_run stest.1 {{SRC.join(" ")}} \
       dmenu-{{VERSION}}
    tar -cf dmenu-{{VERSION}}.tar dmenu-{{VERSION}}
    gzip dmenu-{{VERSION}}.tar
    rm -rf dmenu-{{VERSION}}

# Install binaries and manpages
install: dmenu stest
    mkdir -p {{DESTDIR}}{{PREFIX}}/bin
    cp -f dmenu dmenu_path dmenu_run stest {{DESTDIR}}{{PREFIX}}/bin
    chmod 755 {{DESTDIR}}{{PREFIX}}/bin/dmenu*
    mkdir -p {{DESTDIR}}{{MANPREFIX}}/man1
    sed "s/VERSION/{{VERSION}}/g" < dmenu.1 > {{DESTDIR}}{{MANPREFIX}}/man1/dmenu.1
    sed "s/VERSION/{{VERSION}}/g" < stest.1 > {{DESTDIR}}{{MANPREFIX}}/man1/stest.1
    chmod 644 {{DESTDIR}}{{MANPREFIX}}/man1/*.1

# Uninstall everything
uninstall:
    rm -f {{DESTDIR}}{{PREFIX}}/bin/dmenu*
    rm -f {{DESTDIR}}{{MANPREFIX}}/man1/dmenu.1
    rm -f {{DESTDIR}}{{MANPREFIX}}/man1/stest.1