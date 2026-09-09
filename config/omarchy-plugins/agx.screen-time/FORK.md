## 2026-09-09: lock/screensaver pause was dead on Omarchy 4.0 (fixed locally)

The pause mechanism subscribed to `shell.serviceFor("omarchy.lock")` /
`("omarchy.idle")`, but Omarchy 4.0's plugin sandbox resolves `serviceFor`
only to a plugin's own service — both came back `null` forever, so accrual
ran through lock windows (measured: 12.0h recorded vs 6.6h unlocked on
2026-09-08; upstream issue ax1g#10 is likely the same bug). Also fixed two
secondary reopen leaks that would have accrued through the pause even with
working lock events: `switchActive()` reopened buckets on focus events fired
while locked, and an in-flight terminal resolve (`applyResolvedApp`) could
reopen one mid-lock.

Local fix (upstream candidate):

- Warn once after 10s when the lock/idle services never resolve.
- Fallback: single persistent watcher process calling
  `omarchy-shell lock isLocked` every 10s (same call omarchy's idle service
  uses; change-only output, supervisor restart) feeding the existing
  `setSessionLocked()`; screensaver derived from the toplevel list every
  10s in-process. Resume after unlock is deferred ~2s and re-validates both
  pause flags so a stale reading cannot briefly reopen a bucket.
- `switchActive()` / `applyResolvedApp()` keep the bucket closed while
  `sessionLocked || screensaverActive`.
- Event-driven subscriptions still take over automatically when the shell
  exposes the services (future omarchy-shell fix: add `omarchy.lock` to the
  third-party first-party proxy allowlist with a read-only `locked`).
- Upstream work lives in `~/Projects/oss/quickshell-screentime-plugin`
  (branch `session-state`, commits 7331742/9a3c054/bae89e8; PR draft
  `docs/pr-drafts/PR-lock-state.md`).

Data note: history up to 2026-09-08 was corrected in place (proportional
scale-down to measured unlocked wall time); raw file preserved as
`history.json.backup-pre-lockfix-*`. Pre-fix data over-counts.

Verification still owed: one real lock window observed with the pause
engaged (lock for ~1 min, confirm today's total freezes).

Fork notice: vendored from https://github.com/ax1g/quickshell-screentime-plugin at commit 42ca30751cf3e623e615cbb54d9bf874927560a (v1.5.0).
