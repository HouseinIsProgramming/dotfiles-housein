use ratatui::{
    Frame,
    layout::Rect,
    style::{Color, Modifier, Style},
    text::{Line, Span},
    widgets::{Block, Borders, Clear, List, ListItem, ListState, Paragraph},
};
use crate::app::{App, CopyMode};
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

    // Show copy menu if in copy mode
    if app.copy_mode == CopyMode::Selecting {
        render_copy_menu(frame, area);
    }
}

fn render_copy_menu(frame: &mut Frame, area: Rect) {
    // Center the popup
    let popup_width = 30;
    let popup_height = 6;
    let x = (area.width.saturating_sub(popup_width)) / 2;
    let y = (area.height.saturating_sub(popup_height)) / 2;
    let popup_area = Rect::new(x, y, popup_width, popup_height);

    // Clear the area
    frame.render_widget(Clear, popup_area);

    let menu_text = vec![
        Line::from("Copy:"),
        Line::from(""),
        Line::from("  1. File name"),
        Line::from("  2. Directory"),
        Line::from("  3. Absolute path"),
        Line::from("  4. Relative path"),
    ];

    let menu = Paragraph::new(menu_text)
        .block(Block::default()
            .borders(Borders::ALL)
            .border_style(Style::default().fg(Color::Cyan))
            .title("Copy"));

    frame.render_widget(menu, popup_area);
}
