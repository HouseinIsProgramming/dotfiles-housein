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
        // Escape single quotes for shell safety
        let escaped_path = path.replace("'", "'\\''");

        if let Some(ref pane) = self.sibling_pane {
            // Send command to sibling pane
            if let Err(e) = std::process::Command::new("tmux")
                .args(["send-keys", "-t", pane, &format!("{} '{}'", editor, escaped_path), "Enter"])
                .output()
            {
                eprintln!("Failed to open file: {}", e);
            }
        }
    }
}
