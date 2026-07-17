# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow major.minor.hotfix (e.g. 1.2.3).

## [1.1.3] - 2026-07-17

### Fixed
- The content panel's own scrollbar (right side, `UIPanelScrollFrameTemplate`) landed on
  top of the dialog's ~12px border texture - 1.1.1's widening only left room for the
  scrollbar itself, not the scrollbar *plus* the border past it. Narrowed the content
  scrollframe further to clear both.

## [1.1.2] - 2026-07-17

### Fixed
- 1.1.1's top-headroom fix only applied to the *first* control in a panel. A slider
  directly following a checkbox (e.g. Display options' "Nameplate hover delay" after
  "Nameplate hover message") still had its title text overlapping the checkbox row above
  it, since every slider's title sits above its own anchor point, not just the first one.
  The padding now applies before every slider, wherever it falls in the panel.

## [1.1.1] - 2026-07-17

### Fixed
- **Data corruption**: switching category caused a pooled slider widget to briefly carry
  over the *previous* category's data (e.g. the Misc panel's "HUD width" slider, default
  30) while `SetMinMaxValues`/`SetValue` were re-clamping it into the new category's range.
  Blizzard's Slider re-fires `OnValueChanged` synchronously from inside those calls, and
  since `entryData`/`isPercent`/the label were only assigned *after* them, that spurious
  fire ran with the wrong entry attached, writing the old value into the new setting's
  profile key (observed: Fade options' "When full" showing `3000%` after visiting Misc -
  the leftover `30` from Width got written into `FadeFull`). All slider fields are now
  assigned before any Slider setter call, so a spurious fire (if one still occurs) always
  sees the entry actually being rendered. **A value already corrupted by this bug before
  updating won't self-heal** - drag the affected slider to the value you actually want, or
  `/archud reset confirm` to restore every setting to its default.
- Widened the category and content scrollframes - `UIPanelScrollFrameTemplate`'s scrollbar
  sits ~20-25px outside the scrollframe's own right edge, and the previous sizing didn't
  leave room for it, so the scrollbar overlapped the last few pixels of category button
  text and the content area's own scrollbar overlapped the "Fade options"/"Miscellaneous
  options" category headers.
- Combined a slider's label and current value into its own title text instead of a
  separate FontString anchored below the slider bar - that second text sat right where
  `OptionsSliderTemplate`'s Low/High labels already are, so they visually collided (most
  visible on "Nameplate hover delay").
- Added top headroom before the first control in a panel - a slider's title text sits
  *above* its own anchor point, so the first slider in a category (e.g. Fade options'
  "When full") had its title clipped against the scrollframe's top edge/the dialog's own
  border.

## [1.1.0] - 2026-07-17

### Added
- A proper options window (`/archud config`, or the minimap button) replacing the old
  right-click Dewdrop menu that used to hang off the minimap button, several flyouts deep
  in places (Misc -> Ring Visibility -> pick one; a ring's category -> Side -> pick one).
  One left-hand category per section (Display, Fade, Misc) and per ring (Health, Mana,
  Target Health, Target Mana, Pet Health, Pet Mana, Casting, Mirror Timer, Combo Points,
  Druid Mana), all of that section/ring's options on the right, including what used to be
  a further-nested flyout (Side, Ring Visibility) now inlined as a radio row instead of
  requiring another click-through.
- `Options.lua` reads `ArcHUD.dewdrop_menu` (the same table `Core.lua`/`ModuleCore.lua`
  already build for the old menu) directly rather than re-declaring every option by hand -
  no option's key, default, tooltip, or callback changed, only how it's presented. The old
  Dewdrop menu code is untouched and still builds that same table; only the two places that
  used to open it (the `config` chat command, the minimap button's click/right-click) now
  open the new frame instead.

## [1.0.0] - 2026-07-17

Initial fork of [ArcHUD2](https://github.com/McPewPew/ArcHUD2). Renamed for the portfolio
(folder/`.toc`/branding only - internal Lua namespaces, SavedVariables, and file names are
unchanged) and fixed 8 hardcoded `Interface\Addons\ArcHUD2\Icons\...` texture paths in
`ModuleCore.lua` that would have silently broken every ring's textures after the rename.
