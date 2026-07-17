# Teron's ArcHUD

A combat HUD for Vanilla WoW 1.12.1 (Turtle WoW): player/target/pet health and mana/rage/energy
shown as rings centered on your screen, a small target frame with a 3D model, and a casting bar.
Fork of [ArcHUD2](https://github.com/McPewPew/ArcHUD2).

Access options with `/archud` or `/ah` in the chat window, or via the minimap button.

## Changed from upstream

- **Settings moved into a proper options window.** Previously every setting (Display, Fade, Misc,
  Ring Visibility, and each ring's own Enabled/Outline/Side/Level/etc.) only existed inside a
  right-click Dewdrop menu hanging off the minimap button, several flyouts deep in places. All of
  it now lives in one options frame, one category per section/ring, opened the same way
  (`/archud config`, or clicking the minimap button). No option was renamed, removed, or had its
  default changed - this is a UI-layer change only, the underlying settings and their effects are
  unchanged.

Everything else - the rings, the target frame, nameplates, the casting bar - is unmodified from
upstream.

## Credits

Written by Saleel/Nenie of Argent Dawn, based on Tivoli's beta Nurfed HUD, which used the
StatRings ring code originally by Iriel and later modified by Antiarc. Additional credit (from
the original readme) to Moog for Moog_Hud and to Repent for eCastingBar, where the FlightMap
timer support was adapted from. GitHub re-upload/maintenance by McPewPew. Teron fork by
Terongorus.

## Changelog (upstream, pre-fork)

**2.0.8945** (2006-08-24) - Updated TOC for 1.12, added deDE locale, fixed remaining fontstrings
not showing `...`.

**2.0.8359** (2006-08-18) - Updated locales, fixed DruidMana booleans, added native MobHealth3
support, made the target nameplate always active, fixed clickcasting support.

**2.0.8158** (2006-08-16) - Added a PvP indicator to the nameplate, added PvP/group leader/raid
target icons to the target frame, added class/creature type/family to the level display, fixed
fontstrings being too small, fixed a DruidMana timer issue.

**2.0.7892** (2006-08-13) - Reworked to use Ace2 instead of Ace (fully embedded, no longer a
separate dependency), removed the party interface (out of scope for a HUD, not a full
unitframes addon), added zhCN locale, added options to show/hide the Blizzard player/pet/target
frames.

See [CHANGELOG.md](CHANGELOG.md) for changes made in this fork.
