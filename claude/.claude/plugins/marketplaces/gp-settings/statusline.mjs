#!/usr/bin/env node

/**
 * Claude Code HUD – statusline script
 *
 * Reads session metrics from stdin (JSON) and outputs a 3-line HUD:
 *   Line 1: Model | Branch | Session time | Cost
 *   Line 2: Context usage bar
 *   Line 3: 5h / 7d rate-limit bars (from OAuth Usage API)
 *
 * Note: cache files use the PLUGIN_DIR path (~/.claude/plugins/marketplaces/
 * gp-settings/) — deploy this script to that directory.
 */

import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";
import { homedir } from "node:os";
import { basename, join, dirname } from "node:path";
import { request } from "node:https";

// ─── Constants ───────────────────────────────────────────────────────────────

const CONFIG_DIR = process.env.CLAUDE_CONFIG_DIR || join(homedir(), ".claude");
const PLUGIN_DIR = join(CONFIG_DIR, "plugins", "marketplaces", "gp-settings");
const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes
const UPDATE_CHECK_TTL_MS = 60 * 60 * 1000; // 1 hour
const UPDATE_CACHE_FILE = join(PLUGIN_DIR, ".update-cache.json");
const DAILY_COST_FILE = join(PLUGIN_DIR, ".daily-cost.json");

function cachePath() {
  const configDir = process.env.CLAUDE_CONFIG_DIR;
  if (!configDir) return join(PLUGIN_DIR, ".usage-cache.json");
  const hash = createHash("sha256").update(configDir.replace(/\/+$/, "")).digest("hex").slice(0, 8);
  return join(PLUGIN_DIR, `.usage-cache-${hash}.json`);
}

const RESET = "\x1b[0m";
const DIM = "\x1b[2m";
const BOLD = "\x1b[1m";
const GREEN = "\x1b[32m";
const YELLOW = "\x1b[33m";
const RED = "\x1b[31m";
const CYAN = "\x1b[36m";

// ─── stdin reader ────────────────────────────────────────────────────────────

function readStdin() {
  try {
    const raw = readFileSync(0, "utf-8").trim();
    if (!raw) return null;
    return JSON.parse(raw);
  } catch {
    return null;
  }
}

// ─── Turn counter ───────────────────────────────────────────────────────────

function getTurnCount(transcriptPath) {
  if (!transcriptPath) return null;
  try {
    const count = execFileSync(
      "grep", ["-c", '"type":"user"', transcriptPath],
      { timeout: 2000, encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }
    ).trim();
    return parseInt(count, 10) || null;
  } catch {
    return null;
  }
}

// ─── Git info ────────────────────────────────────────────────────────────────

function getGitInfo(cwd) {
  try {
    const branch = execFileSync("git", ["rev-parse", "--abbrev-ref", "HEAD"], {
      cwd,
      timeout: 1000,
      encoding: "utf-8",
      stdio: ["pipe", "pipe", "pipe"],
    }).trim();

    let dirty = false;
    try {
      const status = execFileSync(
        "git",
        ["--no-optional-locks", "status", "--porcelain"],
        {
          cwd,
          timeout: 1000,
          encoding: "utf-8",
          stdio: ["pipe", "pipe", "pipe"],
        }
      ).trim();
      dirty = status.length > 0;
    } catch {
      // ignore
    }

    let worktree = false;
    try {
      const gitDir = execFileSync("git", ["rev-parse", "--git-dir"], {
        cwd, timeout: 1000, encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"],
      }).trim();
      const commonDir = execFileSync("git", ["rev-parse", "--git-common-dir"], {
        cwd, timeout: 1000, encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"],
      }).trim();
      worktree = gitDir !== commonDir;
    } catch {
      // ignore
    }

    let repoName = "";
    try {
      const toplevel = execFileSync("git", ["rev-parse", "--show-toplevel"], {
        cwd, timeout: 1000, encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"],
      }).trim();
      repoName = basename(toplevel);
    } catch {
      // ignore
    }

    const prefix = repoName ? `${repoName}|` : "";
    return `${prefix}${branch}${dirty ? "*" : ""}${worktree ? " [worktree]" : ""}`;
  } catch {
    return null;
  }
}

