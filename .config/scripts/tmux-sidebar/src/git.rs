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
        if let Some(status) = self.statuses.get(path) {
            return status.clone();
        }

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
