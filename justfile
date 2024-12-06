# Development Environment Setup and Build System
#
# This justfile provides a complete development environment setup and build system
# for Go projects. It includes tools for building, testing, debugging, and analysis.
#
# Requirements:
# - Go 1.23 or later
# - Just command runner
# - Git
#
# First time setup:
# 1. Install Go: https://go.dev/dl/
# 2. Install just:
#    - Homebrew: brew install just
#    - Apt: sudo apt install just
#    - Cargo: cargo install just
# 3. Run: just install-dev-tools

# Load .env file if it exists
set dotenv-load

# ===== Basic Configuration =====

# Build variables
binary := "blobphish"
version := `git describe --tags --always --dirty`
commit := `git rev-parse HEAD`
build_date := `date -u +"%Y-%m-%dT%H:%M:%SZ"`

# Directories
bin_dir := "bin"
dist_dir := "dist"
debug_dir := ".debug"
tools_dir := "tools"

# Build flags
version_flags := "-X main.version=" + version + " -X main.commit=" + commit + " -X main.date=" + build_date
debug_flags := "-gcflags=all=-N -l"
release_flags := "-trimpath -ldflags='" + version_flags + " -s -w'"
race_flags := "-race"

# Tool paths and configurations
export R2_ANALYSIS_SCRIPT := "./tools/r2/analyze-go.r2"
export GDB_INIT_FILE := "./tools/gdb/project.gdb"

# ===== Prerequisite Checks =====

# Check if Go is installed
_check-go:
    #!/usr/bin/env bash
    if ! command -v go &> /dev/null; then
        echo "Error: Go is not installed. Visit https://go.dev/dl/"
        exit 1
    fi
    version=$(go version | awk '{print $3}' | sed 's/go//')
    if ! [[ "$version" > "1.23" || "$version" == "1.23"* ]]; then
        echo "Error: Go 1.23 or later is required"
        exit 1
    fi

# Check if Git is installed
_check-git:
    #!/usr/bin/env bash
    if ! command -v git &> /dev/null; then
        echo "Error: Git is not installed"
        exit 1
    fi

# ===== Development Environment Setup =====

# Install system dependencies based on package manager
_install-system-deps:
    #!/usr/bin/env bash
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y build-essential gdb python3 python3-pip \
            python3-dev cmake wget curl
    elif command -v dnf &> /dev/null; then
        sudo dnf groupinstall -y "Development Tools"
        sudo dnf install -y gdb python3 python3-pip python3-devel cmake wget curl
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy base-devel gdb python python-pip cmake wget curl
    else
        echo "Warning: Unsupported package manager. Please install build tools manually."
    fi

# Install all development tools
install-dev-tools: _check-go _check-git _install-system-deps install-go-tools install-debug-tools
    @echo "All development tools installed successfully"

# Install Go-specific analysis and development tools
install-go-tools:
    #!/usr/bin/env bash
    echo "Installing Go tools..."
    tools=(
        "honnef.co/go/tools/cmd/staticcheck@latest"
        "golang.org/x/tools/go/analysis/passes/structlayout/cmd/structlayout@latest"
        "golang.org/x/tools/go/analysis/passes/structlayout/cmd/structlayout-optimize@latest"
        "golang.org/x/tools/go/analysis/passes/structlayout/cmd/structlayout-pretty@latest"
        "github.com/mdempsky/unconvert@latest"
        "github.com/kisielk/errcheck@latest"
        "golang.org/x/vuln/cmd/govulncheck@latest"
        "github.com/gordonklaus/ineffassign@latest"
        "golang.org/x/tools/cmd/goimports@latest"
        "mvdan.cc/gofumpt@latest"
        "github.com/go-delve/delve/cmd/dlv@latest"
        "github.com/securego/gosec/v2/cmd/gosec@latest"
    )
    
    for tool in "${tools[@]}"; do
        echo "Installing $tool..."
        go install "$tool"
    done

# Install debugging tools
install-debug-tools: install-pwndbg install-gef install-rr
    @echo "All debugging tools installed successfully"

# Install pwndbg
install-pwndbg: _check-git
    #!/bin/bash
    if [ ! -d "~/pwndbg" ]; then
        git clone https://github.com/pwndbg/pwndbg ~/pwndbg
        cd ~/pwndbg
        ./setup.sh
    else
        echo "pwndbg already installed"
    fi

# Install GEF (GDB Enhanced Features)
install-gef:
    #!/bin/bash
    if [ ! -f "~/.gdbinit-gef.py" ]; then
        wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py
        echo "source ~/.gdbinit-gef.py" >> ~/.gdbinit
    else
        echo "GEF already installed"
    fi

# Install rr debugger
install-rr:
    #!/bin/bash
    if ! command -v rr &> /dev/null; then
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y rr
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y rr
        elif command -v pacman &> /dev/null; then
            sudo pacman -S rr
        else
            echo "Please install rr manually from https://github.com/rr-debugger/rr"
        fi
    else
        echo "rr already installed"
    fi

# ===== Build Commands =====

# Build development version with debug symbols
build-dev:
    @mkdir -p {{bin_dir}}
    go build \
        {{debug_flags}} \
        -ldflags {{version_flags}} \
        -o {{bin_dir}}/{{binary}}-dev \
        ./cmd/{{binary}}

