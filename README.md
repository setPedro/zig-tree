# zig-tree

Lightweight tool for displaying directory structures in a simple, readable format

## Installation

Clone the repository:

```sh
git clone https://github.com/setPedro/zig-tree.git
cd zig-tree
```

Build and install:

### Unix-like Systems

```sh
zig build-exe src/main.zig -O ReleaseSmall --name ztree
sudo mv ztree /usr/local/bin/
sudo chmod +x /usr/local/bin/ztree
```

These commands:

1. Compile your program into an executable named ztree
2. Move it to a system-wide directory (/usr/local/bin/)
3. Make it executable

### Windows

```sh
zig build-exe src/main.zig -O ReleaseSmall --name ztree.exe
```

After building, either:

1. Move `ztree.exe` to a directory in your system PATH
2. Or add the directory containing `ztree.exe` to your PATH environment variable

---

Once installed, you can use `ztree` from anywhere.

## Usage

- Display the current directory structure:  
  `ztree`

- Display a specific directory:  
  `ztree <path>`
