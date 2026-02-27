#!/usr/bin/env bash

# worked on grafana vm
set -euo pipefail

echo "🚀 FlintCLI Prerequisite Installer (Linux)"

command_exists() {
command -v "$1" >/dev/null 2>&1
}

version_ge() {
printf '%s\n%s\n' "$2" "$1" | sort -C -V
}

detect_pkg_manager() {
if command_exists apt-get; then
PKG_MANAGER="apt"
elif command_exists dnf; then
PKG_MANAGER="dnf"
elif command_exists yum; then
PKG_MANAGER="yum"
else
echo "❌ Unsupported Linux distribution."
exit 1
fi
}

install_packages() {
case "$PKG_MANAGER" in
apt)
sudo apt-get update -y
sudo apt-get install -y "$@"
;;
dnf)
sudo dnf install -y "$@"
;;
yum)
sudo yum install -y "$@"
;;
esac
}

if ! sudo -n true 2>/dev/null; then
echo "🔐 Sudo access required..."
sudo true
fi

detect_pkg_manager
echo "✅ Package manager: $PKG_MANAGER"

if ! command_exists curl; then
echo "📦 Installing curl..."
install_packages curl
else
echo "✅ curl already installed"
fi

PY_MIN="3.8.10"
if command_exists python3; then
PY_VER=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))')
if version_ge "$PY_VER" "$PY_MIN"; then
echo "✅ Python OK: $PY_VER"
else
echo "📦 Installing Python..."
install_packages python3
fi
else
echo "📦 Installing Python..."
install_packages python3
fi

if ! python3 -m pip --version >/dev/null 2>&1; then
echo "📦 Installing python3-pip..."
install_packages python3-pip
fi

if command_exists pipx; then
echo "✅ pipx already installed"
else
echo "📦 Installing pipx..."
if [[ "$PKG_MANAGER" == "apt" ]]; then
if ! sudo apt-get install -y pipx >/dev/null 2>&1; then
python3 -m pip install --user pipx --break-system-packages
fi
else
python3 -m pip install --user pipx
fi
python3 -m pipx ensurepath || true
export PATH="$HOME/.local/bin:$PATH"
hash -r
fi

if command_exists node; then
echo "✅ Node already installed: $(node --version)"
else
echo "📦 Installing Node.js 20 LTS..."
if [[ "$PKG_MANAGER" == "apt" ]]; then
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
install_packages nodejs
else
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
install_packages nodejs
fi
fi

if command_exists adb; then
echo "✅ ADB already installed"
else
echo "📦 Installing ADB..."
if [[ "$PKG_MANAGER" == "apt" ]]; then
install_packages adb
else
install_packages android-tools
fi
fi

echo ""
echo "🎉 Prerequisites ready"
echo "Python : $(python3 --version 2>/dev/null || echo missing)"
echo "pipx   : $(pipx --version 2>/dev/null || echo missing)"
echo "Node   : $(node --version 2>/dev/null || echo missing)"
echo "ADB    : $(adb version 2>/dev/null | head -n1 || echo missing)"
echo ""
