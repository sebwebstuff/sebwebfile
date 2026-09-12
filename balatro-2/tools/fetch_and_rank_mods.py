import json
import os
import re
import urllib.request
from datetime import datetime, timezone

THUNDERSTORE_API = "https://thunderstore.io/c/balatro/api/v1/package/"
HTTP_HEADERS = {
    "User-Agent": "BalatroeModFetcher/1.0 (+https://thunderstore.io)",
    "Accept": "application/json, */*;q=0.8",
}

MODS = [
    {"name": "MoreSpeed", "provider": "thunderstore", "difficulty": 2, "reason": "Gameplay speed tweak; likely hooks game loop/timers."},
    {"name": "MikasModCollection", "provider": "thunderstore", "difficulty": 5, "reason": "Collection packs are typically broad and high surface area."},
    {"name": "ThemedJokers", "provider": "thunderstore", "difficulty": 3, "reason": "Mostly content and joker behavior additions."},
    {"name": "JankJonklers", "provider": "thunderstore", "difficulty": 3, "reason": "Joker content mod with moderate behavior complexity."},
    {"name": "Mor Jokers", "provider": "thunderstore", "difficulty": 3, "reason": "Additional joker pack, moderate scripting complexity."},
    {"name": "JSUtils", "provider": "thunderstore", "difficulty": 5, "reason": "Utility/foundation mod likely relied upon by others."},
    {"name": "Buffoon Deck", "provider": "thunderstore", "difficulty": 2, "reason": "Single deck/mechanic extension."},
    {"name": "High Card Mod", "provider": "thunderstore", "difficulty": 2, "reason": "Rules/scoring tweak with limited scope."},
    {"name": "MobileLikeDragging", "provider": "thunderstore", "difficulty": 4, "reason": "Input/UI interaction layer changes."},
    {"name": "SubtleAdditions", "provider": "thunderstore", "difficulty": 2, "reason": "Small additive content/features."},
    {"name": "PestricaJoker", "provider": "thunderstore", "difficulty": 2, "reason": "Single/few joker implementation."},
    {"name": "Chudjoker", "provider": "thunderstore", "difficulty": 2, "reason": "Small joker add-on."},
    {"name": "JevilsCard", "provider": "thunderstore", "difficulty": 3, "reason": "Custom card behavior with likely event hooks."},
    {"name": "Lord Minimus", "provider": "thunderstore", "difficulty": 2, "reason": "Likely focused content mod."},
    {"name": "Showdown", "provider": "thunderstore", "difficulty": 4, "reason": "Could alter progression/challenge flow."},
    {"name": "JokerDisplay", "provider": "thunderstore", "difficulty": 3, "reason": "UI overlay and rendering adjustments."},
    {"name": "Frost Utils", "provider": "thunderstore", "difficulty": 5, "reason": "Low-level utility dependency layer."},
    {"name": "Baldatro", "provider": "thunderstore", "difficulty": 3, "reason": "Likely content+presentation changes."},
    {"name": "Pokermon", "provider": "nexus", "difficulty": 4, "reason": "Large themed content/system crossover."},
    {"name": "Balatro Plus", "provider": "nexus", "difficulty": 4, "reason": "Broad expansion-style mod scope."},
    {"name": "Power Creep Joker", "provider": "nexus", "difficulty": 2, "reason": "Focused joker balance/content change."},
]


def slugify(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "", text.lower())


def current_utc_timestamp() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def fetch_json(url: str):
    req = urllib.request.Request(url, headers=HTTP_HEADERS)
    with urllib.request.urlopen(req) as resp:
        return json.loads(resp.read().decode("utf-8"))


def fetch_binary(url: str) -> bytes:
    req = urllib.request.Request(url, headers=HTTP_HEADERS)
    with urllib.request.urlopen(req) as resp:
        return resp.read()


def find_thunderstore_mod(all_mods, target_name: str):
    target_slug = slugify(target_name)
    best = None
    for item in all_mods:
        candidates = [
            item.get("name", ""),
            item.get("full_name", ""),
            item.get("package_name", ""),
            item.get("owner", ""),
            item.get("description", ""),
        ]
        score = 0
        for cand in candidates:
            s = slugify(str(cand))
            if s == target_slug:
                score = max(score, 100)
            elif target_slug in s:
                score = max(score, 60)
        if score > 0:
            versions = item.get("versions") or []
            latest = versions[0] if versions else {}
            downloads = int(latest.get("downloads") or item.get("total_downloads") or 0)
            rank = (score, downloads)
            if not best or rank > best[0]:
                best = (rank, item)
    return best[1] if best else None


def write_porting_queue(path: str, mods):
    rows = sorted(mods, key=lambda m: (m["difficulty"], m["name"].lower()))
    lines = [
        "# Porting Queue (Easy -> Hard)",
        "",
        f"Generated: {current_utc_timestamp()}",
        "",
        "| Priority | Mod | Provider | Difficulty (1-5) | Rationale |",
        "|---|---|---|---:|---|",
    ]
    for idx, mod in enumerate(rows, start=1):
        lines.append(
            f"| {idx} | {mod['name']} | {mod['provider']} | {mod['difficulty']} | {mod['reason']} |"
        )
    with open(path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")


def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    out_dir = os.path.join(base_dir, "downloaded_mods")
    os.makedirs(out_dir, exist_ok=True)

    thunderstore_data = []
    try:
        thunderstore_data = fetch_json(THUNDERSTORE_API)
    except Exception as exc:
        print(f"[WARN] Thunderstore fetch failed: {exc}")

    report = {
        "generated_utc": current_utc_timestamp(),
        "mods": [],
        "notes": [
            "Nexus direct downloads generally require authenticated API access.",
            "For Nexus mods, this script records placeholders unless explicit file URLs are provided.",
        ],
    }

    for mod in MODS:
        entry = {
            "name": mod["name"],
            "provider": mod["provider"],
            "difficulty": mod["difficulty"],
            "reason": mod["reason"],
            "status": "pending",
        }

        if mod["provider"] == "thunderstore" and thunderstore_data:
            match = find_thunderstore_mod(thunderstore_data, mod["name"])
            if not match:
                entry["status"] = "not_found"
            else:
                versions = match.get("versions") or []
                latest = versions[0] if versions else {}
                download_url = latest.get("download_url") or ""
                entry["matched_full_name"] = match.get("full_name")
                entry["download_url"] = download_url
                if download_url:
                    safe_name = re.sub(r"[^a-zA-Z0-9._-]+", "_", mod["name"]).strip("_") or "mod"
                    out_path = os.path.join(out_dir, safe_name + ".zip")
                    try:
                        data = fetch_binary(download_url)
                        with open(out_path, "wb") as f:
                            f.write(data)
                        entry["status"] = "downloaded"
                        entry["saved_to"] = out_path
                    except Exception as exc:
                        entry["status"] = "download_failed"
                        entry["error"] = str(exc)
                else:
                    entry["status"] = "no_download_url"

        elif mod["provider"] == "nexus":
            entry["status"] = "manual_needed"
            entry["note"] = "Provide Nexus API key + mod file URLs for automated fetch."

        report["mods"].append(entry)

    report_path = os.path.join(base_dir, "mod_fetch_report.json")
    with open(report_path, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)

    queue_path = os.path.join(base_dir, "porting_queue.md")
    write_porting_queue(queue_path, MODS)

    print(f"Wrote report: {report_path}")
    print(f"Wrote queue: {queue_path}")
    print(f"Downloaded files dir: {out_dir}")


if __name__ == "__main__":
    main()
