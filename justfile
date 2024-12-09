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

debug_flags := "-gcflags=all='-N -L -K'"
release_flags := "-trimpath -ldflags='" + version_flags + " -s -w'"
race_flags := "-race"

# Tool paths and configurations
export R2_ANALYSIS_SCRIPT := "./tools/r2/analyze-go.r2"
export GDB_INIT_FILE := "./tools/gdb/project.gdb"

# ===== Help Commands =====

# Show all available commands
list-commands:
    @just --list

# Show quick start guide
help:
    @echo "Quick Start Guide:"
    @echo "1. First time setup:    just install-dev-tools"
    @echo "2. Build project:       just build-dev"
    @echo "3. Run all tests:       just test"
    @echo "4. Run all checks:      just check"
    @echo ""
    @echo "Use 'just help-<topic>' for more information:"
    @echo "  - help-build:     Build commands"
    @echo "  - help-test:      Testing commands"
    @echo "  - help-debug:     Debugging tools"
    @echo "  - help-profile:   Profiling tools"
    @echo "  - help-checks:    Code analysis"
    @echo "  - help-tools:     Tool management"

# Show build help
help-build:
    @echo "Build Commands:"
    @echo "  just build-dev              Build with debug symbols"
    @echo "  just build-race            Build with race detector"
    @echo "  just build-release         Build optimized release version"
    @echo ""
    @echo "Build artifacts are placed in ./bin/"
    @echo "Use clean to remove build artifacts: just clean"

# Show test help
help-test:
    @echo "Test Commands:"
    @echo "  just test                  Run all tests"
    @echo "  just test-pattern <pat>    Run tests matching pattern"
    @echo "  just test-coverage         Run tests with coverage"
    @echo "  just test-bench [pat]      Run benchmarks"
    @echo "  just test-debug            Build test binary for debugging"
    @echo ""
    @echo "Coverage report will be in .debug/coverage.html"

# Show debug help
help-debug:
    @echo "Debug Commands:"
    @echo "  just debug-dlv             Debug with Delve"
    @echo "  just debug-pwndbg <bin>    Debug with pwndbg"
    @echo "  just debug-gef <bin>       Debug with GEF"
    @echo "  just debug-server          Start headless debug server"
    @echo ""
    @echo "Record & Replay:"
    @echo "  just rr-record <bin>       Record program execution"
    @echo "  just rr-replay             Replay recorded execution"
    @echo "  just rr-replay-reverse     Replay in reverse"
    @echo ""
    @echo "Core Dumps:"
    @echo "  just debug-core <core> <bin>  Analyze core dump"

# Show profiling help
help-profile:
    @echo "Profiling Commands:"
    @echo "  just profile-cpu <bin> [duration]  CPU profile"
    @echo "  just profile-mem <bin> [duration]  Memory profile"
    @echo ""
    @echo "Default duration is 30s"
    @echo "Profiles are viewed in browser at localhost:8080"

# Show code analysis help
help-checks:
    @echo "Analysis Commands:"
    @echo "  just check                 Run all checks"
    @echo "  just check-fmt             Format code"
    @echo "  just check-vet             Run go vet"
    @echo "  just check-staticcheck     Run staticcheck"
    @echo "  just check-errcheck        Check error handling"
    @echo "  just check-unconvert       Find unnecessary conversions"
    @echo "  just check-vuln            Check for vulnerabilities"
    @echo "  just check-ineffassign     Find ineffective assignments"
    @echo "  just analyze-structs       Analyze struct layouts"

# Show tool management help
help-tools:
    @echo "Tool Management:"
    @echo "  just install-dev-tools     Install all development tools"
    @echo "  just install-go-tools      Install Go-specific tools"
    @echo "  just install-debug-tools   Install debugging tools"
    @echo ""
    @echo "Individual Debug Tools:"
    @echo "  just install-pwndbg        Install pwndbg"
    @echo "  just install-gef           Install GEF"
    @echo "  just install-rr            Install rr"

# Show examples of common workflows
help-examples:
    @echo "Common Workflows:"
    @echo ""
    @echo "1. Start development:"
    @echo "   just build-dev"
    @echo "   just test"
    @echo "   just check"
    @echo ""
    @echo "2. Debug an issue:"
    @echo "   just build-dev"
    @echo "   just debug-dlv"
    @echo ""
    @echo "3. Profile performance:"
    @echo "   just build-release"
    @echo "   just profile-cpu bin/myapp"
    @echo ""
    @echo "4. Prepare for commit:"
    @echo "   just check"
    @echo "   just test"
    @echo "   just check-vuln"
    @echo ""
    @echo "5. Create release:"
    @echo "   just check"
    @echo "   just test"
    @echo "   just release"

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
check: check-fmt check-vet check-staticcheck check-unconvert check-vuln check-ineffassign check-imports

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

# ===== Test Commands =====

# Run all tests
test:
    go test -v -race ./...

# Run tests matching a pattern
test-pattern PATTERN:
    go test -v -race ./... -run {{PATTERN}}

# Run tests with coverage
test-coverage:
    #!/bin/bash
    mkdir -p {{debug_dir}}
    go test -v -race -coverprofile={{debug_dir}}/coverage.out ./...
    go tool cover -html={{debug_dir}}/coverage.out -o {{debug_dir}}/coverage.html
    xdg-open {{debug_dir}}/coverage.html 2>/dev/null || open {{debug_dir}}/coverage.html 2>/dev/null || echo "Coverage report at {{debug_dir}}/coverage.html"

# Run benchmarks
test-bench pattern="":
    go test -v -run=NONE -bench={{pattern}} -benchmem ./...

# Run tests in verbose mode with race detection and generate test binary for debugging
test-debug:
    go test -v -race -c -o {{bin_dir}}/test.test ./...

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
