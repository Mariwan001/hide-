# 🔒 HIDE - Invisible File/Folder Management System

**Version:** 1.0.0  
**License:** MIT  
**Platform:** Linux (Bash)

A production-ready command-line system that creates and manages completely invisible files and folders that cannot be detected by standard Linux tools like `ls`, `find`, `tree`, etc.

---

## 🌟 Features

- ✅ **Truly Invisible**: Files/folders stored in hidden locations unreachable by standard tools
- 🔐 **Password Protection**: Lock items with encrypted passwords
- 📝 **Dual Editor Support**: Use nano or built-in hidden notepad
- 📋 **Encrypted Registry**: All metadata encrypted in base64
- 🗂️ **Full Management**: Create, list, open, rename, delete operations
- 🔍 **Smart Access Control**: Password-protected entry system
- 💾 **Persistent Storage**: All hidden items survive reboots
- 🎯 **Zero Dependencies**: Only requires Python3 and base64 (standard on most Linux)

---

## 🚀 Installation

### Quick Install from GitHub
```bash
# Clone the repository
git clone https://github.com/Mariwan001/hide.git
cd hide

# Install
chmod +x install.sh
sudo ./install.sh
```

### Manual Installation
```bash
# Make scripts executable
chmod +x hide
chmod +x hide-notepad

# Copy to system path
sudo cp hide /usr/local/bin/
sudo cp hide-notepad /usr/local/bin/
```

---

## 📖 Complete Command Reference

### **CREATE**

#### `hide`
Create a new hidden file or folder interactively.

**Example:**
```bash
$ hide
What do you want to hide?
1) File
2) Folder
Choose (1 or 2): 1
Editor type:
1) nano (text editor)
2) normal (hidden notepad)
Choose (1 or 2): 2
Enter name: secret_notes
✓ Hidden file 'secret_notes' created successfully
```

---

### **LIST**

#### `hide ls file`
List all hidden files.

#### `hide ls folder`
List all hidden folders.

#### `hide ls all`
List all hidden items (files and folders).
```bash
$ hide ls all
╔════════════════════════════════════════════════════════════╗
║           HIDDEN ITEMS REGISTRY                            ║
╚════════════════════════════════════════════════════════════╝

  🔓 secret_notes
     Type: file
     Editor: normal
     Created: Sun Dec  7 10:30:45 2025
```

---

### **ACCESS**

#### `hide show <name>`
Display the actual hidden storage location of an item.
```bash
$ hide show secret_notes
Hidden location: /home/user/.local/.cache/.system/.storage/1733571045_aB3dF9kL2pQr5tXy
```

#### `hide open <name>`
Open a hidden item:
- For **nano** files: Opens in nano editor
- For **normal** files: Opens in hidden notepad
- For **folders**: Opens a bash shell in that directory
```bash
$ hide open secret_notes
[Opens in hidden notepad]
```

#### `hide notepad <name>`
Open the hidden notepad with optional name.
```bash
$ hide notepad mynotes
[Opens hidden notepad]
```

---

### **MANAGE**

#### `hide delete <name>`
Delete a hidden file.
```bash
$ hide delete secret_notes
✓ Hidden item 'secret_notes' deleted
```

#### `hide delete -f <name>`
Force delete a hidden folder (even if not empty).
```bash
$ hide delete -f secret_project
✓ Hidden item 'secret_project' deleted
```

#### `hide rename <old_name> <new_name>`
Rename a hidden item.
```bash
$ hide rename secret_notes private_notes
✓ Renamed 'secret_notes' to 'private_notes'
```

---

### **SECURITY**

#### `hide key <name>`
Lock an item with password protection.
```bash
$ hide key passwords
Enter password: 
Confirm password: 
✓ Item 'passwords' locked
```

#### `hide enterKey <name>`
Unlock and open a password-protected item.
```bash
$ hide enterKey passwords
Enter password: 
✓ Password correct
[Opens the item]
```

---

### **INFO**

#### `hide help`
Display complete help information.

---

## 🏗️ System Architecture

### Storage Structure
