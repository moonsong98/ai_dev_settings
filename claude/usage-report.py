#!/usr/bin/env python3
"""Claude Code usage report — sums per-token costs from local transcripts.

Reads every JSONL under ~/.claude/projects/, totals token usage from
assistant messages, multiplies by per-model pricing, and prints
today / last 7 days / this month / all-time spend.

Local-only. No network calls. Pricing tables are hardcoded — update them
if the published rates change."""

import json
import sys
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from pathlib import Path

# Per-million-token USD pricing (Anthropic public rates, 2026-Q2 baseline)
PRICING = {
    "claude-opus-4":   {"input": 15.0, "output": 75.0, "cache_5m": 18.75, "cache_1h": 30.0, "cache_read": 1.50},
    "claude-sonnet-4": {"input":  3.0, "output": 15.0, "cache_5m":  3.75, "cache_1h":  6.0, "cache_read": 0.30},
    "claude-haiku-4":  {"input":  1.0, "output":  5.0, "cache_5m":  1.25, "cache_1h":  2.0, "cache_read": 0.10},
}


def model_family(model_id: str) -> str | None:
    """Strip patch version to find the pricing family. Returns None for
    synthetic / unknown models so they contribute $0 to totals."""
    if model_id.startswith("claude-opus-4"):
        return "claude-opus-4"
    if model_id.startswith("claude-sonnet-4"):
        return "claude-sonnet-4"
    if model_id.startswith("claude-haiku-4"):
        return "claude-haiku-4"
    return None


def cost_for(model_id: str, usage: dict) -> float:
    fam = model_family(model_id)
    if fam is None:
        return 0.0
    p = PRICING[fam]
    cache = usage.get("cache_creation") or {}
    tokens = {
        "input":      usage.get("input_tokens", 0),
        "output":     usage.get("output_tokens", 0),
        "cache_5m":   cache.get("ephemeral_5m_input_tokens", 0),
        "cache_1h":   cache.get("ephemeral_1h_input_tokens", 0),
        "cache_read": usage.get("cache_read_input_tokens", 0),
    }
    return sum(tokens[k] * p[k] for k in tokens) / 1_000_000.0


def walk_transcripts(base: Path):
    """Yield (timestamp, model, cost) for every billed assistant message."""
    for path in base.glob("*/*.jsonl"):
        try:
            fh = path.open()
        except OSError:
            continue
        with fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    d = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if d.get("type") != "assistant":
                    continue
                msg = d.get("message") or {}
                model = msg.get("model") or ""
                usage = msg.get("usage") or {}
                if not usage:
                    continue
                cost = cost_for(model, usage)
                if cost <= 0:
                    continue
                ts_str = d.get("timestamp") or ""
                try:
                    ts = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
                except ValueError:
                    continue
                yield ts, model, cost


def main() -> int:
    base = Path.home() / ".claude" / "projects"
    if not base.exists():
        print("No ~/.claude/projects/ directory — nothing to report.")
        return 0

    now = datetime.now(timezone.utc).astimezone()  # local TZ
    today = now.date()
    week_start = today - timedelta(days=6)         # rolling 7 days, today inclusive
    month_start = today.replace(day=1)

    totals = {"today": 0.0, "week": 0.0, "month": 0.0, "all": 0.0}
    by_model: dict[str, float] = defaultdict(float)
    by_day: dict[object, float] = defaultdict(float)

    for ts, model, cost in walk_transcripts(base):
        local_day = ts.astimezone().date()
        totals["all"] += cost
        by_model[model] += cost
        by_day[local_day] += cost
        if local_day >= month_start:
            totals["month"] += cost
        if local_day >= week_start:
            totals["week"] += cost
        if local_day == today:
            totals["today"] += cost

    bold = "\033[1m"
    dim = "\033[2m"
    reset = "\033[0m"

    print(f"{bold}Claude Code usage{reset} {dim}({now.strftime('%Y-%m-%d %H:%M %Z')}){reset}")
    print()
    print(f"  Today       ${totals['today']:>8.3f}")
    print(f"  Last 7 days ${totals['week']:>8.3f}")
    print(f"  This month  ${totals['month']:>8.3f}")
    print(f"  All time    ${totals['all']:>8.3f}")

    if by_model:
        print()
        print(f"{bold}By model{reset}")
        for model, cost in sorted(by_model.items(), key=lambda x: -x[1]):
            print(f"  {model:32} ${cost:>8.3f}")

    if by_day:
        print()
        print(f"{bold}Last 7 days{reset}")
        for i in range(6, -1, -1):
            day = today - timedelta(days=i)
            amount = by_day.get(day, 0.0)
            marker = " ← today" if day == today else ""
            print(f"  {day.isoformat()}  ${amount:>8.3f}{marker}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
