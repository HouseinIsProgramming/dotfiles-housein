use std::path::{Path, PathBuf};
use std::fs;
use std::cmp::Ordering;
use crate::git::GitInfo;

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
    pub flat_list: Vec<usize>,
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
        Self::find_node_mut_inner(&mut self.root, path)
    }

    fn find_node_mut_inner<'a>(node: &'a mut FileNode, path: &Path) -> Option<&'a mut FileNode> {
        if node.path == path {
            return Some(node);
        }
        for i in 0..node.children.len() {
            if path.starts_with(&node.children[i].path) {
                return Self::find_node_mut_inner(&mut node.children[i], path);
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

    pub fn apply_git_status(&mut self, git_info: &GitInfo) {
        Self::apply_git_status_recursive(&mut self.root, git_info);
    }

    fn apply_git_status_recursive(node: &mut FileNode, git_info: &GitInfo) {
        node.git_status = git_info.get_status(&node.path);
        for child in &mut node.children {
            Self::apply_git_status_recursive(child, git_info);
        }
    }
}