// ─── Effort level ────────────────────────────────────────────────────────────

function getEffortLevel(cwd, data) {
  // 1. stdin data.effort.level — runtime-resolved value Claude Code will actually
  //    send to the API. Reflects /effort overrides (including session-only "max").
  //    Absent for models that don't support effort.
  const stdinEffort = data?.effort?.level;
  if (stdinEffort) return String(stdinEffort).toLowerCase();

  // 2. Environment variable
  const envEffort = process.env.CLAUDE_CODE_EFFORT_LEVEL;
  if (envEffort) return envEffort.toLowerCase();

  // 3. Project settings
  if (cwd) {
    try {
      const projectSettings = JSON.parse(
        readFileSync(join(cwd, ".claude", "settings.json"), "utf-8")
      );
      if (projectSettings.effortLevel) return projectSettings.effortLevel;
    } catch {
      // no project settings
    }
  }

  // 4. User global settings (CLAUDE_CONFIG_DIR or ~/.claude)
  try {
    const userSettings = JSON.parse(
      readFileSync(join(CONFIG_DIR, "settings.json"), "utf-8")
    );
    if (userSettings.effortLevel) return userSettings.effortLevel;
  } catch {
    // no user settings
  }

  return null;
}

// ─── Visibility config (hud.show) ───────────────────────────────────────────
//
// Every element rendered in the HUD can be toggled via `hud.show.<key>` in
// settings.json. Missing keys fall back to HUD_DEFAULTS.
// Lookup order: project `.claude/settings.json` overrides user
// `~/.claude/settings.json` (or CLAUDE_CONFIG_DIR).
//
// Convention: pre-existing elements default to `true` to preserve the HUD
// users are familiar with. Newly introduced elements default to `false`
// (opt-in) so a plugin update never silently changes the baseline layout.

const HUD_DEFAULTS = {
  // Line 1 — model / branch / duration
  model_name: true,        // "Opus 4.7 (1M)"
  effort_level: true,      // "high" / "max"
  session_tag: true,       // "[Team]" / "[Enterprise]" / "[Pro]"
  cache_ttl: true,         // "Cache:1h" / "Cache:5m"
  git_branch: true,        // "feature-branch*"
  duration: true,          // "12m"
  turn_count: true,        // "T42"

  // Line 2 — context
  context_bar: true,       // "Context █████░░░░░ 45% (450k/1.0M)"
  cache_hit_rate: true,    // "Cache 85%"
  output_tokens: true,     // "Out 2.3k"

  // Line 3 — rate limits / cost
  credits: true,           // Enterprise credits bar
  rate_5h: true,           // "5h ██░░░░░░░░ 18% (2h59m)"
  rate_7d: true,           // "7d █████░░░░░ 51%"
  sub_limits: false,       // "(Opus X% · Sonnet Y% · Design Z%)" — opt-in (#23)
  session_cost: true,      // "Session $0.15"
  cost_velocity: true,     // "($0.75/h)"
  daily_cost: true,        // "/ Today $4.00"
  lines_changed: true,     // "+42/-7"

  // Line 4 — notices
  update_notice: true,     // "⬆ HUD update available"
};

function loadHudShow(cwd) {
  const show = { ...HUD_DEFAULTS };

  // User global (lower priority)
  try {
    const us = JSON.parse(readFileSync(join(CONFIG_DIR, "settings.json"), "utf-8"));
    if (us?.hud?.show && typeof us.hud.show === "object") {
      Object.assign(show, us.hud.show);
    }
  } catch {
    // no user settings
  }

  // Project overrides user
  if (cwd) {
    try {
      const ps = JSON.parse(readFileSync(join(cwd, ".claude", "settings.json"), "utf-8"));
      if (ps?.hud?.show && typeof ps.hud.show === "object") {
        Object.assign(show, ps.hud.show);
      }
    } catch {
      // no project settings
    }
  }

  return show;
}

