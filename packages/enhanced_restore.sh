#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Package file definitions
PKGLIST="pkglist.txt"
AURLIST="aurlist.txt"
PKGLIST_VANILLA="pkglist_vanilla_arch.txt"
AURLIST_VANILLA="aurlist_vanilla_arch.txt"

# Statistics tracking
declare -g STATS_SUCCESS=0
declare -g STATS_FAILED=0
declare -g STATS_SKIPPED=0
declare -g STATS_EOS_ONLY=0
declare -g STATS_AUR_ONLY=0

# Log files
LOG_FILE="$(mktemp)"
REPORT_FILE="$(mktemp)"

# Package substitution database
declare -A PACKAGE_SUBSTITUTIONS=(
    ["arc-gtk-theme-eos"]="arc-gtk-theme"
    ["welcome"]="eos-welcome"
    ["reflector-simple"]="reflector"
    ["hwdetect"]="lshw hwinfo"
    ["downgrade"]="(AUR: downgrade)"
)

# Endesvouros-specific packages
declare -A EOS_ONLY_PACKAGES=(
    ["arc-gtk-theme-eos"]="EndeavourOS theme, use arc-gtk-theme"
    ["welcome"]="EndeavourOS welcome utility"
    ["reflector-simple"]="EOS-specific mirror tool, use reflector"
    ["hwdetect"]="EOS hardware detection, use lshw instead"
)

# AUR-only packages (incorrectly listed as official)
declare -A AUR_ONLY_PACKAGES=(
    ["ghostty"]="Modern terminal emulator"
    ["spotify-player"]="Spotify TUI client"
    ["spotify-launcher"]="Spotify desktop launcher"
    ["spotifyd"]="Spotify daemon"
    ["kernel-install-for-dracut"]="Kernel install helper"
    ["networkmanager-dmenu"]="NetworkManager dmenu interface"
    ["hyprshot"]="Screenshot utility for Hyprland"
    ["downgrade"]="Package downgrade utility"
)

log() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

log_success() {
    log "${GREEN}✅ $1${NC}"
    ((STATS_SUCCESS++))
}

log_warning() {
    log "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    log "${RED}❌ $1${NC}"
    ((STATS_FAILED++))
}

log_info() {
    log "${BLUE}ℹ️  $1${NC}"
}

log_header() {
    log "${BOLD}$1${NC}"
}

# System detection
detect_system() {
    log_info "Detecting system type..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID" | grep -q "endeavouros" && echo "endeavouros" || echo "arch"
    else
        echo "arch"
    fi
}

