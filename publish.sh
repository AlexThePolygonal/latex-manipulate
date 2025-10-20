#!/bin/bash

# publish.sh - Install latex-split and latex-merge to /usr/local/bin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root for installation to /usr/local/bin
check_permissions() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script needs root privileges to install to /usr/local/bin"
        echo "Usage: sudo $0"
        exit 1
    fi
}

# Check if scripts exist
check_scripts() {
    local missing_scripts=()

    if [[ ! -f "latex-split" ]]; then
        missing_scripts+=("latex-split")
    fi

    if [[ ! -f "latex-merge" ]]; then
        missing_scripts+=("latex-merge")
    fi

    if [[ ${#missing_scripts[@]} -gt 0 ]]; then
        print_error "Missing required scripts: ${missing_scripts[*]}"
        echo "Please ensure both latex-split and latex-merge exist in the current directory."
        exit 1
    fi
}

# Test scripts before installation
test_scripts() {
    print_status "Testing latex-split..."
    if ! ./latex-split --test > /dev/null 2>&1; then
        print_error "latex-split test failed"
        exit 1
    fi
    echo "✓ latex-split tests passed"

    print_status "Testing latex-merge..."
    if ! ./latex-merge --test > /dev/null 2>&1; then
        print_error "latex-merge test failed"
        exit 1
    fi
    echo "✓ latex-merge tests passed"
}

# Install scripts
install_scripts() {
    local target_dir="/usr/local/bin"

    print_status "Installing scripts to $target_dir..."

    # Backup existing installations if they exist
    for script in latex-split latex-merge; do
        if [[ -f "$target_dir/$script" ]]; then
            print_warning "Backing up existing $script to $target_dir/$script.backup"
            cp "$target_dir/$script" "$target_dir/$script.backup"
        fi
    done

    # Copy scripts
    cp latex-split "$target_dir/"
    cp latex-merge "$target_dir/"

    # Set executable permissions
    chmod 755 "$target_dir/latex-split"
    chmod 755 "$target_dir/latex-merge"

    echo "✓ Installed latex-split to $target_dir/latex-split"
    echo "✓ Installed latex-merge to $target_dir/latex-merge"
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."

    # Check if scripts are in PATH and executable
    if command -v latex-split >/dev/null 2>&1; then
        echo "✓ latex-split is now available in PATH"
    else
        print_error "latex-split not found in PATH after installation"
        return 1
    fi

    if command -v latex-merge >/dev/null 2>&1; then
        echo "✓ latex-merge is now available in PATH"
    else
        print_error "latex-merge not found in PATH after installation"
        return 1
    fi
}

# Show usage examples
show_usage() {
    echo ""
    print_status "Installation complete! Usage examples:"
    echo ""
    echo "  latex-split document.tex --output-dir my_paper --verbose"
    echo "  latex-merge main.tex --output merged_document.tex --force"
    echo ""
    echo "Run 'latex-split --help' or 'latex-merge --help' for more options."
}

# Main installation flow
main() {
    echo "LaTeX Manipulation Tools Installer"
    echo "=================================="
    echo ""

    check_permissions
    check_scripts
    test_scripts
    install_scripts
    verify_installation
    show_usage

    print_status "Installation completed successfully!"
}

# Handle script arguments
case "${1:-}" in
    --help|-h)
        echo "Usage: $0"
        echo ""
        echo "Install latex-split and latex-merge to /usr/local/bin"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help message"
        echo ""
        echo "Note: This script requires root privileges."
        exit 0
        ;;
    "")
        main
        ;;
    *)
        print_error "Unknown option: $1"
        echo "Use --help for usage information."
        exit 1
        ;;
esac