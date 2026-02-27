#!/usr/bin/env bash
set -euo pipefail

echo "🚀 FlintCLI Full Installer"

command_exists() {
command -v "$1" >/dev/null 2>&1
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

# curl

if ! command_exists curl; then
echo "📦 Installing curl..."
install_packages curl
else
echo "✅ curl already installed"
fi

# python

if ! command_exists python3; then
echo "📦 Installing Python..."
install_packages python3
else
echo "✅ Python present: $(python3 --version)"
fi
# pip

if ! python3 -m pip --version >/dev/null 2>&1; then
echo "📦 Installing python3-pip..."
install_packages python3-pip
fi
# pipx

if command_exists pipx; then
echo "✅ pipx already installed"
else
echo "📦 Installing pipx..."
if [[ "$PKG_MANAGER" == "apt" ]]; then
sudo apt-get install -y pipx || python3 -m pip install --user pipx --break-system-packages
else
python3 -m pip install --user pipx
fi
python3 -m pipx ensurepath || true
fi
# ensure pipx path (current + future shells)
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null; then
echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi
export PATH="$HOME/.local/bin:$PATH"
hash -r

# node

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

# adb

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

echo "⬇️ Downloading FlintCLI..."

curl -fL -o flintcli-3.1.0-py3-none-any.whl "https://raw.githubusercontent.com/flint-lab/clisamplescript/main/flintcli-3.1.0-py3-none-any.whl"

# verify downloa
if [[ ! -s flintcli-3.1.0-py3-none-any.whl ]]; then
echo "❌ Download failed."
exit 1
fi

echo "📦 Installing FlintCLI via pipx..."
pipx install --force "$(pwd)/flintcli-3.1.0-py3-none-any.whl"

echo "🔍 Verifying FlintCLI..."

if command -v flintcli >/dev/null 2>&1; then
echo "✅ FlintCLI is ready"
else
echo ""
echo "⚠️ FlintCLI installed but not in PATH yet."
echo "👉 Please run:"
echo "   export PATH="$HOME/.local/bin:$PATH""
echo "   or open a new terminal."
fi

echo ""
echo "⚠️ IMPORTANT:"
echo "If 'flintcli' command is not found, run:"
echo '  export PATH="$HOME/.local/bin:$PATH"'
echo "or simply open a new terminal."
echo ""
echo ""
echo "🎉 FlintCLI installation complete!"
echo ""
echo "Run:"
echo "  flintcli version"
echo "  flintcli auth --nat <your_token>"
echo ""