// ─── Cache TTL detection ────────────────────────────────────────────────────

function getCacheTTL(subscriptionType) {
  // Server-side 1h TTL for paid subscription plans
  if (["enterprise", "team", "pro", "max"].includes(subscriptionType)) {
    return { ttl: "1h", source: "server" };
  }
  // User opt-in via environment variable
  const envVal = process.env.ENABLE_PROMPT_CACHING_1H;
  if (envVal && envVal !== "0" && envVal.toLowerCase() !== "false") {
    return { ttl: "1h", source: "env" };
  }
  return { ttl: "5m", source: "default" };
}

// ─── OAuth credentials from Keychain ─────────────────────────────────────────

function keychainServiceName() {
  const configDir = process.env.CLAUDE_CONFIG_DIR;
  if (!configDir) return "Claude Code-credentials";
  const hash = createHash("sha256").update(configDir.replace(/\/+$/, "")).digest("hex").slice(0, 8);
  return `Claude Code-credentials-${hash}`;
}

function getOAuthCredentials() {
  // 1. Try file-based credentials (Linux / CLAUDE_CONFIG_DIR)
  try {
    const credFile = join(CONFIG_DIR, ".credentials.json");
    const raw = readFileSync(credFile, "utf-8").trim();
    const parsed = JSON.parse(raw);
    const oauth = parsed.claudeAiOauth;
    const token = oauth?.accessToken || parsed.access_token || parsed.token || null;
    if (token) {
      return {
        token,
        subscriptionType: oauth?.subscriptionType || null,
      };
    }
  } catch {
    // no file-based credentials — fall through to Keychain
  }

  // 2. Fallback to macOS Keychain
  try {
    const raw = execFileSync(
      "security",
      ["find-generic-password", "-s", keychainServiceName(), "-w"],
      { timeout: 2000, encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }
    ).trim();
    const parsed = JSON.parse(raw);
    const oauth = parsed.claudeAiOauth;
    return {
      token: oauth?.accessToken || parsed.access_token || parsed.token || null,
      subscriptionType: oauth?.subscriptionType || null,
    };
  } catch {
    return { token: null, subscriptionType: null };
  }
}

// ─── Usage API with caching ─────────────────────────────────────────────────

function readCache({ allowStale = false } = {}) {
  try {
    const raw = readFileSync(cachePath(), "utf-8");
    const cache = JSON.parse(raw);
    if (Date.now() - cache.timestamp < CACHE_TTL_MS) {
      return cache.data;
    }
    if (allowStale) {
      return cache.data;
    }
  } catch {
    // no cache
  }
  return null;
}

function writeCache(data) {
  try {
    mkdirSync(dirname(cachePath()), { recursive: true });
    writeFileSync(
      cachePath(),
      JSON.stringify({ timestamp: Date.now(), data }),
      "utf-8"
    );
  } catch {
    // ignore write errors
  }
}

function fetchUsageApi(token) {
  return new Promise((resolve) => {
    if (!token) {
      resolve(null);
      return;
    }

    const options = {
      hostname: "api.anthropic.com",
      path: "/api/oauth/usage",
      method: "GET",
      headers: {
        Authorization: `Bearer ${token}`,
        "anthropic-beta": "oauth-2025-04-20",
        Accept: "application/json",
      },
      timeout: 3000,
    };

    const req = request(options, (res) => {
      let body = "";
      res.on("data", (chunk) => (body += chunk));
      res.on("end", () => {
        try {
          if (res.statusCode === 200) {
            const data = JSON.parse(body);
            writeCache(data);
            resolve(data);
          } else {
            resolve(null);
          }
        } catch {
          resolve(null);
        }
      });
    });

    req.on("error", () => resolve(null));
    req.on("timeout", () => {
      req.destroy();
      resolve(null);
    });
    req.end();
  });
}

