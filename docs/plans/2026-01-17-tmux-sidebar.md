# tmux-sidebar Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a lightweight, interactive file tree sidebar for tmux with git integration, vim-style navigation, and auto-sync to the active pane's working directory.

**Architecture:** Rust binary using ratatui for the TUI, `notify` for filesystem watching, `git2` for git status. A shell toggle script manages the tmux pane lifecycle. The sidebar communicates with tmux to detect the sibling pane's PWD and sends keys to open files.

**Tech Stack:** Rust, ratatui, crossterm, notify, git2, tmux

---

## Project Structure

```
~/.config/scripts/tmux-sidebar/
├── Cargo.toml
├── src/
│   ├── main.rs           # Entry point, tmux integration
│   ├── app.rs            # Application state
│   ├── ui.rs             # Ratatui rendering
│   ├── tree.rs           # File tree data structure
│   ├── git.rs            # Git status integration
│   └── watcher.rs        # File system watcher
└── toggle.sh             # Tmux toggle script
```

---

### Task 1: Project Scaffolding

**Files:**
- Create: `~/.config/scripts/tmux-sidebar/Cargo.toml`
- Create: `~/.config/scripts/tmux-sidebar/src/main.rs`

**Step 1: Create Cargo.toml**

```toml
[package]
name = "tmux-sidebar"
version = "0.1.0"
edition = "2021"

[dependencies]
ratatui = "0.29"
crossterm = "0.28"
git2 = "0.19"
notify = "7.0"
notify-debouncer-mini = "0.5"
anyhow = "1.0"
walkdir = "2.5"
ignore = "0.4"

[profile.release]
opt-level = "z"
lto = true
strip = true
```

**Step 2: Create minimal main.rs**

```rust
use std::io;
use anyhow::Result;

fn main() -> Result<()> {
    println!("tmux-sidebar starting...");
    Ok(())
}
```

**Step 3: Build to verify setup**

Run: `cd ~/.config/scripts/tmux-sidebar && cargo build --release`
Expected: Compiles successfully

**Step 4: Commit**

```bash
git add ~/.config/scripts/tmux-sidebar/
git commit -m "feat(tmux-sidebar): scaffold rust project"
```

---

### Task 2: File Tree Data Structure

**Files:**
- Create: `~/.config/scripts/tmux-sidebar/src/tree.rs`
- Modify: `~/.config/scripts/tmux-sidebar/src/main.rs`

**Step 1: Create tree.rs with FileNode struct**

```rust
use std::path::{Path, PathBuf};
use std::fs;
use std::cmp::Ordering;

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum GitStatus {
    Modified,
    Added,
    Deleted,
    Untracked,
    None,
}

#[derive(Debug, Clone)]
pub struct FileNode {
    pub name: String,
    pub path: PathBuf,
    pub is_dir: bool,
    pub expanded: bool,
    pub children: Vec<FileNode>,
    pub git_status: GitStatus,
    pub depth: usize,
}

impl FileNode {
    pub fn new(path: PathBuf, depth: usize) -> Self {
        let name = path
            .file_name()
            .map(|n| n.to_string_lossy().to_string())
            .unwrap_or_else(|| path.to_string_lossy().to_string());
        let is_dir = path.is_dir();

        Self {
            name,
            path,
            is_dir,
            expanded: false,
            children: Vec::new(),
            git_status: GitStatus::None,
            depth,
        }
    }

    pub fn load_children(&mut self) {
        if !self.is_dir || !self.children.is_empty() {
            return;
        }

        let Ok(entries) = fs::read_dir(&self.path) else {
            return;
        };

        let mut children: Vec<FileNode> = entries
            .filter_map(|e| e.ok())
            .filter(|e| {
                !e.file_name()
                    .to_string_lossy()
                    .starts_with('.')
            })
            .map(|e| FileNode::new(e.path(), self.depth + 1))
            .collect();

        children.sort_by(|a, b| {
            match (a.is_dir, b.is_dir) {
                (true, false) => Ordering::Less,
                (false, true) => Ordering::Greater,
                _ => a.name.to_lowercase().cmp(&b.name.to_lowercase()),
            }
        });

        self.children = children;
    }

    pub fn clear_children(&mut self) {
        self.children.clear();
        self.expanded = false;
    }
}

#[derive(Debug)]
pub struct FileTree {
    pub root: FileNode,
    pub flat_list: Vec<usize>,  // indices into a flattened view
}

impl FileTree {
    pub fn new(root_path: PathBuf) -> Self {
        let mut root = FileNode::new(root_path, 0);
        root.expanded = true;
        root.load_children();

        Self {
            root,
            flat_list: Vec::new(),
        }
    }

    pub fn flatten(&self) -> Vec<&FileNode> {
        let mut result = Vec::new();
        self.flatten_node(&self.root, &mut result);
        result
    }

    fn flatten_node<'a>(&'a self, node: &'a FileNode, result: &mut Vec<&'a FileNode>) {
        // Skip root itself, show only children
        if node.depth == 0 {
            for child in &node.children {
                self.flatten_node(child, result);
            }
        } else {
            result.push(node);
            if node.expanded {
                for child in &node.children {
                    self.flatten_node(child, result);
                }
            }
        }
    }

    pub fn get_node_mut(&mut self, path: &Path) -> Option<&mut FileNode> {
        self.find_node_mut(&mut self.root, path)
    }

    fn find_node_mut<'a>(&'a mut self, node: &'a mut FileNode, path: &Path) -> Option<&mut FileNode> {
        if node.path == path {
            return Some(node);
        }
        for child in &mut node.children {
            if path.starts_with(&child.path) {
                return Self::find_node_mut_inner(child, path);
            }
        }
        None
    }

    fn find_node_mut_inner(node: &mut FileNode, path: &Path) -> Option<&mut FileNode> {
        if node.path == path {
            return Some(node);
        }
        for child in &mut node.children {
            if path.starts_with(&child.path) {
                return Self::find_node_mut_inner(child, path);
            }
        }
        None
    }

    pub fn reload(&mut self, root_path: PathBuf) {
        let mut root = FileNode::new(root_path, 0);
        root.expanded = true;
        root.load_children();
        self.root = root;
    }
}
```

