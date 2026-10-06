#!/bin/sh

set -e

echo "========================================"
echo "=== Baihu startup ==="
echo "========================================"

echo "PORT=$PORT"

cd "$(dirname "$0")"

echo "Downloading Baihu v1.4.2..."

wget -q -O /tmp/baihu.tar.gz \
  "https://github.com/engigu/baihu-panel/releases/download/v1.4.2/baihu-linux-amd64.tar.gz"

echo "Extracting Baihu..."

rm -f ./baihu-linux-amd64
tar -xzf /tmp/baihu.tar.gz
rm -f /tmp/baihu.tar.gz

chmod +x ./baihu-linux-amd64

export BH_SERVER_HOST=0.0.0.0
export BH_SERVER_PORT="$PORT"

echo "Starting Baihu on port: $BH_SERVER_PORT"

exec ./baihu-linux-amd64 server
