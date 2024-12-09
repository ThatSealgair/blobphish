# Binary name and paths
binary_name := "blobphish"
build_dir := "build"
main_path := "./cmd/blobphish"

# Build information
version := `git describe --tags --always --dirty`
build_time := `date -u '+%Y-%m-%d_%H:%M:%S'`
commit_hash := `git rev-parse --short HEAD`

# Debug output
debug_dir := "debug/"
cpu_prof := " -cpuprofile " + debug_dir + "cpu_" + version + build_time + " "
mem_prof := " -memprofile " + debug_dir + "mem_" + version + build_time + " "
mutex_prof := " -mutexprofile " + debug_dir + "mutex_" + version + build_time + " "
trace_prof := "  -traceprofile " + debug_dir + "trace_" + version + build_time + ""


# Build flags
gc_flags := "-gcflags="
ld_flags := "-ldflags="
ld_info := "-X main.Version=" + version + " -X main.BuildTime=" + build_time + " -X main.CommitHash=" + commit_hash

gcflags_release := gc_flags + "'" + "-L -m -race -h" + "'"
ldflags_release := ld_flags + "'" + ld_info + " -h -race -s" + "'"

gcflags_debug := gc_flags + "'" + "-E -K -L -N -W -l -m -j -r -race -w -v" + cpu_prof + mem_prof + mutex_prof + trace_prof + "'"
ldflags_debug := ld_flags + "'" + ld_info + "-n -race -v -c" + "'"

# Default recipe
default: list

# Quality control
audit:
    @echo "Running quality control checks..."
    just clean
    go mod tidy -diff
    go mod verify
    just test

# Build for development
build:
    CGO_ENABLED=1 GOARCH=amd64 GOOS=darwin go build -o {{build_dir}}/{{binary_name}}-darwin {{main_path}}
    CGO_ENABLED=1 GOARCH=amd64 GOOS=linux go build -o {{build_dir}}/{{binary_name}}-linux {{main_path}}
    CGO_ENABLED=1 GOARCH=amd64 GOOS=windows go build -o {{build_dir}}/{{binary_name}}-windows {{main_path}}
    @echo "Building {{binary_name}}..."
    mkdir -p {{build_dir}}
    go build {{ldflags_release}} {{gcflags_release}} -o {{build_dir}}/{{binary_name}} {{main_path}}

# Build for debugging
debug:
    @echo "Building debug binary..."
    mkdir -p {{build_dir}}
    CGO_ENABLED=1 go build {{ldflags_debug}} {{gcflags_debug}} -o {{build_dir}}/{{binary_name}}-debug {{main_path}}
    

# Build for release with optimizations
# TODO: Fix this
#release:
#    @echo "Building release binary..."
#    mkdir -p {{build_dir}}
#    # Linux build
#    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
#        go build -trimpath -a -ldflags {{ldflags}} \
#        -o {{build_dir}}/{{binary_name}}-linux-amd64 {{main_path}}
#    # MacOS build
#    CGO_ENABLED=0 GOOS=darwin GOARCH=amd64 \
#        go build -trimpath -a -ldflags {{ldflags}} \
#        -o {{build_dir}}/{{binary_name}}-darwin-amd64 {{main_path}}
#    # Windows build
#    CGO_ENABLED=0 GOOS=windows GOARCH=amd64 \
#        go build -trimpath -a -ldflags {{ldflags}} \
#        -o {{build_dir}}/{{binary_name}}-windows-amd64.exe {{main_path}}

# Run tests
test:
    @echo "Running tests..."
    go test -v -race test/

test-complete:
    @echo "Running complete tests..."
    go test -v -race -buildcvs -coverprofile=/tmp/coverage.out .
    go tool cover -html=/tmp/coverage.out

test-quck:
    @echo "Running quick tests.."
    go test -v -race -short test/

# Generate test coverage report
coverage:
    @echo "Generating coverage report..."
    mkdir -p {{build_dir}}
    go test -coverprofile={{build_dir}}/coverage.out ./...
    go tool cover -html={{build_dir}}/coverage.out -o {{build_dir}}/coverage.html

# Run linter
lint:
    @echo "Running linter..."
    revive .

# Run go vet
vet:
    @echo "Running go vet..."
    go vet .

# Format code
fmt:
    @echo "Formatting code..."
    gofmt -s -e -l -w .

# Clean build directory
clean:
    @echo "Cleaning build directory..."
    rm -rf {{build_dir}}

# Build Docker image
docker:
    @echo "Building Docker image..."
    docker build -t {{binary_name}}:{{version}} \
        --build-arg VERSION={{version}} \
        --build-arg BUILD_TIME={{build_time}} \
        --build-arg COMMIT_HASH={{commit_hash}} .

run-debug: debug
    @echo "Running DEBUG {{binary_name}}.."
    

# Run the application
run: build
    @echo "Running {{binary_name}}..."
    ./{{build_dir}}/{{binary_name}}

# List available recipes
list:
    @just --list
