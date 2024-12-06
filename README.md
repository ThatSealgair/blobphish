# blobphish
Phishing analysis CLI tool.

# Development Setup Guide

## Prerequisites

### Installing Go
1. Download Go from the official website:
   - Visit [go.dev/dl](https://go.dev/dl/)
   - Choose your operating system:

```bash
# Linux (using apt)
wget https://go.dev/dl/go1.22.1.linux-amd64.tar.gz
sudo rm -rf /usr/local/go 
sudo tar -C /usr/local -xzf go1.22.1.linux-amd64.tar.gz

# Add to your ~/.bashrc or ~/.zshrc:
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$(go env GOPATH)/bin

# Verify installation
go version
```

### Installing Just
1. Install Just using your package manager:

```bash
# Using Homebrew (macOS or Linux)
brew install just

# Using apt (Debian/Ubuntu)
sudo apt update
sudo apt install just

# Using cargo (Any OS with Rust installed)
cargo install just

# Arch Linux
sudo pacman -S just
```

2. Verify installation:
```bash
just --version
```

## Development Setup

### First Time Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd <project-directory>
```

2. Install all required development tools:
```bash
# This will install all necessary Go tools, debuggers, and analysis tools
just install-dev-tools
```

3. Verify your setup:
```bash
# List all available commands
just list-commands

# List all available checks
just list-checks
```

### Development Workflow

1. Building:
```bash
# Development build with debug symbols
just build-dev

# Build with race detection
just build-race

# Optimized release build
just build-release
```

2. Running Tests and Checks:
```bash
# Run all checks
just check

# Run specific checks
just check-fmt      # Format code
just check-vet      # Run go vet
just check-staticcheck
just check-errcheck
```

3. Debugging:
```bash
# Using different debuggers
just debug-pwndbg ./bin/your-binary
just debug-gef ./bin/your-binary
just debug-dlv

# Record and replay execution
just rr-record ./bin/your-binary
just rr-replay
```

4. Profiling:
```bash
# CPU profiling
just profile-cpu ./bin/your-binary 30s

# Memory profiling
just profile-mem ./bin/your-binary 30s
```

5. Code Analysis:
```bash
# Analyze struct layouts
just analyze-structs

# Check memory issues
just check-memory
```

### Common Development Tasks

1. Before committing changes:
```bash
# Format code and run all checks
just check

# Run tests
just test
```

2. When investigating performance:
```bash
# CPU profile
just profile-cpu ./bin/your-binary

# Memory profile
just profile-mem ./bin/your-binary
```

3. When debugging issues:
```bash
# Start debug session
just debug-dlv

# Record program execution
just rr-record ./bin/your-binary
just rr-replay
```

### Updating Tools

To update all development tools:
```bash
just install-dev-tools
```

### Troubleshooting

1. If you encounter permission issues:
   - Ensure your GOPATH is properly set
   - Check if you have write permissions in the installation directories

2. If tools aren't found:
   - Verify they're in your PATH
   - Try reinstalling with `just install-dev-tools`

3. For debugging tool issues:
   - Verify GDB installation: `gdb --version`
   - Check if rr is supported on your system: `rr check`

## License

This project is licensed under the MIT License for non-commercial use. You are free to use, modify, and distribute the code for personal or academic purposes.

### Commercial Use
If you intend to use this software for commercial purposes (e.g., in a business or for profit), you must obtain a commercial license.

For commercial licensing terms, please refer to the [LICENSE-COMMERCIAL](LICENSE-COMMERCIAL) file or contact us at hunter.jay.k@gmail.com.

### How to Obtain a Commercial License
Please email hunter.jay.k@gmail.com to discuss licensing terms, pricing, and support options for commercial use.