**Step 2: Update main.rs to use tree module**

```rust
mod tree;

use std::io;
use std::path::PathBuf;
use anyhow::Result;
use tree::FileTree;

fn main() -> Result<()> {
    let cwd = std::env::current_dir()?;
    let tree = FileTree::new(cwd);

    for node in tree.flatten() {
        let indent = "  ".repeat(node.depth.saturating_sub(1));
        let icon = if node.is_dir { "📁" } else { "📄" };
        println!("{}{} {}", indent, icon, node.name);
    }

    Ok(())
}
```

**Step 3: Build and test**

Run: `cd ~/.config/scripts/tmux-sidebar && cargo run --release`
Expected: Prints current directory tree

**Step 4: Commit**

```bash
git add ~/.config/scripts/tmux-sidebar/
git commit -m "feat(tmux-sidebar): add file tree data structure"
```

---

### Task 3: Git Integration

**Files:**
- Create: `~/.config/scripts/tmux-sidebar/src/git.rs`
- Modify: `~/.config/scripts/tmux-sidebar/src/tree.rs`

**Step 1: Create git.rs**

```rust
use std::collections::HashMap;
use std::path::{Path, PathBuf};
use git2::{Repository, StatusOptions};
use crate::tree::GitStatus;

pub struct GitInfo {
    pub statuses: HashMap<PathBuf, GitStatus>,
    pub repo_root: Option<PathBuf>,
}

impl GitInfo {
    pub fn new(path: &Path) -> Self {
        let mut info = Self {
            statuses: HashMap::new(),
            repo_root: None,
        };

        let Ok(repo) = Repository::discover(path) else {
            return info;
        };

        info.repo_root = repo.workdir().map(|p| p.to_path_buf());

        let mut opts = StatusOptions::new();
        opts.include_untracked(true)
            .recurse_untracked_dirs(true);

        let Ok(statuses) = repo.statuses(Some(&mut opts)) else {
            return info;
        };

        for entry in statuses.iter() {
            let Some(path_str) = entry.path() else { continue };
            let status = entry.status();

            let full_path = if let Some(ref root) = info.repo_root {
                root.join(path_str)
            } else {
                PathBuf::from(path_str)
            };

            let git_status = if status.is_wt_new() || status.is_index_new() {
                GitStatus::Added
            } else if status.is_wt_modified() || status.is_index_modified() {
                GitStatus::Modified
            } else if status.is_wt_deleted() || status.is_index_deleted() {
                GitStatus::Deleted
            } else {
                GitStatus::None
            };

            if git_status != GitStatus::None {
                info.statuses.insert(full_path, git_status);
            }
        }

        info
    }

    pub fn get_status(&self, path: &Path) -> GitStatus {
        // Check exact match
        if let Some(status) = self.statuses.get(path) {
            return status.clone();
        }

        // For directories, check if any children have status
        if path.is_dir() {
            for (p, status) in &self.statuses {
                if p.starts_with(path) {
                    return status.clone();
                }
            }
        }

        GitStatus::None
    }
}
```

