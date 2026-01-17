mod tree;

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
