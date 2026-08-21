# Weekly Check-in Note Shortcuts

Two Apple Shortcuts that create or open weekly check-in notes in Apple Notes.
Idempotent — running a shortcut twice opens the existing note instead of creating a duplicate.

## Files

| File | Description |
|------|-------------|
| `Weekly Check-in Note.shortcut` | Current week (Monday–Sunday) |
| `Next Weekly Check-in Note.shortcut` | Next week (Monday–Sunday) |

## Import

1. Double-click the `.shortcut` file, or open it with **Shortcuts.app**.
2. Tap **Add Shortcut** in the import dialog.
3. Repeat for both files.

On iOS/iPhone: AirDrop the `.shortcut` file to your device, or save to iCloud Drive and open from Files.

## How It Works

Each shortcut:

1. Computes the Monday and Sunday of the target week.
2. Builds a title: `Weekly Check-in — 18 May–24 May 2026 — CW21`
3. Searches Apple Notes for a note with exactly that title.
4. If found → opens it.
5. If not found → creates a new note with the template, then opens it.

### Note Template

```
Weekly Check-in — {startDate}–{endDate} — CW{weekNumber}

## Weight

## Hunger

## Well-being

## Cardio / steps

## Wins

## Problems to fix next week

## Plan for next week
```

The first line becomes the note's title in Apple Notes.

## Testing

1. Import both shortcuts.
2. Run **Weekly Check-in Note**.
3. Confirm a note is created with the current week's title.
4. Run **Weekly Check-in Note** again.
5. Confirm it opens the same note — no duplicate created.
6. Run **Next Weekly Check-in Note**.
7. Confirm it creates/opens a note for next week.
8. Run it again — confirm no duplicate.

## Customization

### Change the Notes folder

1. Open the shortcut in Shortcuts.app.
2. Find the **Create Note** action (near the bottom, inside the "Otherwise" branch).
3. Tap the folder field and pick a different folder.
4. If you already have notes in a specific folder, also update the **Find Notes** action's folder filter.

### Change the body template

1. Open the shortcut in Shortcuts.app.
2. Find the second **Text** action — it builds the note body.
3. Edit the text after the title variable. Keep the first line as-is (it's the title reference).

### Change the title format

1. Find the first **Text** action that contains `Weekly Check-in —`.
2. Edit the text. The three embedded variables are: start date, end date, week number.
3. Also update the **Find Notes** filter to match your new title pattern.

## Known Limitations

1. **English locale required for date dispatch.** The shortcut compares day names (`Monday`, `Tuesday`, etc.) in English. Non-English device languages will break the Monday calculation. Fix: edit the 6 "If" conditions to use your locale's day names.

2. **Week number is locale-dependent.** The `w` date format returns the calendar week number based on your device's locale settings. For most of the year this matches ISO 8601, but it can differ by ±1 at year boundaries if your locale doesn't use Monday as the first day of the week.

3. **Note matching uses the "Name" property.** Apple Notes uses the first line of a note as its name. If Apple Notes strips or transforms the first line (e.g., removes markdown), the duplicate check may fail. If you see duplicates, try changing the filter property from "Name" to "Title" in the Shortcuts app.

4. **Signing.** The `.shortcut` files are signed with `--mode anyone`. If your device rejects the signature, re-sign locally:
   ```bash
   shortcuts sign --mode anyone --input "Weekly Check-in Note.shortcut" --output "Weekly Check-in Note_resigned.shortcut"
   ```
