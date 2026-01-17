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
