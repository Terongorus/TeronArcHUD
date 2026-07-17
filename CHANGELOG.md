# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versions follow major.minor.hotfix (e.g. 1.2.3).

## [1.0.0] - 2026-07-17

Initial fork of [ArcHUD2](https://github.com/McPewPew/ArcHUD2). Renamed for the portfolio
(folder/`.toc`/branding only - internal Lua namespaces, SavedVariables, and file names are
unchanged) and fixed 8 hardcoded `Interface\Addons\ArcHUD2\Icons\...` texture paths in
`ModuleCore.lua` that would have silently broken every ring's textures after the rename.