async function fetchUsage(token) {
  const cached = readCache();
  if (cached) return cached;
  const fresh = await fetchUsageApi(token);
  if (fresh) return fresh;
  return readCache({ allowStale: true });
}

// ─── Update check ───────────────────────────────────────────────────────────

function getPluginHead() {
  try {
    return execFileSync("git", ["rev-parse", "HEAD"], {
      cwd: PLUGIN_DIR, timeout: 1000, encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"],
    }).trim();
  } catch {
    return null;
  }
}

function getLocalPluginVersion() {
  try {
    const raw = readFileSync(join(PLUGIN_DIR, ".claude-plugin", "plugin.json"), "utf-8");
    return JSON.parse(raw)?.version || null;
  } catch {
    return null;
  }
}

function getRemotePluginVersion() {
  try {
    const raw = execFileSync(
      "git",
      ["show", "origin/main:.claude-plugin/plugin.json"],
      { cwd: PLUGIN_DIR, timeout: 2000, encoding: "utf-8", stdio: ["pipe", "pipe", "pipe"] }
    );
    return JSON.parse(raw)?.version || null;
  } catch {
    return null;
  }
}

function readUpdateCache() {
  try {
    const raw = readFileSync(UPDATE_CACHE_FILE, "utf-8");
    const cache = JSON.parse(raw);
    if (Date.now() - cache.timestamp < UPDATE_CHECK_TTL_MS) {
      // Invalidate the cache if HEAD changed (i.e. a git pull happened).
      if (cache.head && cache.head !== getPluginHead()) return null;
      return cache;
    }
  } catch {
    // no cache or expired
  }
  return null;
}

function writeUpdateCache(updateAvailable, versionMismatch = false) {
  try {
    writeFileSync(
      UPDATE_CACHE_FILE,
      JSON.stringify({
        timestamp: Date.now(),
        updateAvailable,
        versionMismatch,
        head: getPluginHead(),
      }),
      "utf-8"
    );
  } catch {
    // ignore
  }
}

function checkForUpdates() {
  const cached = readUpdateCache();
  if (cached != null) {
    return {
      available: cached.updateAvailable,
      versionMismatch: cached.versionMismatch ?? false,
    };
  }

  try {
    execFileSync("git", ["fetch", "origin", "--quiet"], {
      cwd: PLUGIN_DIR,
      timeout: 5000,
      stdio: ["pipe", "pipe", "pipe"],
    });

    const count = execFileSync(
      "git",
      ["rev-list", "HEAD..origin/main", "--count"],
      {
        cwd: PLUGIN_DIR,
        timeout: 2000,
        encoding: "utf-8",
        stdio: ["pipe", "pipe", "pipe"],
      }
    ).trim();

    const available = parseInt(count, 10) > 0;
    let versionMismatch = false;
    if (available) {
      const local = getLocalPluginVersion();
      const remote = getRemotePluginVersion();
      versionMismatch = !!(local && remote && local !== remote);
    }
    writeUpdateCache(available, versionMismatch);
    return { available, versionMismatch };
  } catch {
    writeUpdateCache(false, false);
    return { available: false, versionMismatch: false };
  }
}

// ─── Daily cost tracking ────────────────────────────────────────────────────