**Step 2: Update tree.rs to apply git status**

Add this method to `FileTree` impl:

```rust
use crate::git::GitInfo;

// Add to FileTree impl
pub fn apply_git_status(&mut self, git_info: &GitInfo) {
    self.apply_git_status_recursive(&mut self.root, git_info);
}

fn apply_git_status_recursive(&self, node: &mut FileNode, git_info: &GitInfo) {
    node.git_status = git_info.get_status(&node.path);
    for child in &mut node.children {
        self.apply_git_status_recursive(child, git_info);
    }
}
```

**Step 3: Update main.rs to show git status**

```rust
mod tree;
mod git;

use std::path::PathBuf;
use anyhow::Result;
use tree::FileTree;
use git::GitInfo;

fn main() -> Result<()> {
    let cwd = std::env::current_dir()?;
    let mut tree = FileTree::new(cwd.clone());
    let git_info = GitInfo::new(&cwd);
    tree.apply_git_status(&git_info);

    for node in tree.flatten() {
        let indent = "  ".repeat(node.depth.saturating_sub(1));
        let icon = if node.is_dir { "▸" } else { " " };
        let status = match node.git_status {
            tree::GitStatus::Modified => " M",
            tree::GitStatus::Added => " A",
            tree::GitStatus::Deleted => " D",
            _ => "  ",
        };
        println!("{}{} {}{}", indent, icon, node.name, status);
    }

    Ok(())
}
```

**Step 4: Build and test in a git repo**

Run: `cd ~/.config/scripts/tmux-sidebar && cargo run --release`
Expected: Shows M/A/D markers next to changed files

**Step 5: Commit**

```bash
git add ~/.config/scripts/tmux-sidebar/
git commit -m "feat(tmux-sidebar): add git status integration"
```

---

### Task 4: Application State

**Files:**
- Create: `~/.config/scripts/tmux-sidebar/src/app.rs`

**Step 1: Create app.rs**

```rust
use std::path::PathBuf;
use crate::tree::{FileTree, FileNode};
use crate::git::GitInfo;

pub struct App {
    pub tree: FileTree,
    pub git_info: GitInfo,
    pub cursor: usize,
    pub root_path: PathBuf,
    pub sibling_pane: Option<String>,
    pub should_quit: bool,
}

impl App {
    pub fn new(root_path: PathBuf, sibling_pane: Option<String>) -> Self {
        let mut tree = FileTree::new(root_path.clone());
        let git_info = GitInfo::new(&root_path);
        tree.apply_git_status(&git_info);

        Self {
            tree,
            git_info,
            cursor: 0,
            root_path,
            sibling_pane,
            should_quit: false,
        }
    }

    pub fn visible_items(&self) -> Vec<&FileNode> {
        self.tree.flatten()
    }

    pub fn selected_node(&self) -> Option<&FileNode> {
        self.visible_items().get(self.cursor).copied()
    }

    pub fn move_up(&mut self) {
        if self.cursor > 0 {
            self.cursor -= 1;
        }
    }

    pub fn move_down(&mut self) {
        let max = self.visible_items().len().saturating_sub(1);
        if self.cursor < max {
            self.cursor += 1;
        }
    }

    pub fn expand_or_enter(&mut self) {
        let items = self.visible_items();
        let Some(node) = items.get(self.cursor) else { return };

        if !node.is_dir {
            return;
        }

        let path = node.path.clone();
        if let Some(node) = self.tree.get_node_mut(&path) {
            if node.expanded {
                // Already expanded, go into first child
                if !node.children.is_empty() {
                    self.cursor += 1;
                }
            } else {
                node.load_children();
                node.expanded = true;
                self.git_info = GitInfo::new(&self.root_path);
                self.tree.apply_git_status(&self.git_info);
            }
        }
    }

    pub fn collapse_or_parent(&mut self) {
        let items = self.visible_items();
        let Some(node) = items.get(self.cursor) else { return };

        let path = node.path.clone();

        if node.is_dir && node.expanded {
            // Collapse current
            if let Some(node) = self.tree.get_node_mut(&path) {
                node.clear_children();
            }
        } else {
            // Go to parent
            if let Some(parent) = path.parent() {
                if parent != self.root_path {
                    // Find parent in list
                    for (i, item) in self.visible_items().iter().enumerate() {
                        if item.path == parent {
                            self.cursor = i;
                            break;
                        }
                    }
                }
            }
        }
    }

    pub fn go_to_root(&mut self) {
        self.cursor = 0;
    }

    pub fn reload(&mut self, new_root: Option<PathBuf>) {
        if let Some(path) = new_root {
            self.root_path = path;
        }
        self.tree.reload(self.root_path.clone());
        self.git_info = GitInfo::new(&self.root_path);
        self.tree.apply_git_status(&self.git_info);
        self.cursor = 0;
    }

    pub fn open_selected(&self) {
        let Some(node) = self.selected_node() else { return };
        if node.is_dir { return; }

        let editor = std::env::var("VISUAL")
            .or_else(|_| std::env::var("EDITOR"))
            .unwrap_or_else(|_| "nvim".to_string());

        let path = node.path.to_string_lossy();

        if let Some(ref pane) = self.sibling_pane {
            // Send command to sibling pane
            let _ = std::process::Command::new("tmux")
                .args(["send-keys", "-t", pane, &format!("{} '{}'", editor, path), "Enter"])
                .output();
        }
    }
}
```

