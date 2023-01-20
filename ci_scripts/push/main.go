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
	ctx, cancel := context.WithTimeout(ctx, time.Second*30)
	defer cancel()

	archiveName := os.Getenv("ARCHIVE_NAME")

	l := log.New(os.Stderr, "", 0)
	objPath := fmt.Sprintf("%s.tgz", archiveName)
	l.Printf("objPath: %s", objPath)

	o := client.Bucket("slowdown-ci-archives").Object(objPath)
	o = o.If(storage.Conditions{DoesNotExist: true})

	w := o.NewWriter(ctx)

	if _, err = io.Copy(w, os.Stdin); err != nil {
		log.Fatalf("Failed to write file: %v", err)
	}
	if err := w.Close(); err != nil {
		log.Fatalf("Failed to close writer: %v", err)
	}
	l.Printf("%s uploaded.", objPath)
}
