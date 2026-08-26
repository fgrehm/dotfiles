/**
 * Adds familiar shell/editor-style quit commands to Pi.
 *
 * Supports Pi's /exit and /quit commands, bare "exit", and Vim-style
 * :q, :q!, :wq, :wq!, :x, and :x! inputs.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const quitInputs = new Set(["exit", ":q", ":q!", ":wq", ":wq!", ":x", ":x!"]);

export default function (pi: ExtensionAPI) {
  pi.registerCommand("exit", {
    description: "Exit Pi",
    handler: async (_args, ctx) => {
      ctx.shutdown();
    },
  });

  pi.on("input", (event, ctx) => {
    if (event.source === "interactive" && quitInputs.has(event.text.trim())) {
      ctx.shutdown();
      return { action: "handled" };
    }
    return { action: "continue" };
  });
}