**Step 2: Commit**

```bash
git add ~/.config/scripts/tmux-sidebar/src/app.rs
git commit -m "feat(tmux-sidebar): add application state management"
```

---

### Task 5: TUI Rendering

**Files:**
- Create: `~/.config/scripts/tmux-sidebar/src/ui.rs`

**Step 1: Create ui.rs**

```rust
use ratatui::{
    Frame,
    layout::{Constraint, Layout, Rect},
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, List, ListItem, ListState},
};
use crate::app::App;
use crate::tree::GitStatus;

pub fn render(frame: &mut Frame, app: &App) {
    let area = frame.area();

    let items = app.visible_items();

    let list_items: Vec<ListItem> = items
        .iter()
        .enumerate()
        .map(|(i, node)| {
            let indent = "  ".repeat(node.depth.saturating_sub(1));

            let icon = if node.is_dir {
                if node.expanded { "▾ " } else { "▸ " }
            } else {
                "  "
            };

            let (status_char, status_color) = match node.git_status {
                GitStatus::Modified => ("M", Color::Yellow),
                GitStatus::Added => ("A", Color::Green),
                GitStatus::Deleted => ("D", Color::Red),
                GitStatus::Untracked => ("?", Color::Cyan),
                GitStatus::None => (" ", Color::DarkGray),
            };

            let is_selected = i == app.cursor;
            let name_style = if is_selected {
                Style::default().fg(Color::Black).bg(Color::White)
            } else if node.is_dir {
                Style::default().fg(Color::Blue).add_modifier(Modifier::BOLD)
            } else {
                Style::default().fg(Color::White)
            };

            let line = Line::from(vec![
                Span::styled(status_char, Style::default().fg(status_color)),
                Span::raw(" "),
                Span::raw(indent),
                Span::raw(icon),
                Span::styled(&node.name, name_style),
            ]);

            ListItem::new(line)
        })
        .collect();

    let title = app.root_path
        .file_name()
        .map(|n| n.to_string_lossy().to_string())
        .unwrap_or_else(|| "files".to_string());

    let list = List::new(list_items)
        .block(Block::default()
            .borders(Borders::LEFT)
            .border_style(Style::default().fg(Color::DarkGray))
            .title(title));

    let mut state = ListState::default();
    state.select(Some(app.cursor));

    frame.render_stateful_widget(list, area, &mut state);
}
```

**Step 2: Commit**

```bash
git add ~/.config/scripts/tmux-sidebar/src/ui.rs
git commit -m "feat(tmux-sidebar): add TUI rendering"
```

---

### Task 6: File Watcher

**Files:**
- Create: `~/.config/scripts/tmux-sidebar/src/watcher.rs`

**Step 1: Create watcher.rs**

