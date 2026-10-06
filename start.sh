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

"$BAIHU_BIN" server &
BAIHU_PID=$!

echo "Baihu PID: $BAIHU_PID"

cleanup() {
  echo "Stopping Baihu..."
  kill "$BAIHU_PID" 2>/dev/null || true
  wait "$BAIHU_PID" 2>/dev/null || true
  exit 143
}

trap cleanup TERM INT

sleep 5

echo "Checking local port: $PORT"

if wget -q -O /dev/null "http://127.0.0.1:$PORT"; then
  echo "LOCAL HEALTH CHECK: OK"
else
  echo "LOCAL HEALTH CHECK: FAILED"
fi

wait "$BAIHU_PID"
