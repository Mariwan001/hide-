#!/bin/bash

# HIDE - Invisible File/Folder Management System
# Version: 1.0.0
# A system for creating and managing completely invisible files and folders

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Base directory for hidden storage (completely hidden location)
HIDE_BASE="$HOME/.local/.cache/.system"
HIDE_STORAGE="$HIDE_BASE/.storage"
HIDE_REGISTRY="$HIDE_BASE/.registry.enc"
HIDE_TEMP="$HIDE_BASE/.temp"
HIDE_NOTEPAD_DIR="$HIDE_BASE/.notepad"

# Initialize the hide system
init_hide_system() {
    if [ ! -d "$HIDE_BASE" ]; then
        mkdir -p "$HIDE_BASE"
        chattr +i "$HIDE_BASE" 2>/dev/null || true
    fi
    
    if [ ! -d "$HIDE_STORAGE" ]; then
        mkdir -p "$HIDE_STORAGE"
    fi
    
    if [ ! -d "$HIDE_TEMP" ]; then
        mkdir -p "$HIDE_TEMP"
    fi
    
    if [ ! -d "$HIDE_NOTEPAD_DIR" ]; then
        mkdir -p "$HIDE_NOTEPAD_DIR"
    fi
    
    if [ ! -f "$HIDE_REGISTRY" ]; then
        echo "[]" | base64 > "$HIDE_REGISTRY"
    fi
}

# Encode/Decode registry (simple base64 encryption)
encode_registry() {
    echo "$1" | base64
}

decode_registry() {
    echo "$1" | base64 -d
}

# Read registry
read_registry() {
    if [ -f "$HIDE_REGISTRY" ]; then
        decode_registry "$(cat "$HIDE_REGISTRY")"
    else
        echo "[]"
    fi
}

# Write registry
write_registry() {
    encode_registry "$1" > "$HIDE_REGISTRY"
}

# Generate unique ID
generate_id() {
    echo "$(date +%s)_$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
}

# Add entry to registry
add_to_registry() {
    local name="$1"
    local type="$2"
    local editor="$3"
    local hidden_path="$4"
    local locked="${5:-false}"
    local password="${6:-}"
    
    local registry=$(read_registry)
    local id=$(generate_id)
    
    local entry="{\"id\":\"$id\",\"name\":\"$name\",\"type\":\"$type\",\"editor\":\"$editor\",\"path\":\"$hidden_path\",\"locked\":$locked,\"password\":\"$password\",\"created\":\"$(date)\"}"
    
    if [ "$registry" = "[]" ]; then
        registry="[$entry]"
    else
        registry="${registry%]},${entry}]"
    fi
    
    write_registry "$registry"
    echo "$id"
}

# Get entry from registry
get_from_registry() {
    local name="$1"
    local registry=$(read_registry)
    
    echo "$registry" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for item in data:
        if item['name'] == '$name':
            print(json.dumps(item))
            sys.exit(0)
except:
    pass
"
}

# Remove entry from registry
remove_from_registry() {
    local name="$1"
    local registry=$(read_registry)
    
    local new_registry=$(echo "$registry" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    filtered = [item for item in data if item['name'] != '$name']
    print(json.dumps(filtered))
except:
    print('[]')
")
    
    write_registry "$new_registry"
}

# Update entry in registry
update_registry_entry() {
    local old_name="$1"
    local new_name="$2"
    local registry=$(read_registry)
    
    local new_registry=$(echo "$registry" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for item in data:
        if item['name'] == '$old_name':
            item['name'] = '$new_name'
    print(json.dumps(data))
except:
    print('[]')
")
    
    write_registry "$new_registry"
}

# Lock entry in registry
lock_registry_entry() {
    local name="$1"
    local password="$2"
    local registry=$(read_registry)
    
    local hashed_password=$(echo -n "$password" | sha256sum | awk '{print $1}')
    
    local new_registry=$(echo "$registry" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for item in data:
        if item['name'] == '$name':
            item['locked'] = True
            item['password'] = '$hashed_password'
    print(json.dumps(data))
except:
    print('[]')
")
    
    write_registry "$new_registry"
}

# Check password
check_password() {
    local name="$1"
    local password="$2"
    local entry=$(get_from_registry "$name")
    
    if [ -z "$entry" ]; then
        return 1
    fi
    
    local stored_hash=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin).get('password', ''))")
    local input_hash=$(echo -n "$password" | sha256sum | awk '{print $1}')
    
    [ "$stored_hash" = "$input_hash" ]
}

# Create hidden item
create_hidden_item() {
    echo -e "${CYAN}What do you want to hide?${NC}"
    echo "1) File"
    echo "2) Folder"
    read -p "Choose (1 or 2): " choice
    
    case $choice in
        1) local type="file" ;;
        2) local type="folder" ;;
        *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
    esac
    
    echo -e "${CYAN}Editor type:${NC}"
    echo "1) nano (text editor)"
    echo "2) normal (hidden notepad)"
    read -p "Choose (1 or 2): " editor_choice
    
    case $editor_choice in
        1) local editor="nano" ;;
        2) local editor="normal" ;;
        *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
    esac
    
    read -p "Enter name: " name
    
    if [ -z "$name" ]; then
        echo -e "${RED}Name cannot be empty${NC}"
        exit 1
    fi
    
    # Check if already exists
    if [ -n "$(get_from_registry "$name")" ]; then
        echo -e "${RED}Item '$name' already exists${NC}"
        exit 1
    fi
    
    # Generate hidden path
    local hidden_id=$(generate_id)
    local hidden_path="$HIDE_STORAGE/$hidden_id"
    
    if [ "$type" = "file" ]; then
        touch "$hidden_path"
    else
        mkdir -p "$hidden_path"
    fi
    
    # Add to registry
    add_to_registry "$name" "$type" "$editor" "$hidden_path" "false" ""
    
    echo -e "${GREEN}✓ Hidden $type '$name' created successfully${NC}"
    echo -e "${YELLOW}Use 'hide open $name' to access it${NC}"
}

