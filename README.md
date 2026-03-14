
# OS_Coursework - Operating Systems Assignments

A comprehensive collection of OS coursework assignments covering system programming, process management, synchronization, file I/O buffering, threading, and file operations.

---

## **Exercise 1: xv6 System Call Implementation & Chess Simulator**

### Part 1: Adding `memsize` System Call to xv6

**Objective**: Implement a new system call that returns the current memory usage of a process in the xv6 operating system.

#### Key Learning: System call interface between user and kernel space

---

### Part 2: Interactive Chess Simulator in Bash

**Objective**: Build a Bash script that parses and replays chess games from PGN files with interactive controls.

#### Key Components:
**Bash Chess Simulator** (`chess_sim.sh`)

**Core Data Structure: 2D Array Board**
```bash
board[$row,$col]="piece_symbol"
# Pieces: R(ook), N(ight), B(ishop), Q(ueen), K(ing), P(awn)
# Uppercase = White, Lowercase = Black
```

**Key Functions**:
- `initialize_board()` - Sets up chess starting position
- `print_board()` - Displays 8×8 grid with current move count
- `d_function()` - Moves forward through game
- `print_pgn_header()` - Displays game metadata (players, date, etc.)

**Interactive Controls**:
- **'d'** - Next move (advance to next position in game)
- **'a'** - Previous move (undo last move)
- **'w'** - Go to start (reset to initial position)
- **'s'** - Go to end (jump to final position)
- **'q'** - Quit

**Move Mechanics**:
- Parses UCI moves (e.g., `e2e4` = move from e2 to e4)
- Updates 2D board array with piece positions
- Tracks move history for forward/backward navigation

#### Key Learning: Shell scripting, file parsing, game state management

---

## **Exercise 2: Process Management & Buffered I/O**

### Part 1: Multi-Process File Writing

**Objective**: Implement concurrent process writes to a shared file using fork/wait pattern.

**Key Concepts**:
- Parent-child process hierarchy
- Process synchronization with `waitpid()`
- Shared file descriptors
- Write ordering (timing-dependent)

---

### Part 2: Synchronization with File Locks

**Objective**: Implement mutual exclusion for concurrent writers using file-based locking.

**Mechanism**:
- `O_EXCL` flag ensures atomic lock creation
- Returns error if lock file already exists
- Spin-lock with sleep (100µs) prevents CPU thrashing
- Guarantees mutual exclusion between processes

---

### Part 3: Custom Buffered I/O Library

**Objective**: Implement a buffering layer that wraps POSIX I/O with configurable buffer sizes and special flags.

#### Key Features:

**1. Buffered Write** (`buffered_write`)
- Accumulates data in write buffer
- Auto-flushes when buffer fills (4KB default)
- Supports manual flush via `buffered_flush()`
- Tracks file offset for non-sequential access

**2. Buffered Read** (`buffered_read`)
- Pre-fills read buffer on first read
- Returns data from buffer before disk I/O
- Auto-refills when buffer exhausted
- Flushes write buffer on switch to read mode

**3. Custom Flag: O_PREAPPEND**
- Seeks to beginning before first write
- Allows "prepending" content to existing files
- New data placed at file start, old content follows

#### Key Learning: I/O optimization, buffer management, state tracking

---

## **Exercise 3: Concurrent Programming with Threads**

**Objective**: Implement a producer-consumer pattern with synchronized access to shared resources.

### Architecture:

**1. BoundedBuffer** (Thread-safe queue)
```cpp
class BoundedBuffer {
    mutex lock;
    condition_variable full, empty;
    queue<T> buffer;
    size_t capacity;
};
```
- Protects access with mutex
- Uses condition variables for blocking I/O
- Signals on full/empty transitions

**2. Producer Threads**
- Generate items and insert into buffer
- Blocks if buffer is full
- Signals consumers when items available

**3. Consumer Threads** (Dispatcher)
- Extract items from buffer
- Process according to consumer behavior
- Block if buffer empty

**4. Screen Manager** (ScrManager)
- Synchronized output to terminal
- Prevents interleaved writes

### Configuration (`config.txt`):
- Number of producers/consumers
- Buffer capacity
- Item generation/processing rates

#### Key Learning: Mutexes, condition variables, thread synchronization

---

## **Exercise 4: Advanced Process and File Management**

### Structure:
- **part1/** - Socket programming or IPC
- **part2/** - Advanced file operations or network protocols
- **/part1_submit/** & **/part2_submit/** - Submission-ready code

---

## **Exercise 5: Recursive Directory Tree Operations**

**Objective**: Implement a `copytree` utility that recursively copies directory structures with optional features.

### Features:

**1. Basic Recursive Copy**
```c
copytree source_dir dest_dir
```
- Recursively copies all files and directories
- Creates destination structure
- Copies file contents

**2. Symbolic Link Support** (`-l` flag)
```c
copytree -l source_dir dest_dir
```
- Preserves symbolic links instead of following them
- Reconstructs symlink targets in destination

**3. Permission Preservation** (`-p` flag)
```c
copytree -p source_dir dest_dir
```
- Copies file/directory permissions using `chmod`
- Preserves original access modes (rwx bits)
- Can be combined: `copytree -l -p src dst`

### Implementation Details:

**Directory Traversal** (`copytree.c`):
- Uses `opendir()/readdir()` for directory iteration
- Recursively processes subdirectories
- Handles symlinks via `readlink()`

**File Operations** (`part3.c`):
- `stat()` to read file metadata and permissions
- `open()` with mode flags for file creation
- `read()/write()` for content copying
- `symlink()` to create symbolic links


#### Key Learning: Directory traversal, metadata manipulation, recursive algorithms, testing frameworks


---

## **Key OS Concepts Covered**

✅ **System Calls** - Implementing kernel interfaces  
✅ **Process Management** - Fork, exec, wait, exit  
✅ **Synchronization** - Locks, mutexes, condition variables  
✅ **File I/O** - Buffering, descriptors, permissions  
✅ **Concurrency** - Threads, producer-consumer patterns  
✅ **Shell Programming** - Bash scripting, parsing  
✅ **Data Structures** - Queues, state machines  

