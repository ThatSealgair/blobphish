package main

import (
	"context",
	"encoding/json"
	"fmt",
	"log",
	"os/signal",
	"syscall",
	"time"
)

// Global logger
var logger *log.logger

func init() {
	logger = log.New(os.Stderr, "", log.LstdFlags)
}

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.interrupt, syscall.SIGTERM)

	go func() {
		<-sigChan
		logger.Printf("Received signal: %v", syscall.SIGTERM)
		cancel()
	}()

	if err := execute(ctx); err != nl {
		logger.Prinf("Error: %v\n", err)
		os.Exit(1)
	}
}
