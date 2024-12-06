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

# Build for development with debug symbols
build-dev:
    #!/usr/bin/env bash
    echo "Building development version with debug symbols..."
    go build \
        -gcflags="all=-N -l" \
        -ldflags "{{version_flags}}" \
        -o bin/{{binary_name}}-dev \
        ./cmd/{{binary_name}}

# Build with race detection
build-race: build-dev
    #!/usr/bin/env bash
    echo "Building development version with race detection..."
    go build \
        -gcflags="all=-N -l" \
        -race \
        -ldflags "{{version_flags}}" \
        -o bin/{{binary_name}}-race \
        ./cmd/{{binary_name}}

# Build optimized release version
build-release:
    #!/usr/bin/env bash
    echo "Building optimized release version..."
    go build \
        -trimpath \
        -ldflags "{{version_flags}} -s -w" \
        -o bin/{{binary_name}} \
        ./cmd/{{binary_name}}

# Run tests
test:
    go test -v -race ./...

# Run tests with coverage
test-coverage:
    go test -v -race -coverprofile=coverage.out ./...
    go tool cover -html=coverage.out

# Run linter
lint:
    golangci-lint run

# Clean build artifacts
clean:
    rm -rf bin/
    rm -f coverage.out

# Debug with GDB
debug-gdb: build-dev
    #!/usr/bin/env bash
    echo "Starting GDB session..."
    gdb --quiet \
        -ex "set disassembly-flavor intel" \
        -ex "b main.main" \
        -ex "r" \
        ./bin/{{binary_name}}-dev

# Debug with Radare2
debug-radare: build-dev
    #!/usr/bin/env bash
    echo "Starting Radare2 session..."
    r2 -d ./bin/{{binary_name}}-dev

# Debug with Delve
debug-dlv: build-dev
    dlv exec ./bin/{{binary_name}}-dev

# Start debug server for Helix
debug-server: build-dev
    dlv debug --headless --listen=:2345 --api-version=2 --accept-multiclient ./cmd/{{binary_name}}

# Run with live reload using reflex
watch:
    reflex -r '\.go$' -s -- go run ./cmd/{{binary_name}}

# Watch tests
watch-test:
    reflex -r '\.go$' -s -- go test ./...

# Generate all artifacts for a release
release: clean test lint build-release
    #!/usr/bin/env bash
    echo "Creating release artifacts..."
    mkdir -p dist
    cp bin/{{binary_name}} dist/
    tar czf dist/{{binary_name}}-{{version}}.tar.gz -C bin {{binary_name}}
    echo "Release artifacts created in dist/"

# Install development tools
install-tools:
    #!/usr/bin/env bash
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install github.com/cespare/reflex@latest