function trackDailyCost(sessionCost) {
  if (sessionCost == null) return null;

  const today = new Date().toISOString().slice(0, 10);
  const sessionKey = `${process.ppid}`;
  let data = { date: today, sessions: {}, archived: 0 };

  try {
    const raw = JSON.parse(readFileSync(DAILY_COST_FILE, "utf-8"));
    if (raw.date === today && raw.sessions) {
      data = raw;
      data.archived = data.archived || 0;
    }
  } catch {
    // no file or different date → fresh start
  }

  const prevCost = data.sessions[sessionKey] ?? 0;

  // Cost dropped for same PID → PID was reused by a new session, archive old cost
  if (sessionCost < prevCost - 0.001) {
    data.archived += prevCost;
  }

  data.sessions[sessionKey] = sessionCost;

  try {
    writeFileSync(DAILY_COST_FILE, JSON.stringify(data), "utf-8");
  } catch {
    // ignore
  }

  return data.archived + Object.values(data.sessions).reduce((sum, c) => sum + c, 0);
}

// ─── Formatters ──────────────────────────────────────────────────────────────

function formatDuration(ms) {
  if (ms == null || ms <= 0) return null;
  const totalMin = Math.floor(ms / 60000);
  if (totalMin < 60) return `${totalMin}m`;
  const h = Math.floor(totalMin / 60);
  const m = totalMin % 60;
  return m > 0 ? `${h}h${m}m` : `${h}h`;
}

function formatCost(usd) {
  if (usd == null) return null;
  return `$${usd.toFixed(2)}`;
}

function formatCredits(amount) {
  if (amount == null) return "?";
  const dollars = amount / 100;
  return "$" + dollars.toLocaleString("en-US", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });
}

function formatTokens(count) {
  if (count == null) return "?";
  if (count >= 1000000) return `${(count / 1000000).toFixed(1)}M`;
  if (count >= 1000) return `${Math.round(count / 1000)}k`;
  return `${count}`;
}

function colorForPercent(pct) {
  if (pct >= 80) return RED;
  if (pct >= 60) return YELLOW;
  return GREEN;
}

function progressBar(pct, width = 10, fixedColor = null) {
  const clamped = Math.max(0, Math.min(100, pct));
  const filled = Math.round((clamped / 100) * width);
  const empty = width - filled;
  const color = fixedColor || colorForPercent(clamped);
  return `${color}${"█".repeat(filled)}${DIM}${"░".repeat(empty)}${RESET}`;
}

function formatRemainingTime(resetsAt) {
  if (!resetsAt) return null;
  const diff = new Date(resetsAt).getTime() - Date.now();
  if (diff <= 0) return null;
  return formatDuration(diff);
}

// ─── Render ──────────────────────────────────────────────────────────────────

function effortColor(level) {
  switch (level) {
    case "low":
      return DIM;
    case "high":
      return YELLOW;
    case "xhigh":
    case "max":
      return RED;
    default:
      return "";
  }
}

function sessionTag(subscriptionType) {
  switch (subscriptionType) {
    case "enterprise":
      return `${DIM}[${RESET}${YELLOW}Enterprise${RESET}${DIM}]${RESET}`;
    case "team":
      return `${DIM}[${RESET}${CYAN}Team${RESET}${DIM}]${RESET}`;
    case "pro":
      return `${DIM}[${RESET}${GREEN}Pro${RESET}${DIM}]${RESET}`;
    default:
      return null;
  }
}