```rust
use std::path::Path;
use std::sync::mpsc::{channel, Receiver};
use std::time::Duration;
use notify_debouncer_mini::{new_debouncer, DebouncedEventKind};
use anyhow::Result;

pub enum WatchEvent {
    FileChanged,
}

pub struct Watcher {
    pub rx: Receiver<WatchEvent>,
    _debouncer: notify_debouncer_mini::Debouncer<notify::RecommendedWatcher>,
}

impl Watcher {
    pub fn new(path: &Path) -> Result<Self> {
        let (tx, rx) = channel();

        let mut debouncer = new_debouncer(
            Duration::from_millis(200),
            move |res: Result<Vec<notify_debouncer_mini::DebouncedEvent>, _>| {
                if let Ok(events) = res {
                    if events.iter().any(|e| e.kind == DebouncedEventKind::Any) {
                        let _ = tx.send(WatchEvent::FileChanged);
                    }
                }
            },
        )?;

        debouncer.watcher().watch(path, notify::RecursiveMode::Recursive)?;

        Ok(Self {
            rx,
            _debouncer: debouncer,
        })
    }
}
```

**Step 2: Commit**

```bash
git add ~/.config/scripts/tmux-sidebar/src/watcher.rs
git commit -m "feat(tmux-sidebar): add file system watcher"
```

---

### Task 7: Main Event Loop

**Files:**
- Modify: `~/.config/scripts/tmux-sidebar/src/main.rs`

**Step 1: Rewrite main.rs with full event loop**

```rust
mod app;
mod git;
mod tree;
mod ui;
mod watcher;

use std::io;
use std::path::PathBuf;
use std::time::Duration;
use std::sync::mpsc::TryRecvError;

use anyhow::Result;
use crossterm::{
    event::{self, Event, KeyCode, KeyModifiers},
    execute,
    terminal::{disable_raw_mode, enable_raw_mode, EnterAlternateScreen, LeaveAlternateScreen},
};
use ratatui::prelude::*;

use app::App;
use watcher::Watcher;

fn get_sibling_pane_pwd(sibling_pane: &str) -> Option<PathBuf> {
    let output = std::process::Command::new("tmux")
        .args(["display-message", "-p", "-t", sibling_pane, "#{pane_current_path}"])
        .output()
        .ok()?;

    let path_str = String::from_utf8_lossy(&output.stdout).trim().to_string();
    if path_str.is_empty() {
        None
    } else {
        Some(PathBuf::from(path_str))
    }
}

fn main() -> Result<()> {
    // Get sibling pane ID from args
    let args: Vec<String> = std::env::args().collect();
    let sibling_pane = args.get(1).cloned();

    // Get initial path
    let initial_path = sibling_pane
        .as_ref()
        .and_then(|p| get_sibling_pane_pwd(p))
        .unwrap_or_else(|| std::env::current_dir().unwrap_or_else(|_| PathBuf::from(".")));

    // Setup terminal
    enable_raw_mode()?;
    let mut stdout = io::stdout();
    execute!(stdout, EnterAlternateScreen)?;
    let backend = CrosstermBackend::new(stdout);
    let mut terminal = Terminal::new(backend)?;

    // Create app and watcher
    let mut app = App::new(initial_path.clone(), sibling_pane.clone());
    let watcher = Watcher::new(&initial_path).ok();

    let mut last_pwd = initial_path;

    // Main loop
    loop {
        // Check for file changes
        if let Some(ref w) = watcher {
            match w.rx.try_recv() {
                Ok(_) => app.reload(None),
                Err(TryRecvError::Empty) => {}
                Err(TryRecvError::Disconnected) => {}
            }
        }

        // Check if sibling pane PWD changed
        if let Some(ref pane) = sibling_pane {
            if let Some(new_pwd) = get_sibling_pane_pwd(pane) {
                if new_pwd != last_pwd {
                    last_pwd = new_pwd.clone();
                    app.reload(Some(new_pwd));
                }
            }
        }

        // Draw
        terminal.draw(|f| ui::render(f, &app))?;

        // Handle input with timeout
        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key) = event::read()? {
                match (key.code, key.modifiers) {
                    (KeyCode::Char('q'), _) | (KeyCode::Esc, _) => {
                        app.should_quit = true;
                    }
                    (KeyCode::Char('j'), _) | (KeyCode::Down, _) => app.move_down(),
                    (KeyCode::Char('k'), _) | (KeyCode::Up, _) => app.move_up(),
                    (KeyCode::Char('l'), _) | (KeyCode::Right, _) | (KeyCode::Enter, _) => {
                        if app.selected_node().map(|n| !n.is_dir).unwrap_or(false) {
                            app.open_selected();
                        } else {
                            app.expand_or_enter();
                        }
                    }
                    (KeyCode::Char('h'), _) | (KeyCode::Left, _) => app.collapse_or_parent(),
                    (KeyCode::Char('H'), KeyModifiers::SHIFT) => app.go_to_root(),
                    (KeyCode::Char('r'), _) => app.reload(None),
                    (KeyCode::Char('g'), _) => app.cursor = 0,
                    (KeyCode::Char('G'), KeyModifiers::SHIFT) => {
                        app.cursor = app.visible_items().len().saturating_sub(1);
                    }
                    _ => {}
                }
            }
        }

        if app.should_quit {
            break;
        }
    }

    // Restore terminal
    disable_raw_mode()?;
    execute!(terminal.backend_mut(), LeaveAlternateScreen)?;

    Ok(())
}
```

