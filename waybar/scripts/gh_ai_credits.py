#!/usr/bin/env python3
"""Waybar module: percentage of the included monthly AI credit allowance used.

Prints Waybar JSON:  {"text": "53.1%", "tooltip": "4,748 / 9,000", "class": ...}
The class compares current usage with the plan line (PLAN_PCT of the allowance
spread evenly over the month), with a +-BAND_PCT dead zone:
  under  - under plan by more than BAND_PCT of the allowance
  normal - within +-BAND_PCT of plan
  over   - over plan by more than BAND_PCT of the allowance

API calls: 1 (usage). The allowance needs a 2nd call (copilot/billing) only on
a cache miss; it is cached in /tmp for --ttl seconds (default 24h).

Usage:  GH_TOKEN=... GH_ORG=... ./gh_ai_credits.py [--ttl SECONDS]
        --ttl 0 forces the allowance to be re-derived.
"""
import argparse
import calendar
import datetime as dt
import json
import os
import sys
import syslog
import time
import urllib.error
import urllib.request

PER_SEAT_USD = {"business": 30, "enterprise": 70}  # promotional rate, 2026
PLAN_PCT = 95  # target consumption at month end
BAND_PCT = 5   # dead zone around the plan line, in % of the allowance
CACHE = "/tmp/gh_ai_credits_allowance.json"


def log(msg):
    """stderr when run interactively, journal (journalctl -t gh_ai_credits)
    otherwise -- under Waybar stderr is inherited from the compositor and lost."""
    if sys.stderr.isatty():
        print(msg, file=sys.stderr)
    else:
        syslog.openlog("gh_ai_credits", syslog.LOG_PID)
        syslog.syslog(syslog.LOG_INFO, msg)


def month_elapsed(now=None):
    """Fraction of the current billing month already gone (0 < x <= 1)."""
    now = now or dt.datetime.now()
    days = calendar.monthrange(now.year, now.month)[1]
    return ((now.day - 1) + (now.hour * 3600 + now.minute * 60 + now.second) / 86400) / days


def api(path, token):
    req = urllib.request.Request("https://api.github.com" + path, headers={
        "Accept": "application/vnd.github+json",
        "Authorization": f"Bearer {token}",
        "X-GitHub-Api-Version": "2026-03-10",
    })
    t = time.monotonic()
    status, remaining = "ERR", "?"
    try:
        with urllib.request.urlopen(req) as r:
            body = json.load(r)
            status, remaining = r.status, r.headers.get("x-ratelimit-remaining", "?")
            return body
    except urllib.error.HTTPError as e:
        status, remaining = e.code, e.headers.get("x-ratelimit-remaining", "?")
        raise
    finally:
        log(f"[api] GET {path} -> {status} "
            f"({(time.monotonic() - t) * 1000:.0f}ms, ratelimit-remaining={remaining})")


def cache_get(org, ttl):
    try:
        e = json.load(open(CACHE))[org]
        return e["allowance"] if time.time() - e["ts"] < ttl else None
    except Exception:
        return None


def cache_put(org, allowance):
    try:
        data = json.load(open(CACHE))
    except Exception:
        data = {}
    data[org] = {"allowance": allowance, "ts": time.time()}
    tmp = CACHE + f".{os.getpid()}"
    with open(tmp, "w") as f:
        json.dump(data, f)
    os.replace(tmp, CACHE)


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--ttl", type=int, default=86400, help="allowance cache TTL, seconds")
    a = p.parse_args()
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    org = os.environ.get("GH_ORG")
    if not token:
        sys.exit("set GH_TOKEN")
    if not org:
        sys.exit("set GH_ORG")

    items = api(f"/organizations/{org}/settings/billing/ai_credit/usage", token)["usageItems"]
    total = lambda k: sum(i.get(k, 0) for i in items)
    used = total("grossQuantity")

    allowance = None
    if total("netQuantity") > 0:                      # overage -> allowance is in this response
        allowance = total("discountQuantity")
        cache_put(org, allowance)
    if not allowance:
        allowance = cache_get(org, a.ttl)
    if not allowance:                                 # 2nd call: seats x per-seat $ / credit price
        b = api(f"/orgs/{org}/copilot/billing", token)
        price = next(i["pricePerUnit"] for i in items if i.get("pricePerUnit"))
        allowance = b["seat_breakdown"]["total"] * PER_SEAT_USD[b["plan_type"].lower()] / price
        cache_put(org, allowance)

    pct = used / allowance * 100
    plan = PLAN_PCT * month_elapsed()                   # where usage should be right now
    print(json.dumps({
        "text": f"{pct:.1f}%",
        "tooltip": f"{used:,.0f} / {allowance:,.0f}",
        "class": "under" if pct < plan - BAND_PCT else
                 "over" if pct > plan + BAND_PCT else "normal",
    }))


if __name__ == "__main__":
    main()
