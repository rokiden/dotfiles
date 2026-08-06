#!/usr/bin/env python3
"""Waybar module: percentage of the included monthly AI credit allowance used.

Prints Waybar JSON:  {"text": "53.1%", "tooltip": "4,748 / 9,000", "class": ...}
The class compares current usage with the plan line (PLAN_PCT of the allowance
spread evenly over the month), with a +-BAND_PCT dead zone:
  under  - under plan by more than BAND_PCT of the allowance
  normal - within +-BAND_PCT of plan
  over   - over plan by more than BAND_PCT of the allowance

API calls: organization mode uses 1 usage call plus copilot/billing on an
allowance cache miss; user mode uses one copilot_internal/user call for both
current usage and allowance. Organization allowances are cached in /tmp for
--ttl seconds (default 24h).

Usage:  GH_TOKEN=... GH_ORG=... ./gh_ai_credits.py [--ttl SECONDS]
   or:  GH_TOKEN=... GH_USER=... ./gh_ai_credits.py [--ttl SECONDS]
        --ttl 0 forces the organization allowance to be re-derived; user
        mode always refreshes its quota.
"""
import argparse
import calendar
import datetime as dt
import json
import math
import os
import sys
import syslog
import time
import urllib.error
import urllib.request
from urllib.parse import quote

PER_SEAT_USD = {"business": 30, "enterprise": 70}  # promotional rate, 2026
PLAN_PCT = 99  # target consumption at month end
BAND_PCT = 5   # dead zone around the plan line, in % of the allowance
CACHE = "/tmp/gh_ai_credits_allowance.json"
API_TIMEOUT = 15


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
        with urllib.request.urlopen(req, timeout=API_TIMEOUT) as r:
            body = json.load(r)
            status, remaining = r.status, r.headers.get("x-ratelimit-remaining", "?")
            return body
    except urllib.error.HTTPError as e:
        status, remaining = e.code, e.headers.get("x-ratelimit-remaining", "?")
        raise
    finally:
        log(f"[api] GET {path} -> {status} "
            f"({(time.monotonic() - t) * 1000:.0f}ms, ratelimit-remaining={remaining})")


def cache_get(account, ttl):
    try:
        with open(CACHE, encoding="utf-8") as f:
            entry = json.load(f)[account]
        allowance = float(entry["allowance"])
        return allowance if math.isfinite(allowance) and allowance > 0 and \
            time.time() - entry["ts"] < ttl else None
    except Exception:
        return None


def cache_put(account, allowance):
    try:
        with open(CACHE, encoding="utf-8") as f:
            data = json.load(f)
    except Exception:
        data = {}
    data[account] = {"allowance": allowance, "ts": time.time()}
    tmp = CACHE + f".{os.getpid()}"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(data, f)
    os.replace(tmp, CACHE)


def finite_number(value):
    try:
        value = float(value)
    except (TypeError, ValueError):
        return None
    return value if math.isfinite(value) else None


def positive_number(value):
    value = finite_number(value)
    return value if value is not None and value > 0 else None


def nonnegative_number(value):
    value = finite_number(value)
    return value if value is not None and value >= 0 else None


def as_object(value, description):
    if not isinstance(value, dict):
        raise ValueError(f"{description} is not an object")
    return value


def usage_total(items, field):
    total = 0.0
    for item in items:
        if not isinstance(item, dict):
            raise ValueError("billing usage item is not an object")
        value = finite_number(item.get(field, 0))
        if value is None:
            raise ValueError(f"billing usage field {field} is not numeric")
        total += value
    return total