# Repository validation
validate_repositories() {
    log_info "Validating repository configuration..."
    
    local system_type
    system_type=$(detect_system)
    
    local required_repos=("core" "extra")
    
    # EndeavourOS doesn't have separate community repo
    if [[ "$system_type" == "arch" ]]; then
        required_repos+=("community")
    fi
    
    local missing_repos=()
    
    for repo in "${required_repos[@]}"; do
        if ! grep -q "^\[$repo\]" /etc/pacman.conf; then
            missing_repos+=("$repo")
        fi
    done
    
    if [[ ${#missing_repos[@]} -gt 0 ]]; then
        log_error "Missing required repositories: ${missing_repos[*]}"
        log_info "Please enable these repositories in /etc/pacman.conf"
        return 1
    fi
    
    # Check multilib
    if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
        log_warning "multilib repository not enabled - some packages may fail"
    fi
    
    log_success "Repository validation complete"
    return 0
}

# Check if package exists in official repos
package_exists_official() {
    local pkg="$1"
    pacman -Si "$pkg" &>/dev/null
}

# Check if package exists in AUR
package_exists_aur() {
    local pkg="$1"
    # Simple check - could be enhanced with curl to AUR API
    return 1
}

# Categorize package
categorize_package() {
    local pkg="$1"
    local system_type="$2"
    
    # Check EOS-specific packages
    if [[ -n "${EOS_ONLY_PACKAGES[$pkg]:-}" ]]; then
        echo "EOS_ONLY"
        return
    fi
    
    # Check AUR-only packages
    if [[ -n "${AUR_ONLY_PACKAGES[$pkg]:-}" ]]; then
        echo "AUR_ONLY"
        return
    fi
    
    # Check official repositories
    if package_exists_official "$pkg"; then
        echo "OFFICIAL"
        return
    fi
    
    # Check AUR as fallback
    if package_exists_aur "$pkg"; then
        echo "AUR_ONLY"
        return
    fi
    
    echo "NOT_FOUND"
}

# Generate compatibility-specific package lists
generate_compatibility_lists() {
    local system_type="$1"
    
    log_info "Generating package lists for $system_type..."
    
    if [[ ! -f "$PKGLIST" ]]; then
        log_error "Source package list not found: $PKGLIST"
        return 1
    fi
    
    # Clear output files
    > "$PKGLIST_VANILLA"
    > "$AURLIST_VANILLA"
    
    local total=0
    local official=0
    local aur_only=0
    local eos_only=0
    local not_found=0
    
    while read -r pkg; do
        # Skip empty lines and comments
        [[ -z "$pkg" || "$pkg" =~ ^[[:space:]]*# ]] && continue
        
        ((total++))
        local category
        category=$(categorize_package "$pkg" "$system_type")
        
        case "$category" in
            "OFFICIAL")
                echo "$pkg" >> "$PKGLIST_VANILLA"
                ((official++))
                ;;
            "AUR_ONLY")
                echo "$pkg" >> "$AURLIST_VANILLA"
                ((aur_only++))
                ;;
            "EOS_ONLY")
                ((eos_only++))
                local substitution="${PACKAGE_SUBSTITUTIONS[$pkg]:-}"
                if [[ "$substitution" != "(AUR: downgrade)" ]]; then
                    log_warning "EOS-only package: $pkg"
                    if [[ -n "$substitution" && "$substitution" != "EOS welcome utility" ]]; then
                        log_info "  Suggestion: $substitution"
                    fi
                fi
                ;;
            "NOT_FOUND")
                ((not_found++))
                log_warning "Package not found: $pkg"
                ;;
        esac
    done < "$PKGLIST"
    
    log_success "Package categorization complete:"
    log_info "  Total processed: $total"
    log_info "  Official packages: $official"
    log_info "  AUR packages: $aur_only"
    log_info "  EOS-only packages: $eos_only"
    log_info "  Not found: $not_found"
    
    return 0
}

# Install packages with detailed error handling
install_official_packages() {
    log_header "📦 Installing Official Packages"
    
    if [[ ! -f "$PKGLIST_VANILLA" ]] || [[ ! -s "$PKGLIST_VANILLA" ]]; then
        log_warning "No official packages to install"
        return 0
    fi
    
    local pkg_count=$(wc -l < "$PKGLIST_VANILLA")
    log_info "Installing $pkg_count official packages..."
    
    # Update package databases
    log_info "Updating package databases..."
    sudo pacman -Sy || {
        log_error "Failed to update package databases"
        return 1
    }
    
    # Validate each package before installation
    local valid_packages=()
    local failed_packages=()
    
    while read -r pkg; do
        [[ -z "$pkg" ]] && continue
        
        if package_exists_official "$pkg"; then
            valid_packages+=("$pkg")
        else
            failed_packages+=("$pkg")
            log_error "Package not available in repositories: $pkg"
        fi
    done < "$PKGLIST_VANILLA"
    
    # Install valid packages
    if [[ ${#valid_packages[@]} -gt 0 ]]; then
        log_info "Installing ${#valid_packages[@]} valid packages..."
        
        for pkg in "${valid_packages[@]}"; do
            log_info "Installing: $pkg"
            if sudo pacman -S --needed --noconfirm "$pkg"; then
                log_success "Installed: $pkg"
            else
                log_error "Failed to install: $pkg"
            fi
        done
    fi
    
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        log_error "Failed packages:"
        printf '  %s\n' "${failed_packages[@]}"
    fi
}

# Install AUR packages
install_aur_packages() {
    log_header "📦 Installing AUR Packages"
    
    # Check for AUR helper
    if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
        log_info "No AUR helper found, installing yay..."
        install_aur_helper
    fi
    
    local aur_helper
    if command -v yay &>/dev/null; then
        aur_helper="yay"
    elif command -v paru &>/dev/null; then
        aur_helper="paru"
    else
        log_error "No AUR helper available"
        return 1
    fi
    
    if [[ ! -f "$AURLIST_VANILLA" ]] || [[ ! -s "$AURLIST_VANILLA" ]]; then
        log_warning "No AUR packages to install"
        return 0
    fi
    
    local pkg_count=$(wc -l < "$AURLIST_VANILLA")
    log_info "Installing $pkg_count AUR packages with $aur_helper..."
    
    while read -r pkg; do
        [[ -z "$pkg" ]] && continue
        
        log_info "Installing AUR package: $pkg"
        if "$aur_helper" -S --needed --noconfirm "$pkg"; then
            log_success "Installed AUR: $pkg"
        else
            log_error "Failed to install AUR: $pkg"
        fi
    done < "$AURLIST_VANILLA"
}

# Install AUR helper
install_aur_helper() {
    log_info "Installing yay AUR helper..."
    
    local tmpdir
    tmpdir=$(mktemp -d)
    
    if git clone https://aur.archlinux.org/yay.git "$tmpdir"; then
        if (cd "$tmpdir" && makepkg -si --noconfirm); then
            log_success "AUR helper installed successfully"
        else
            log_error "Failed to install AUR helper"
        fi
    else
        log_error "Failed to clone yay repository"
    fi
    
    rm -rf "$tmpdir"
}

# Verify installations
verify_installations() {
    log_header "🔍 Verifying Installations"
    
    local verification_failed=0
    
    # Check official packages
    if [[ -f "$PKGLIST_VANILLA" ]]; then
        while read -r pkg; do
            [[ -z "$pkg" ]] && continue
            if pacman -Q "$pkg" &>/dev/null; then
                log_success "Verified: $pkg"
            else
                log_error "Not installed: $pkg"
                ((verification_failed++))
            fi
        done < "$PKGLIST_VANILLA"
    fi
    
    # Check AUR packages
    if [[ -f "$AURLIST_VANILLA" ]]; then
        while read -r pkg; do
            [[ -z "$pkg" ]] && continue
            if pacman -Q "$pkg" &>/dev/null; then
                log_success "Verified AUR: $pkg"
            else
                log_error "AUR not installed: $pkg"
                ((verification_failed++))
            fi
        done < "$AURLIST_VANILLA"
    fi
    
    if [[ $verification_failed -eq 0 ]]; then
        log_success "All packages verified successfully"
    else
        log_warning "$verification_failed packages failed verification"
    fi
}

# Generate final report
generate_report() {
    log_header "📊 Installation Report"
    
    local total_packages=$((STATS_SUCCESS + STATS_FAILED + STATS_SKIPPED + STATS_EOS_ONLY + STATS_AUR_ONLY))
    
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "${BOLD}Installation Summary${NC}"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log "${GREEN}✅ Successfully installed: $STATS_SUCCESS${NC}"
    log "${RED}❌ Failed to install: $STATS_FAILED${NC}"
    log "${YELLOW}⚠️  Skipped (EOS-specific): $STATS_EOS_ONLY${NC}"
    log "${BLUE}🔄 AUR packages: $STATS_AUR_ONLY${NC}"
    log "${BLUE}ℹ️  Total processed: $total_packages${NC}"
    log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Save report to file
    cat > "$REPORT_FILE" << EOF
Enhanced Restore Script Report
Generated: $(date)
System: $(detect_system)

Installation Summary:
- Successfully installed: $STATS_SUCCESS
- Failed to install: $STATS_FAILED
- Skipped (EOS-specific): $STATS_EOS_ONLY
- AUR packages: $STATS_AUR_ONLY
- Total processed: $total_packages

For detailed logs, see: $LOG_FILE
EOF
    
    log_info "Detailed report saved to: $REPORT_FILE"
    log_info "Installation logs saved to: $LOG_FILE"
}

# Main restore function
enhanced_restore() {
    local dryrun="${1:-}"
    
    log_header "🚀 Enhanced Package Restore Script"
    log_info "Starting enhanced restore process..."
    
    # System detection
    local system_type
    system_type=$(detect_system)
    log_info "Detected system: $system_type"
    
    # Pre-flight checks
    validate_repositories || {
        log_error "Repository validation failed. Please fix pacman.conf and try again."
        return 1
    }
    
    # Generate compatibility-specific package lists
    generate_compatibility_lists "$system_type" || return 1
    
    if [[ "$dryrun" == "--dry-run" ]]; then
        log_header "🔍 Dry Run Mode"
        log_info "Packages that would be installed:"
        log_info "Official: $(wc -l < "$PKGLIST_VANILLA") packages"
        log_info "AUR: $(wc -l < "$AURLIST_VANILLA") packages"
        return 0
    fi
    
    # Installation process
    install_official_packages
    install_aur_packages
    
    # Verification
    verify_installations
    
    # Generate report
    generate_report
    
    log_success "Enhanced restore process completed"
}

# Legacy functions for compatibility
backup() {
    log_error "Backup functionality removed. Use original script for backup."
    return 1
}

restore() {
    enhanced_restore
}

# Main execution
case "${1:-}" in
    backup) backup ;;
    restore) enhanced_restore ;;
    restore-dry) enhanced_restore --dry-run ;;
    enhanced) enhanced_restore ;;
    enhanced-dry) enhanced_restore --dry-run ;;
    *) 
        echo "Usage: $0 {restore|restore-dry|enhanced|enhanced-dry}"
        echo "  restore/dry-run: Use original restore logic"
        echo "  enhanced/enhanced-dry: Use new enhanced restore logic"
        exit 1
        ;;
esac