# List hidden items
list_hidden_items() {
    local filter="$1"
    local registry=$(read_registry)
    
    if [ "$registry" = "[]" ]; then
        echo -e "${YELLOW}No hidden items found${NC}"
        return
    fi
    
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           HIDDEN ITEMS REGISTRY                            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo "$registry" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    filter_type = '$filter'
    
    for item in data:
        if filter_type == 'all' or item['type'] == filter_type:
            locked = '🔒' if item.get('locked', False) else '🔓'
            print(f\"  {locked} {item['name']}\")
            print(f\"     Type: {item['type']}\")
            print(f\"     Editor: {item['editor']}\")
            print(f\"     Created: {item['created']}\")
            print()
except Exception as e:
    print(f'Error: {e}')
"
}

# Show hidden item location
show_hidden_item() {
    local name="$1"
    local entry=$(get_from_registry "$name")
    
    if [ -z "$entry" ]; then
        echo -e "${RED}Item '$name' not found${NC}"
        exit 1
    fi
    
    # Check if locked
    local is_locked=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin).get('locked', False))")
    
    if [ "$is_locked" = "True" ]; then
        echo -e "${RED}Item '$name' is locked. Use 'hide enterKey $name' to unlock${NC}"
        exit 1
    fi
    
    local path=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin)['path'])")
    
    echo -e "${GREEN}Hidden location: ${BLUE}$path${NC}"
}

# Open hidden item
open_hidden_item() {
    local name="$1"
    local entry=$(get_from_registry "$name")
    
    if [ -z "$entry" ]; then
        echo -e "${RED}Item '$name' not found${NC}"
        exit 1
    fi
    
    # Check if locked
    local is_locked=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin).get('locked', False))")
    
    if [ "$is_locked" = "True" ]; then
        echo -e "${RED}Item '$name' is locked. Use 'hide enterKey $name' to unlock${NC}"
        exit 1
    fi
    
    local path=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin)['path'])")
    local type=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin)['type'])")
    local editor=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin)['editor'])")
    
    if [ "$type" = "file" ]; then
        if [ "$editor" = "nano" ]; then
            nano "$path"
        else
            # Open in hidden notepad
            hide-notepad "$path"
        fi
    else
        cd "$path" && bash
        echo -e "${GREEN}Exited from hidden folder${NC}"
    fi
}

# Delete hidden item
delete_hidden_item() {
    local name="$1"
    local force="$2"
    local entry=$(get_from_registry "$name")
    
    if [ -z "$entry" ]; then
        echo -e "${RED}Item '$name' not found${NC}"
        exit 1
    fi
    
    local path=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin)['path'])")
    local type=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin)['type'])")
    
    if [ "$type" = "folder" ] && [ "$force" != "-f" ]; then
        echo -e "${RED}Cannot delete folder without -f flag${NC}"
        exit 1
    fi
    
    rm -rf "$path"
    remove_from_registry "$name"
    
    echo -e "${GREEN}✓ Hidden item '$name' deleted${NC}"
}

# Rename hidden item
rename_hidden_item() {
    local old_name="$1"
    local new_name="$2"
    
    if [ -z "$old_name" ] || [ -z "$new_name" ]; then
        echo -e "${RED}Usage: hide rename <old_name> <new_name>${NC}"
        exit 1
    fi
    
    local entry=$(get_from_registry "$old_name")
    
    if [ -z "$entry" ]; then
        echo -e "${RED}Item '$old_name' not found${NC}"
        exit 1
    fi
    
    if [ -n "$(get_from_registry "$new_name")" ]; then
        echo -e "${RED}Item '$new_name' already exists${NC}"
        exit 1
    fi
    
    update_registry_entry "$old_name" "$new_name"
    
    echo -e "${GREEN}✓ Renamed '$old_name' to '$new_name'${NC}"
}