def personal_usage_and_allowance(token):
    """Read personal current usage and allowance in one quota API call.

    /copilot_internal/user is undocumented, but currently exposes both the
    included entitlement and the remaining premium-interaction quota.
    """
    data = api("/copilot_internal/user", token)
    if not isinstance(data, dict):
        raise ValueError("Copilot quota response is not an object")
    snapshots = data.get("quota_snapshots", {})
    interactions = (
        snapshots.get("premium_interactions")
        if isinstance(snapshots, dict) else None
    )
    if not isinstance(interactions, dict):
        raise ValueError("Copilot quota response has no premium_interactions")

    allowance = positive_number(interactions.get("entitlement"))
    if allowance is None:
        raise ValueError("Copilot quota response has no finite allowance")
    if interactions.get("unlimited") is True:
        raise ValueError("Copilot quota is unlimited")

    # quota_remaining preserves the fractional included-quota value. The
    # token-based response may omit token_based_billing, so positive quota
    # fields—not that flag—determine current usage.
    quota_remaining = finite_number(interactions.get("quota_remaining"))
    remaining = finite_number(interactions.get("remaining"))
    if quota_remaining is None and remaining is None:
        raise ValueError("Copilot quota response has no remaining value")

    if quota_remaining is not None:
        included_used = max(0, allowance - max(0, quota_remaining))
    elif remaining is not None:
        included_used = max(0, allowance - max(0, remaining))
    else:
        included_used = 0

    overage = nonnegative_number(interactions.get("overage_count")) or 0
    reported_overage = max(0, -remaining) if remaining is not None else 0
    used = included_used + max(overage, reported_overage)
    return used, allowance


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--ttl", type=int, default=86400,
                   help="organization allowance cache TTL (user mode always refreshes)")
    a = p.parse_args()
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    org = os.environ.get("GH_ORG")
    user = os.environ.get("GH_USER")
    if not token:
        sys.exit("set GH_TOKEN")
    if org and user:
        sys.exit("set only one of GH_ORG or GH_USER")
    if not org and not user:
        sys.exit("set GH_ORG or GH_USER")

    items = None
    if org:
        mode, identity = "org", org
        cache_key = f"{mode}:{identity}"
        usage_path = f"/organizations/{quote(org, safe='')}/settings/billing/ai_credit/usage"
        usage_response = as_object(api(usage_path, token), "billing usage response")
        items = usage_response.get("usageItems", [])
        if not isinstance(items, list):
            raise ValueError("billing usage response has no usageItems list")
        used = usage_total(items, "grossQuantity")
        net = usage_total(items, "netQuantity")

        allowance = None
        if net > 0:                                    # overage -> allowance is in this response
            allowance = positive_number(usage_total(items, "discountQuantity"))
            if allowance:
                cache_put(cache_key, allowance)
        if not allowance:
            allowance = cache_get(cache_key, a.ttl)

        if not allowance:                              # seats x plan price / credit price
            price = None
            for item in items:
                candidate = positive_number(item.get("pricePerUnit"))
                if candidate is not None:
                    price = candidate
                    break
            if price:
                billing = as_object(
                    api(f"/orgs/{quote(org, safe='')}/copilot/billing", token),
                    "Copilot billing response",
                )
                plan_type = billing.get("plan_type")
                if not isinstance(plan_type, str):
                    raise ValueError("Copilot billing response has no plan_type")
                seat_breakdown = as_object(
                    billing.get("seat_breakdown"),
                    "Copilot billing seat_breakdown",
                )
                seat_count = nonnegative_number(seat_breakdown.get("total"))
                if seat_count is None:
                    raise ValueError("Copilot billing response has no numeric seat total")
                seat_price = PER_SEAT_USD.get(plan_type.lower())
                if seat_price is None:
                    raise ValueError(f"unsupported Copilot plan type: {plan_type}")
                allowance = positive_number(seat_count * seat_price / price)
                if allowance:
                    cache_put(cache_key, allowance)
    else:
        try:
            # One call supplies both current usage and the included allowance.
            used, allowance = personal_usage_and_allowance(token)
        except (urllib.error.HTTPError, urllib.error.URLError, ValueError, TypeError) as e:
            log(f"personal quota lookup failed: {e}")
            print(json.dumps({"text": "\u2026", "tooltip": "personal AI credit quota unavailable"}))
            return

    if not allowance:
        log("no allowance available -- can't derive included AI credit allowance")
        tooltip = ("no AI credit usage recorded or allowance available"
                   if org and not items else "AI credit allowance unavailable")
        print(json.dumps({"text": "\u2026", "tooltip": tooltip}))
        return

    pct = used / allowance * 100
    plan = PLAN_PCT * month_elapsed()                   # where usage should be right now
    print(json.dumps({
        "text": f"{pct:.1f}%",
        "tooltip": f"{used:,.0f} / {allowance:,.0f}",
        "class": "under" if pct < plan - BAND_PCT else
                 "over" if pct > plan + BAND_PCT else "normal",
    }))


if __name__ == "__main__":
    try:
        main()
    except (urllib.error.URLError, OSError, ValueError, TypeError, KeyError, AttributeError) as e:
        log(f"GitHub AI credit request failed: {e}")
        print(json.dumps({
            "text": "\u2026",
            "tooltip": "GitHub AI credit data unavailable",
        }))
