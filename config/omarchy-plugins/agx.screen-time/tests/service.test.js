"use strict"

const { test } = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")

const service = fs.readFileSync(
  path.join(__dirname, "..", "Service.qml"),
  "utf8",
)

test("service tracks lock and screensaver state", () => {
  assert.match(service, /property bool sessionLocked: false/)
  assert.match(service, /property bool screensaverActive: false/)
  assert.match(service, /serviceFor\("omarchy\.lock"\)/)
  assert.match(service, /serviceFor\("omarchy\.idle"\)/)
  assert.match(service, /function setSessionLocked\(locked\)/)
  assert.match(service, /function setScreensaverActive\(active\)/)
})

test("lock and screensaver transitions close and persist the active bucket", () => {
  assert.match(
    service,
    /function setSessionLocked[\s\S]*?State\.closeActiveBucket\([\s\S]*?root\.persist\(\)/,
  )
  assert.match(
    service,
    /function setScreensaverActive[\s\S]*?State\.closeActiveBucket\([\s\S]*?root\.persist\(\)/,
  )
})

test("screen-time debugging is opt-in", () => {
  assert.match(service, /property bool debugLogging: false/)
  assert.match(service, /if \(root\.debugLogging\) console\.warn/)
})

test("pause keeps buckets closed against reopen paths", () => {
  // Focus events and reconcile ticks during lock must not reopen a bucket.
  assert.match(
    service,
    /function switchActive[\s\S]*?root\.sessionLocked \|\| root\.screensaverActive[\s\S]*?root\.activeApp = ""[\s\S]*?root\.activeStart = 0/,
  )
  // A resolver landing during the pause must not reopen a bucket either.
  assert.match(
    service,
    /function applyResolvedApp[\s\S]*?root\.sessionLocked \|\| root\.screensaverActive[\s\S]*?root\.resolveForApp = ""/,
  )
  // Locking kills any in-flight resolve.
  assert.match(
    service,
    /if \(locked\) \{[\s\S]*?root\.resolveForApp = ""[\s\S]*?lock started/,
  )
})

test("falls back to polling when lock/idle services are unavailable", () => {
  // Scoped plugin shells may never resolve the lock/idle services; the
  // plugin must say so once and poll instead of accruing through locks.
  assert.match(service, /property bool serviceLookupWarned: false/)
  assert.match(service, /id: fallbackPollTimer/)
  assert.match(service, /running: root\.ready && \(!root\.lockService \|\| !root\.idleService\)/)
  assert.match(service, /omarchy-shell lock isLocked/)
  assert.match(service, /setSessionLocked\(lockPollOut\.text\.trim\(\) === "true"\)/)
  assert.match(service, /function screensaverWindowVisible/)
  // The poll result feeds the same pause state machine; no bucket handling
  // inside the poll process block.
  const poll = service.match(/Process \{\s*\n\s*id: lockPollProc[\s\S]*?\n  \}/)
  assert(poll, "lockPollProc block exists")
  assert.match(poll[0], /setSessionLocked\(lockPollOut/)
  assert(!poll[0].includes("closeActiveBucket"))
})

test("warns once instead of failing silently when services never appear", () => {
  assert.match(service, /services unavailable after 10s/)
})
