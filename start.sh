#!/bin/sh

set -e

echo "========================================"
echo "=== Baihu startup ==="
echo "========================================"

echo "PORT=$PORT"

BAIHU_DIR="/tmp/baihu"
BAIHU_TAR="/tmp/baihu.tar.gz"
BAIHU_BIN="$BAIHU_DIR/baihu-linux-amd64"

rm -rf "$BAIHU_DIR"
mkdir -p "$BAIHU_DIR"

echo "Downloading Baihu v1.4.2..."

wget -q -O "$BAIHU_TAR" \
  "https://github.com/engigu/baihu-panel/releases/download/v1.4.2/baihu-linux-amd64.tar.gz"

echo "Extracting Baihu..."

tar \
  --no-same-owner \
  --no-same-permissions \
  -xzf "$BAIHU_TAR" \
  -C "$BAIHU_DIR"

rm -f "$BAIHU_TAR"

chmod +x "$BAIHU_BIN"

export BH_SERVER_HOST=0.0.0.0
export BH_SERVER_PORT="$PORT"

echo "Baihu binary: $BAIHU_BIN"
echo "Starting Baihu on port: $BH_SERVER_PORT"

exec "$BAIHU_BIN" server
