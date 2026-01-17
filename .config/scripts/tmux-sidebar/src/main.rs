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

use app::{App, CopyMode};
use watcher::Watcher;

struct CleanupGuard;

impl Drop for CleanupGuard {
    fn drop(&mut self) {
        let _ = disable_raw_mode();
        let _ = execute!(io::stdout(), LeaveAlternateScreen);
    }
}

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
    let _cleanup = CleanupGuard; // Will run cleanup on drop (including panic)
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
                    // Copy mode handling
                    _ if app.copy_mode == CopyMode::Selecting => {
                        match key.code {
                            KeyCode::Char('1') => app.copy_selection(1),
                            KeyCode::Char('2') => app.copy_selection(2),
                            KeyCode::Char('3') => app.copy_selection(3),
                            KeyCode::Char('4') => app.copy_selection(4),
                            KeyCode::Esc | KeyCode::Char('q') | KeyCode::Char('c') => app.exit_copy_mode(),
                            _ => {}
                        }
                    }
                    // Normal mode
                    (KeyCode::Char('q'), _) | (KeyCode::Esc, _) => {
                        app.should_quit = true;
                    }
                    (KeyCode::Char('c'), _) => app.enter_copy_mode(),
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

    Ok(())
}
