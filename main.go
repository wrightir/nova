package main

import (
	"archive/tar"
	"compress/gzip"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
)

const downloadURL = "https://github.com/engigu/baihu-panel/releases/download/v1.4.2/baihu-linux-amd64.tar.gz"

func main() {
	baihuDir := "/tmp/baihu"
	baihuBin := filepath.Join(baihuDir, "baihu-linux-amd64")
	tempBin := baihuBin + ".tmp"

	fmt.Println("========================================")
	fmt.Println("=== Baihu Go Runtime startup ===")
	fmt.Println("========================================")

	port := os.Getenv("PORT")
	if port == "" {
		port = "3000"
	}

	fmt.Println("PORT=" + port)
	fmt.Println("Downloading Baihu v1.4.2...")

	_ = os.RemoveAll(baihuDir)

	if err := os.MkdirAll(baihuDir, 0755); err != nil {
		fatal(err)
	}

	resp, err := http.Get(downloadURL)
	if err != nil {
		fatal(err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		fatal(fmt.Errorf("download failed: HTTP %d", resp.StatusCode))
	}

	gzipReader, err := gzip.NewReader(resp.Body)
	if err != nil {
		fatal(err)
	}
	defer gzipReader.Close()

	tarReader := tar.NewReader(gzipReader)

	found := false

	for {
		header, err := tarReader.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			fatal(err)
		}

		if filepath.Base(header.Name) != "baihu-linux-amd64" {
			continue
		}

		if header.Typeflag != tar.TypeReg {
			continue
		}

		out, err := os.OpenFile(
			tempBin,
			os.O_CREATE|os.O_WRONLY|os.O_TRUNC,
			0755,
		)
		if err != nil {
			fatal(err)
		}

		_, copyErr := io.Copy(out, tarReader)
		closeErr := out.Close()

		if copyErr != nil {
			fatal(copyErr)
		}

		if closeErr != nil {
			fatal(closeErr)
		}

		if err := os.Chmod(tempBin, 0755); err != nil {
			fatal(err)
		}

		if err := os.Rename(tempBin, baihuBin); err != nil {
			fatal(err)
		}

		found = true
		break
	}

	if !found {
		fatal(fmt.Errorf("baihu-linux-amd64 not found in archive"))
	}

	fmt.Println("Baihu binary:", baihuBin)

	fmt.Println("Starting Baihu on port:", port)

	cmd := exec.Command(baihuBin, "server")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	cmd.Env = append(
		os.Environ(),
		"BH_SERVER_HOST=0.0.0.0",
		"BH_SERVER_PORT="+port,
	)

	if err := cmd.Run(); err != nil {
		fatal(err)
	}
}

func fatal(err error) {
	fmt.Println("ERROR:", err)
	os.Exit(1)
}
