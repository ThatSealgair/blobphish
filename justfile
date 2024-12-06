# Load .env file if it exists
set dotenv-load

# Default recipe to show help
default:
    @just --list

# Build variables
binary_name := "toolname"
version := `git describe --tags --always --dirty`
commit := `git rev-parse HEAD`
build_date := `date -u +"%Y-%m-%dT%H:%M:%SZ"`

# Common ldflags
version_flags := "-X main.version=" + version + " -X main.commit=" + commit + " -X main.date=" + build_date

# Environment Setup Recipes
setup-reflex:
    #!/usr/bin/env bash
    echo '-r '\''\.go$'\'' -s go run .' > .reflex.conf
    echo '-r '\''\.go$'\'' -s go run -gcflags="all=-N -l" .' > .reflex.debug.conf

setup-gdb:
    #!/usr/bin/env bash
    wget -P ~ https://git.io/.gdbinit
    git clone https://github.com/cyrus-and/gdb-dashboard ~/.gdb-dashboard
    echo "source ~/.gdb-dashboard/.gdbinit" >> ~/.gdbinit
    echo 'define goruntime
      set $mp = runtime.m0
      printf "allm    = %p\n", runtime.allm
      printf "allp    = %p\n", runtime.allp
      printf "gomaxprocs = %d\n", runtime.gomaxprocs
    end' >> ~/.gdbinit

setup-r2:
    #!/usr/bin/env bash
    r2pm init
    r2pm install r2dec
    r2pm install r2ghidra
    echo '# Initialize analysis
    aaa
    # Show Go runtime info
    afl~runtime
    # Find main function
    afl~main
    # Generate callgraph
    agC
    # List strings
    izz' > analyze-go.r2

setup-debug-helpers:
    #!/usr/bin/env bash
    mkdir -p scripts
    echo '#!/bin/bash
    
    # Start delve debugging server
    function dlv-server() {
        dlv debug --headless --listen=:2345 --api-version=2 --accept-multiclient
    }
    
    # Attach to running process
    function dlv-attach() {
        dlv attach $(pgrep "$1") --headless --listen=:2345 --api-version=2
    }
    
    # Generate goroutine dump
    function go-routines() {
        curl -s http://localhost:${1:-8080}/debug/pprof/goroutine?debug=2
    }
    
    # Memory profile
    function go-memprofile() {
        curl -s http://localhost:${1:-8080}/debug/pprof/heap > heap.pprof
        go tool pprof -http=:8081 heap.pprof
    }' > scripts/debug-helpers.sh
    chmod +x scripts/debug-helpers.sh

# Install all development tools
setup-all: setup-reflex setup-gdb setup-r2 setup-debug-helpers
    #!/usr/bin/env bash
    go install github.com/golangci/golint/cmd/golangci-lint@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install github.com/cespare/reflex@latest
    go install github.com/divan/gotrace@latest
    go install github.com/genuinetools/godebug@latest
    go install github.com/ktr0731/evans@latest

# Development Workflow Recipes

# Start live reload with debug symbols
watch-debug:
    reflex -c .reflex.debug.conf

# Start live reload for normal development
watch:
    reflex -c .reflex.conf

# Start Radare2 analysis
analyze-r2: build-dev
    r2 -i analyze-go.r2 ./bin/{{binary_name}}-dev

# Generate and view goroutine dump
dump-routines:
    #!/usr/bin/env bash
    source scripts/debug-helpers.sh
    go-routines 8080

# Generate and view memory profile
profile-memory:
    #!/usr/bin/env bash
    source scripts/debug-helpers.sh
    go-memprofile 8080

[previous build recipes remain the same...]
