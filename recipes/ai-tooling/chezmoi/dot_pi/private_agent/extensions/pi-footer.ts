import type { AssistantMessage } from "@earendil-works/pi-ai";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";

function formatTokens(value: number): string {
  if (value < 1000) return `${value}`;
  if (value < 1_000_000) return `${(value / 1000).toFixed(1)}k`;
  return `${(value / 1_000_000).toFixed(1)}m`;
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", (_event, ctx) => {
    if (ctx.mode !== "tui") return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      const unsubscribe = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsubscribe,
        invalidate() {},
        render(width: number): string[] {
          const usage = ctx.getContextUsage();
          const branch = footerData.getGitBranch();
          const model = ctx.model;
          const project = ctx.cwd.split("/").filter(Boolean).at(-1) ?? "~";

          let input = 0;
          let output = 0;
          let cacheRead = 0;
          let cacheWrite = 0;
          let cost = 0;
          for (const entry of ctx.sessionManager.getBranch()) {
            if (entry.type !== "message" || entry.message.role !== "assistant") continue;
            const message = entry.message as AssistantMessage;
            input += message.usage.input;
            output += message.usage.output;
            cacheRead += message.usage.cacheRead;
            cacheWrite += message.usage.cacheWrite;
            cost += message.usage.cost.total;
          }

          const contextPercent = usage?.percent;
          const contextColor =
            contextPercent !== null && contextPercent !== undefined && contextPercent >= 90
              ? "error"
              : contextPercent !== null && contextPercent !== undefined && contextPercent >= 70
                ? "warning"
                : "success";
          const context =
            contextPercent === null || contextPercent === undefined
              ? theme.fg("muted", "ctx ?")
              : theme.fg(contextColor, `ctx ${Math.round(contextPercent)}%`);
          const providerModel = model
            ? theme.bold(theme.fg("text", `${model.id}@${model.provider}`))
            : theme.fg("muted", "no model");
          const location = theme.fg("accent", project) +
            (branch ? theme.fg("muted", " (") + theme.fg("mdLink", branch) + theme.fg("muted", ")") : "");
          const stats = theme.fg(
            "dim",
            `↑${formatTokens(input)} ↓${formatTokens(output)}  cr${formatTokens(cacheRead)} cw${formatTokens(cacheWrite)}  $${cost.toFixed(2)}`,
          );

          const left = `${location}  ${context}  ${stats}`;
          const full = `${left}  ${providerModel}`;
          if (visibleWidth(full) <= width) {
            const padding = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(providerModel)));
            return [truncateToWidth(`${left}${padding}${providerModel}`, width, "")];
          }
          if (visibleWidth(`${location}  ${context}`) <= width) {
            return [truncateToWidth(`${location}  ${context}`, width, "")];
          }
          return [truncateToWidth(`${context}  ${providerModel}`, width, "")];
        },
      };
    });
  });
}
