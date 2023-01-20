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

	commit := os.Getenv("CI_COMMIT")
	buildNumber := os.Getenv("CI_BUILD_NUMBER")
	baseName := os.Getenv("CI_ARCHIVE_PATH_BASENAME")

	l := log.New(os.Stderr, "", 0)
	objPath := fmt.Sprintf("%s_%s.xcarchive_%s.tgz", baseName, buildNumber, commit)
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
