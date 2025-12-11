# Kiln iOS App — Incremental Milestones

A SwiftUI app for transforming habitual experiences through the 6-phase Kiln process.

---

## Milestone 0: Walking Skeleton (Trivial End-to-End)
> *"A user can complete one full Kiln cycle on a single hardcoded scenario."*

- Single scrollable view with 6 phases (hardcoded prompts)
- Anchor: Hardcoded to "Anxiety Navigation → The WiFi Fails"
- Input: Simple text fields for reflections at each phase
- Storage: None (ephemeral—data lost on close)
- Output: Summary view showing what they wrote

**Proves**: The 6-phase flow is usable on mobile.

---

## Milestone 1: Persistence + Multiple Sessions
> *"A user can save and revisit past Kiln sessions."*

- `SwiftData` for local persistence
- List view of past sessions (date, anchor, completion status)
- Resume incomplete sessions
- Delete sessions

---

## Milestone 2: Anchor Library
> *"A user can choose from the 14 enumerated anchors."*

- Seed 14 anchors from THESIS.md (Order Seeking, Anxiety Navigation, etc.)
- Picker at session start
- Each anchor includes description + tentative forms as prompts
- Anchors are read-only (system-provided)

---

## Milestone 3: Room Emergence
> *"A user can name and save the new Room that emerges."*

- Phase 5 captures: Room name + "spirit" description
- Rooms become first-class entities (separate from sessions)
- Room library view
- Link rooms back to origin session

---

## Milestone 4: Technique Prompts
> *"Guided prompts for each phase's techniques."*

- Expand each phase with techniques from THESIS.md
- Collapsible "technique cards" (Defamiliarization, Silent Witnessing, etc.)
- User picks which technique(s) they used
- Richer reflection prompts based on technique

---

## Milestone 5: Timers + Holding Space
> *"Phase 3 (Empty Heat) gets a meditation-style timer."*

- Configurable timer for the "gap" phase (default: 5 min)
- Haptic pulse at start/end
- Optional ambient sound (or silence toggle)
- Log duration in session data

---

## Milestone 6: Room Graph / Adjacency
> *"Rooms can link to other Rooms."*

- Suggest "adjacent" rooms when creating new room
- Graph view: nodes = rooms, edges = adjacencies
- Tap room to see origin session + linked rooms
- Embodies the "Adjacent Possible" concept

---

## Milestone 7: Journal Feed + Reflection History
> *"A timeline of all observations and transformations."*

- Feed view of all Phase 6 entries chronologically
- Search/filter by anchor or room
- Export to Markdown or plain text

---

## Milestone 8: Anchor Customization
> *"Users can define their own anchors."*

- Add custom anchors with name + description + tentative forms
- Tag anchors (system vs. user-defined)
- Share anchors via share sheet

---

## Milestone 9: Widgets + Shortcuts
> *"Quick entry into Kiln from Home Screen."*

- Widget: "Start new session" or "Continue last session"
- Siri Shortcut: "Start a Kiln session for [anchor]"

---

## Milestone 10: Sync + Export
> *"Data moves across devices."*

- iCloud sync via CloudKit
- Export full journal as PDF or Markdown archive
- Optional: integrate with Apple Notes or Obsidian

---

## Summary

| MS | Core Feature | Data Model | Complexity |
|----|--------------|------------|------------|
| 0 | 6-phase form | None | Trivial |
| 1 | Persistence | Session | Low |
| 2 | Anchor library | Anchor → Session | Low |
| 3 | Room creation | Room → Session | Medium |
| 4 | Technique prompts | Technique → Phase | Medium |
| 5 | Timer / holding | Timer metadata | Medium |
| 6 | Room graph | Room ↔ Room | High |
| 7 | Journal feed | All entries | Medium |
| 8 | Custom anchors | User anchors | Medium |
| 9 | Widgets/Shortcuts | System integration | Medium |
| 10 | Sync/Export | CloudKit | High |
