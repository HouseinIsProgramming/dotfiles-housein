mod tree;
mod git;

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
