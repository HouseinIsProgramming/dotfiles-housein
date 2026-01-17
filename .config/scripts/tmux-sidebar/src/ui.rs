use ratatui::{
    Frame,
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
