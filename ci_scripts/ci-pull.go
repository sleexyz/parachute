// Sample storage-quickstart creates a Google Cloud Storage bucket.
package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"time"

	"cloud.google.com/go/storage"
)

func main() {
	ctx := context.Background()

	client, err := storage.NewClient(ctx)
	if err != nil {
		log.Fatalf("Failed to create client: %v", err)
	}
	defer client.Close()

	// Creates the new bucket.
	ctx, cancel := context.WithTimeout(ctx, time.Second*10)
	defer cancel()

	commit := os.Getenv("CI_COMMIT")
	l := log.New(os.Stderr, "", 0)
	objPath := fmt.Sprintf("Ffi.xcframework_%s.tgz", commit)
	l.Printf("objPath: %s", objPath)

	rc, err := client.Bucket("slowdown-ci").Object(objPath).NewReader(ctx)
	if err != nil {
		log.Fatalf("Failed to create reader: %v", err)
	}

	_, err = io.Copy(os.Stdout, rc)
	if err != nil {
		log.Fatalf("Failed to write file: %v", err)
	}
}