# Build with race detection
build-race: build-dev
    @mkdir -p {{bin_dir}}
    go build \
        {{debug_flags}} \
        {{race_flags}} \
        -ldflags {{version_flags}} \
        -o {{bin_dir}}/{{binary}}-race \
        ./cmd/{{binary}}

# Build optimized release version
build-release:
    @mkdir -p {{bin_dir}}
    go build \
        {{release_flags}} \
        -o {{bin_dir}}/{{binary}} \
        ./cmd/{{binary}}

# ===== Test and Analysis Commands =====

# Run all checks
check: check-fmt check-vet check-staticcheck check-errcheck check-unconvert check-vuln check-ineffassign check-imports

# Format Go code
check-fmt:
    gofumpt -l -w .

# Run go vet
check-vet:
    go vet ./...
    go vet -structtag ./...
    go vet -shadow ./...

# Run staticcheck
check-staticcheck:
    staticcheck -checks all ./...

# Run errcheck
check-errcheck:
    errcheck -blank -asserts -ignoretests ./...

# Run unconvert
check-unconvert:
    unconvert -v ./...

# Run vulnerability check
check-vuln:
    govulncheck ./...

# Run ineffassign
check-ineffassign:
    ineffassign ./...

# Run goimports
check-imports:
    goimports -w .

# Run struct layout analysis
analyze-structs:
    #!/bin/bash
    for file in $(find . -name "*.go"); do
        echo "Analyzing structs in $file..."
        structlayout -json $file | structlayout-pretty
        echo "Optimization suggestions:"
        structlayout -json $file | structlayout-optimize
    done

# Memory analysis
check-memory:
    go test -race ./...
    go test -msan ./...  # If using clang compiler

# ===== Debug Commands =====

# Start debug session with pwndbg
debug-pwndbg TARGET:
    #!/bin/bash
    echo "set debuginfod enabled on" > /tmp/gdbinit-tmp
    echo "source ~/pwndbg/gdbinit.py" >> /tmp/gdbinit-tmp
    gdb -ix /tmp/gdbinit-tmp {{TARGET}}

# Start debug session with GEF
debug-gef TARGET:
    #!/bin/bash
    echo "source ~/.gdbinit-gef.py" > /tmp/gdbinit-tmp
    gdb -ix /tmp/gdbinit-tmp {{TARGET}}

# Start delve debug session
debug-dlv: build-dev
    dlv exec {{bin_dir}}/{{binary}}-dev

# Start headless debug server for editor integration
debug-server: build-dev
    dlv debug --headless --listen=:2345 --api-version=2 --accept-multiclient ./cmd/{{binary}}

# Print stack trace
print-stack TARGET:
    #!/bin/bash
    echo "thread apply all bt" | gdb {{TARGET}}

# Debug core dump
debug-core CORE_FILE TARGET:
    #!/bin/bash
    gdb {{TARGET}} {{CORE_FILE}}

# ===== Record and Replay Commands =====

# Record program execution
rr-record TARGET *ARGS:
    rr record {{TARGET}} {{ARGS}}

# Replay recorded execution
rr-replay:
    rr replay

# Replay recorded execution in reverse
rr-replay-reverse:
    rr replay -r

# List recorded traces
rr-ps:
    rr ps

# ===== Profile Commands =====

# Generate and view CPU profile
profile-cpu TARGET DURATION="30s":
    #!/bin/bash
    go build -o {{TARGET}}
    ./{{TARGET}} -cpuprofile=cpu.prof &
    sleep {{DURATION}}
    kill $!
    go tool pprof -http=:8080 cpu.prof

# Generate and view memory profile
profile-mem TARGET DURATION="30s":
    #!/bin/bash
    go build -o {{TARGET}}
    ./{{TARGET}} -memprofile=mem.prof &
    sleep {{DURATION}}
    kill $!
    go tool pprof -http=:8080 mem.prof

# ===== Maintenance Commands =====

# Clean build artifacts
clean:
    rm -rf {{bin_dir}} {{dist_dir}} {{debug_dir}}

# Generate release artifacts
release: clean test check build-release
    #!/bin/bash
    mkdir -p {{dist_dir}}
    cp {{bin_dir}}/{{binary}} {{dist_dir}}/
    tar czf {{dist_dir}}/{{binary}}-{{version}}.tar.gz -C {{bin_dir}} {{binary}}
    echo "Release artifacts created in {{dist_dir}}/"

# ===== Help Commands =====

# Show all available commands
list-commands:
    @just --list

# Show all available checks
list-checks:
    @echo "Available checks:"
    @echo "  - check-fmt: Format code using gofumpt"
    @echo "  - check-vet: Run go vet with all checks"
    @echo "  - check-staticcheck: Run staticcheck"
    @echo "  - check-errcheck: Check error handling"
    @echo "  - check-unconvert: Check unnecessary conversions"
    @echo "  - check-vuln: Check for vulnerabilities"
    @echo "  - check-ineffassign: Check ineffective assignments"
    @echo "  - check-imports: Check and fix imports"
    @echo "  - analyze-structs: Analyze struct layouts"
    @echo "  - check-memory: Run memory checks"

# Default recipe to show help
default:
    @just --list