function render(data, gitBranch, usage, effort, subscriptionType, updateStatus, dailyCost, turnCount, show) {
  const lines = [];
  const sep = ` ${DIM}|${RESET} `;
  const isEnterprise = subscriptionType === "enterprise";

  // Line 1: Model [effort] [session type] [cache] | Branch | Duration [turn]
  const line1Parts = [];
  const modelBits = [];

  if (show.model_name) {
    const modelName = data?.model?.display_name || data?.model?.id || "Claude";
    modelBits.push(`${BOLD}${modelName}${RESET}`);
  }
  if (show.effort_level && effort) {
    modelBits.push(`${effortColor(effort)}${effort}${RESET}`);
  }
  if (show.session_tag) {
    const tag = sessionTag(subscriptionType);
    if (tag) modelBits.push(tag);
  }
  if (show.cache_ttl) {
    const cache = getCacheTTL(subscriptionType);
    modelBits.push(cache.ttl === "1h"
      ? `${DIM}Cache:${RESET}${GREEN}1h${RESET}`
      : `${DIM}Cache:${RESET}${YELLOW}5m${RESET}`);
  }
  if (modelBits.length > 0) {
    line1Parts.push(modelBits.join(" "));
  }

  if (show.git_branch && gitBranch) {
    line1Parts.push(`${CYAN}${gitBranch}${RESET}`);
  }

  let timePart = "";
  if (show.duration) {
    const d = formatDuration(data?.cost?.total_duration_ms);
    if (d) timePart = d;
  }
  if (show.turn_count && turnCount) {
    timePart = timePart
      ? `${timePart} ${DIM}T${turnCount}${RESET}`
      : `${DIM}T${turnCount}${RESET}`;
  }
  if (timePart) line1Parts.push(timePart);

  if (line1Parts.length > 0) lines.push(line1Parts.join(sep));

  // Line 2: Context bar + cache hit rate + output tokens
  const ctx = data?.context_window;
  const line2Parts = [];

  if (show.context_bar) {
    if (ctx) {
      const pct = Math.round(ctx.used_percentage ?? 0);
      const totalTokens = ctx.context_window_size ?? 0;
      const cacheRead = ctx.current_usage?.cache_read_input_tokens ?? 0;
      const cacheCreate = ctx.current_usage?.cache_creation_input_tokens ?? 0;
      const inputTokens = ctx.current_usage?.input_tokens ?? 0;
      const usedTokens = inputTokens + cacheCreate + cacheRead;
      const contextColor = pct >= 85 ? RED : pct >= 70 ? YELLOW : CYAN;
      const bar = progressBar(pct, 10, contextColor);
      line2Parts.push(`Context ${bar} ${pct}% (${formatTokens(usedTokens)}/${formatTokens(totalTokens)})`);
    } else {
      line2Parts.push(`Context ${DIM}░░░░░░░░░░${RESET} ${DIM}--%${RESET}`);
    }
  }

  if (show.cache_hit_rate && ctx) {
    const cacheRead = ctx.current_usage?.cache_read_input_tokens ?? 0;
    const cacheCreate = ctx.current_usage?.cache_creation_input_tokens ?? 0;
    const inputTokens = ctx.current_usage?.input_tokens ?? 0;
    const cacheTotal = cacheRead + cacheCreate;
    if (cacheTotal > 0) {
      const hitRate = Math.round((cacheRead / (cacheTotal + inputTokens)) * 100);
      const hitColor = hitRate >= 80 ? GREEN : hitRate >= 50 ? YELLOW : RED;
      line2Parts.push(`${DIM}Cache${RESET} ${hitColor}${hitRate}%${RESET}`);
    }
  }

  if (show.output_tokens && ctx?.total_output_tokens > 0) {
    line2Parts.push(`${DIM}Out${RESET} ${formatTokens(ctx.total_output_tokens)}`);
  }

  if (line2Parts.length > 0) lines.push(line2Parts.join(sep));

  // Line 3: Rate limits (Team) or Credits (Enterprise) + Session cost + Lines
  {
    const rateParts = [];

    if (isEnterprise && show.credits && usage?.extra_usage) {
      const eu = usage.extra_usage;
      if (eu.monthly_limit != null) {
        const pct = Math.round(eu.utilization ?? 0);
        const bar = progressBar(pct);
        const used = formatCredits(eu.used_credits);
        const limit = formatCredits(eu.monthly_limit);
        rateParts.push(`Credits ${bar} ${pct}% (${used}/${limit})`);
      }
    } else if (!isEnterprise) {
      if (show.rate_5h && usage?.five_hour != null) {
        const fivePct = Math.round(usage.five_hour.utilization ?? 0);
        const fiveBar = progressBar(fivePct);
        let fiveLabel = `5h ${fiveBar} ${fivePct}%`;
        const remaining = formatRemainingTime(usage.five_hour.resets_at);
        if (remaining) fiveLabel += ` (${remaining})`;
        rateParts.push(fiveLabel);
      }

      if (show.rate_7d && usage?.seven_day != null) {
        const sevenPct = Math.round(usage.seven_day.utilization ?? 0);
        const sevenBar = progressBar(sevenPct);
        let sevenLabel = `7d ${sevenBar} ${sevenPct}%`;

        if (show.sub_limits) {
          // Sub-limits: Opus / Sonnet / Claude Design (codename: omelette).
          // Shown only when non-zero — OAuth API currently under-reports Design
          // (returns 0% while web /usage shows actual usage), so hiding 0 avoids
          // misleading display until Anthropic fixes the API.
          const subs = [];
          const opusPct = Math.round(usage.seven_day_opus?.utilization ?? 0);
          if (opusPct > 0) subs.push(`Opus ${opusPct}%`);
          const sonnetPct = Math.round(usage.seven_day_sonnet?.utilization ?? 0);
          if (sonnetPct > 0) subs.push(`Sonnet ${sonnetPct}%`);
          const designPct = Math.round(usage.seven_day_omelette?.utilization ?? 0);
          if (designPct > 0) subs.push(`Design ${designPct}%`);
          if (subs.length > 0) sevenLabel += ` ${DIM}(${subs.join(" · ")})${RESET}`;
        }

        rateParts.push(sevenLabel);
      }
    }

    if (show.session_cost) {
      const cost = formatCost(data?.cost?.total_cost_usd);
      if (cost) {
        let costLabel = `Session ${cost}`;
        const durationMs = data?.cost?.total_duration_ms;
        if (show.cost_velocity && durationMs > 300000) {
          const velocity = (data.cost.total_cost_usd / durationMs) * 3600000;
          costLabel += ` ${DIM}(${formatCost(velocity)}/h)${RESET}`;
        }
        if (show.daily_cost && dailyCost != null && dailyCost > (data?.cost?.total_cost_usd ?? 0) + 0.001) {
          costLabel += ` ${DIM}/ Today ${formatCost(dailyCost)}${RESET}`;
        }
        rateParts.push(costLabel);
      }
    }

    if (show.lines_changed) {
      const added = data?.cost?.total_lines_added;
      const removed = data?.cost?.total_lines_removed;
      if (added || removed) {
        rateParts.push(`${GREEN}+${added || 0}${RESET}${DIM}/${RESET}${RED}-${removed || 0}${RESET}`);
      }
    }

    if (rateParts.length > 0) lines.push(rateParts.join(sep));
  }

  if (show.update_notice && updateStatus?.available) {
    const label = updateStatus.versionMismatch
      ? "⬆ plugin update available"
      : "⬆ HUD update available";
    lines.push(
      `${YELLOW}${label}${RESET} ${DIM}· /gp:update-hud${RESET}`
    );
  }

  return lines.join("\n");
}

// ─── Main ────────────────────────────────────────────────────────────────────

async function main() {
  const data = readStdin();
  const cwd = data?.cwd || process.cwd();

  const effort = getEffortLevel(cwd, data);
  const show = loadHudShow(cwd);
  const { token, subscriptionType } = getOAuthCredentials();
  const updateStatus = checkForUpdates();
  const [gitBranch, usage] = await Promise.all([
    Promise.resolve(getGitInfo(cwd)),
    fetchUsage(token),
  ]);

  const dailyCost = trackDailyCost(data?.cost?.total_cost_usd ?? null);
  const turnCount = getTurnCount(data?.transcript_path);
  const output = render(data, gitBranch, usage, effort, subscriptionType, updateStatus, dailyCost, turnCount, show);
  process.stdout.write(output);
}

main().catch(() => process.exit(0));