# Lock item with password
lock_item() {
    local name="$1"
    local entry=$(get_from_registry "$name")
    
    if [ -z "$entry" ]; then
        echo -e "${RED}Item '$name' not found${NC}"
        exit 1
    fi
    
    read -sp "Enter password: " password
    echo
    read -sp "Confirm password: " password2
    echo
    
    if [ "$password" != "$password2" ]; then
        echo -e "${RED}Passwords do not match${NC}"
        exit 1
    fi
    
    lock_registry_entry "$name" "$password"
    
    echo -e "${GREEN}✓ Item '$name' locked${NC}"
}

# Enter with key
enter_with_key() {
    local name="$1"
    local entry=$(get_from_registry "$name")
    
    if [ -z "$entry" ]; then
        echo -e "${RED}Item '$name' not found${NC}"
        exit 1
    fi
    
    local is_locked=$(echo "$entry" | python3 -c "import sys, json; print(json.load(sys.stdin).get('locked', False))")
    
    if [ "$is_locked" != "True" ]; then
        echo -e "${YELLOW}Item '$name' is not locked${NC}"
        open_hidden_item "$name"
        return
    fi
    
    read -sp "Enter password: " password
    echo
    
    if check_password "$name" "$password"; then
        echo -e "${GREEN}✓ Password correct${NC}"
        open_hidden_item "$name"
    else
        echo -e "${RED}✗ Incorrect password${NC}"
        exit 1
    fi
}

# Open hidden notepad
open_notepad() {
    local name="${1:-untitled}"
    local notepad_file="$HIDE_NOTEPAD_DIR/${name}.txt"
    
    hide-notepad "$notepad_file"
}

# Show help
show_help() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    HIDE COMMAND HELP                       ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}CREATE:${NC}"
    echo -e "  ${YELLOW}hide${NC}                          Create new hidden file/folder"
    echo ""
    echo -e "${GREEN}LIST:${NC}"
    echo -e "  ${YELLOW}hide ls file${NC}                  List all hidden files"
    echo -e "  ${YELLOW}hide ls folder${NC}                List all hidden folders"
    echo -e "  ${YELLOW}hide ls all${NC}                   List all hidden items"
    echo ""
    echo -e "${GREEN}ACCESS:${NC}"
    echo -e "  ${YELLOW}hide show <name>${NC}              Show hidden item location"
    echo -e "  ${YELLOW}hide open <name>${NC}              Open hidden item"
    echo -e "  ${YELLOW}hide notepad <name>${NC}           Open hidden notepad"
    echo ""
    echo -e "${GREEN}MANAGE:${NC}"
    echo -e "  ${YELLOW}hide delete <name>${NC}            Delete hidden file"
    echo -e "  ${YELLOW}hide delete -f <name>${NC}         Delete hidden folder (force)"
    echo -e "  ${YELLOW}hide rename <old> <new>${NC}       Rename hidden item"
    echo ""
    echo -e "${GREEN}SECURITY:${NC}"
    echo -e "  ${YELLOW}hide key <name>${NC}               Lock item with password"
    echo -e "  ${YELLOW}hide enterKey <name>${NC}          Unlock and open item"
    echo ""
    echo -e "${GREEN}INFO:${NC}"
    echo -e "  ${YELLOW}hide help${NC}                     Show this help"
    echo ""
}

# Main command handler
main() {
    init_hide_system
    
    if [ $# -eq 0 ]; then
        create_hidden_item
        exit 0
    fi
    
    case "$1" in
        ls)
            if [ "$2" = "file" ]; then
                list_hidden_items "file"
            elif [ "$2" = "folder" ]; then
                list_hidden_items "folder"
            elif [ "$2" = "all" ]; then
                list_hidden_items "all"
            else
                echo -e "${RED}Usage: hide ls [file|folder|all]${NC}"
                exit 1
            fi
            ;;
        show)
            show_hidden_item "$2"
            ;;
        open)
            open_hidden_item "$2"
            ;;
        delete)
            if [ "$2" = "-f" ]; then
                delete_hidden_item "$3" "-f"
            else
                delete_hidden_item "$2" ""
            fi
            ;;
        rename)
            rename_hidden_item "$2" "$3"
            ;;
        key)
            lock_item "$2"
            ;;
        enterKey)
            enter_with_key "$2"
            ;;
        notepad)
            open_notepad "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}Unknown command: $1${NC}"
            echo -e "${YELLOW}Use 'hide help' for usage information${NC}"
            exit 1
            ;;
    esac
}

main "$@"
