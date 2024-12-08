// cmd/blobphish/main.go
package main

import (
	"fmt"
	"os"

	"github.com/ThatSealgair/blobphish/internal/cli"
)

func main() {
	// Parse command-line flags
	config := cli.ParseFlags()

	// Run the CLI
	if err := cli.Execute(config); err != nil {
		fmt.Println(cli.DefaultStyles.Error.Render(err.Error()))
		os.Exit(1)
	}
}