**Step 2: Build and test**

Run: `cd ~/.config/scripts/tmux-sidebar && cargo build --release`
Expected: Compiles successfully

**Step 3: Commit**

```bash
git add ~/.config/scripts/tmux-sidebar/
git commit -m "feat(tmux-sidebar): add main event loop with full interactivity"
```

---

### Task 8: Toggle Script

**Files:**
- Create: `~/.config/scripts/tmux-sidebar/toggle.sh`

**Step 1: Create toggle.sh**

```bash
#!/bin/bash
# Toggle tmux-sidebar pane

MAIN_PANE="$1"
SIDEBAR_MARKER="tmux-sidebar"
SIDEBAR_BIN="$HOME/.config/scripts/tmux-sidebar/target/release/tmux-sidebar"

# Find existing sidebar pane in current window
SIDEBAR_PANE=$(tmux list-panes -F '#{pane_id}:#{pane_title}' | grep ":$SIDEBAR_MARKER$" | cut -d: -f1)

if [ -n "$SIDEBAR_PANE" ]; then
    # Sidebar exists - kill it
    tmux kill-pane -t "$SIDEBAR_PANE"
else
    # Create sidebar on the right, 25% width
    tmux split-window -h -l 25% -t "$MAIN_PANE" "$SIDEBAR_BIN $MAIN_PANE"
    # Mark the new pane
    tmux select-pane -T "$SIDEBAR_MARKER"
    # Return focus to main pane
    tmux select-pane -t "$MAIN_PANE"
fi
```

**Step 2: Make executable**

Run: `chmod +x ~/.config/scripts/tmux-sidebar/toggle.sh`

**Step 3: Commit**

```bash
git add ~/.config/scripts/tmux-sidebar/toggle.sh
git commit -m "feat(tmux-sidebar): add toggle script"
```

---

### Task 9: Tmux Binding

**Files:**
- Modify: `~/.config/tmux/tmux.conf`

**Step 1: Update tmux.conf**

Replace the existing `bind E` line with:

```bash
# Toggle file sidebar
bind E run-shell "~/.config/scripts/tmux-sidebar/toggle.sh #{pane_id}"
```

**Step 2: Test the binding**

Run: `tmux source ~/.config/tmux/tmux.conf`
Then press `prefix + E` to toggle sidebar

**Step 3: Commit**

```bash
git add ~/.config/tmux/tmux.conf
git commit -m "feat(tmux-sidebar): bind toggle to prefix+E"
```

---

### Task 10: Cleanup Old Files

**Files:**
- Delete: `~/.config/scripts/yazi-sidebar.sh`

**Step 1: Remove old script**

Run: `rm ~/.config/scripts/yazi-sidebar.sh`

**Step 2: Commit**

```bash
git add -u
git commit -m "chore: remove old yazi-sidebar script"
```

---

## Summary

| Key | Action |
|-----|--------|
| `j` / `k` | Move down/up (siblings only) |
| `l` / Enter | Expand directory / Open file |
| `h` | Collapse / Go to parent |
| `H` (shift) | Go to root |
| `g` / `G` | Go to top / bottom |
| `r` | Refresh |
| `q` / Esc | Close sidebar |

Features:
- Auto-syncs to sibling pane's PWD
- Git status indicators (M/A/D) with colors
- File watching for instant updates
- Opens files with $EDITOR in sibling pane
