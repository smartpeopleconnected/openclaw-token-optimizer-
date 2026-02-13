# Changelog

## [1.0.8] - 2026-02-12

### New Features
- **Configurable heartbeat providers** - Support for `ollama`, `lmstudio`, `groq`, and `none`. Configure via `setup-heartbeat --provider <name>`.
- **Rollback command** - List and restore config backups with `rollback --list` and `rollback --to <file>`.
- **Health check command** - Quick system status with `health` (config, JSON validity, provider reachable, workspace size, budgets).
- **Diff preview in dry-run** - `optimize --dry-run` now shows a colored unified diff instead of dumping the full config.
- **`--no-color` flag** - Disable colored output globally with `--no-color` or `NO_COLOR` env var.

### Improvements
- **Shared colors module** - Deduplicated color code from 3 files into `src/colors.py`.
- **Version single source of truth** - All files read version from `src/__init__.py`. No more hardcoded version strings.
- **Extended triggers** - Added 10 new search triggers for better marketplace discovery.
- **Provider-aware verification** - `verify` checks the configured heartbeat provider instead of only Ollama.

### Fixes
- **License consistency** - Fixed setup.py classifier from "Proprietary" to MIT, README from "Commercial" to MIT.
- **URLs** - setup.py now points to correct smartpeopleconnected GitHub URLs.
- **Version sync** - All 7 files that showed "1.0.0" now correctly show 1.0.8.

## [1.0.7] - 2026-02-08

### Security Improvements
- **Removed hidden HTML comment** from SKILL.md that was flagged in a ClawHub security review.
- **Dry-run is now the default** - running `optimizer.py` without flags shows a preview only. Use `--apply` to make actual changes. This prevents accidental config modifications.
- **User confirmation before downloads** - `ollama pull` now asks for confirmation before downloading ~2GB model data.
- **Existing files are no longer overwritten** - files in `~/.openclaw/prompts/` are skipped if they already exist, preserving user customizations.

### New Features
- **7-day savings report** - after 7 days of usage, `verify.py` shows your accumulated cost savings with a weekly breakdown. This report appears once every 7 days.

### Changed
- `--dry-run` flag replaced by `--apply` flag (dry-run is now the default behavior)
- Documentation updated to reflect new `--apply` workflow

## [1.0.6] - Initial ClawHub release

- Model routing (Haiku default)
- Ollama heartbeats (free local LLM)
- Session management optimization
- Prompt caching
- Budget controls and rate limits
- Cross-platform CLI (Windows, macOS, Linux)
- Verification tool
