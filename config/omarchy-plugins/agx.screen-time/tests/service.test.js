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
