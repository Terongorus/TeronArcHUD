# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow major.minor.hotfix (e.g. 1.2.3).

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
