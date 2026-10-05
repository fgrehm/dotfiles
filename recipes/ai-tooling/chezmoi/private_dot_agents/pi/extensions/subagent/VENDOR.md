# Vendored source

`index.ts` and `agents.ts` in this directory are copied verbatim from the Pi
coding agent repository. They are not maintained here.

| | |
|---|---|
| Upstream | <https://github.com/earendil-works/pi> |
| Path | `packages/coding-agent/examples/extensions/subagent` |
| Commit | `8af7690c4f0c41fad274620829c75a3243d07aa3` |
| Commit date | 2026-08-18 |
| Commit message | `fix(coding-agent): skip trusted subagent prompts` |
| License | MIT, Copyright (c) 2025 Mario Zechner |
| Vendored on | 2026-10-05 |
| Previous commit | none (unchanged) |
| Upstream URL | <https://github.com/earendil-works/pi/blob/main/packages/coding-agent/examples/extensions/subagent> |

`README.md` in this directory is the upstream README, kept unmodified so the
extension's own documentation stays available offline.

## Local modifications

None. Both files are byte-identical to upstream.

## Re-vendoring

Do not edit the files by hand. Re-run the vendoring helper, which resolves a
new upstream commit, reports the change, and rewrites this file:

```sh
recipes/ai-tooling/scripts/vendor-pi-subagent.sh [--sha <commit>]
```

Run it when upgrading Pi and check whether the example changed:

```sh
recipes/ai-tooling/scripts/vendor-pi-subagent.sh --check
```

## Why this is vendored

Pi ships this example as documentation, not as a supported package, so there is
nothing to install from. Vendoring it gives the `subagent` tool (single,
parallel, and chain dispatch to isolated child `pi` processes) without pulling in
`pi-subagents`, which adds a large dependency and a much larger feature surface
we do not use.

The vendored example expects agents in `~/.pi/agent/agents/`. This recipe ships
a single generic `delegate` agent; see the ai-tooling README.
