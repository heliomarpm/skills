#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
else
  echo "Error: python3 or python is required to parse profiles.json." >&2
  exit 1
fi

PROFILE="core"
CLIENT=""
TARGET=""
MODE="link"
PLUGIN_NAME="sk-engineering-toolbox"
PRUNE=0
FORCE=0
LIST=0
DRY_RUN=0

usage() {
  cat <<'EOF'
Usage: scripts/install.sh [options]
  --profile <name[,name2]>   Comma-separated profile(s) (default: core)
  --client <name>            claude | antigravity | gemini | agents | codex | copilot
  --target <path>            Explicit destination path (overrides --client)
  --mode <link|plugin>       link (default) or plugin
  --plugin-name <name>       Plugin folder name (default: sk-engineering-toolbox)
  --prune                    Remove extra sk-* links not in selected profile
  --force                    Replace or prune non-symlink real directories
  --list                     Show 5 pillars, profiles and estimated tokens/turn
  --dry-run                  Simulate actions without writing to disk
  -h, --help                 Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --profile)
      PROFILE="${2:-}"
      shift 2
      ;;
    --client)
      CLIENT="${2:-}"
      shift 2
      ;;
    --target)
      TARGET="${2:-}"
      shift 2
      ;;
    --mode)
      MODE="${2:-}"
      shift 2
      ;;
    --plugin-name)
      PLUGIN_NAME="${2:-}"
      shift 2
      ;;
    --prune)
      PRUNE=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --list)
      LIST=1
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

exec "$PYTHON_BIN" - "$REPO_ROOT" "$PROFILE" "$CLIENT" "$TARGET" "$MODE" "$PLUGIN_NAME" "$PRUNE" "$FORCE" "$LIST" "$DRY_RUN" <<'PYEOF'
import json
import os
import re
import shutil
import sys

(
    _,
    repo_root,
    profile_spec,
    client,
    target,
    mode,
    plugin_name,
    prune_s,
    force_s,
    list_s,
    dry_run_s,
) = sys.argv

prune = prune_s == "1"
force = force_s == "1"
list_mode = list_s == "1"
dry_run = dry_run_s == "1"

if mode not in ("link", "plugin"):
    print(f"Invalid --mode '{mode}'. Expected 'link' or 'plugin'.", file=sys.stderr)
    sys.exit(1)

if client not in ("", "claude", "antigravity", "gemini", "agents", "codex", "copilot"):
    print(f"Invalid --client '{client}'. Expected claude, antigravity, gemini, agents, codex, or copilot.", file=sys.stderr)
    sys.exit(1)

profiles_path = os.path.join(repo_root, "profiles.json")
skills_root = os.path.join(repo_root, "skills")
rules_core_path = os.path.join(repo_root, "rules", "sk-core.md")

with open(profiles_path, "r", encoding="utf-8") as f:
    config = json.load(f)

pillar_map = {int(p["number"]): list(p["skills"]) for p in config["pillars"]}
profile_map = config["profiles"]


def read_skill_meta(skill_name):
    md_path = os.path.join(skills_root, skill_name, "SKILL.md")
    desc_len = 0
    is_explicit = False
    if os.path.isfile(md_path):
        with open(md_path, "r", encoding="utf-8") as f:
            raw = f.read()
        m = re.match(r"^---\r?\n(.*?)\r?\n---", raw, re.S)
        if m:
            for line in m.group(1).splitlines():
                dm = re.match(r"^\s*description:\s*(.+)$", line)
                if dm:
                    val = dm.group(1).strip()
                    if (val.startswith('"') and val.endswith('"')) or (val.startswith("'") and val.endswith("'")):
                        if len(val) >= 2:
                            val = val[1:-1]
                    desc_len = len(val)
                elif re.match(r"^\s*disable-model-invocation:\s*true\s*$", line):
                    is_explicit = True
    return desc_len, is_explicit


meta_cache = {}
for entry in sorted(os.listdir(skills_root)):
    if entry.startswith("sk-") and os.path.isdir(os.path.join(skills_root, entry)):
        meta_cache[entry] = read_skill_meta(entry)


def resolve_single_profile(name, visiting, ordered, seen):
    if name not in profile_map:
        raise ValueError(f"Unknown profile '{name}'. Run with --list to see available profiles.")
    if name in visiting:
        raise ValueError(f"Cycle detected while resolving profile '{name}'.")
    visiting.add(name)
    prof = profile_map[name]
    for parent in prof.get("extends", []):
        resolve_single_profile(parent, visiting, ordered, seen)
    for p_num in prof.get("pillars", []):
        num = int(p_num)
        if num not in pillar_map:
            raise ValueError(f"Unknown pillar '{num}' in profile '{name}'.")
        for sk in pillar_map[num]:
            if sk not in seen:
                seen.add(sk)
                ordered.append(sk)
    for sk in prof.get("skills", []):
        if sk not in seen:
            seen.add(sk)
            ordered.append(sk)
    visiting.remove(name)


def resolve_profile_spec(spec):
    parts = [p.strip() for p in spec.split(",") if p.strip()]
    if not parts:
        raise ValueError("Profile parameter cannot be empty.")
    ordered = []
    seen = set()
    visiting = set()
    for p in parts:
        resolve_single_profile(p, visiting, ordered, seen)
    return ordered


def token_stats(skills):
    imp_chars = 0
    imp_count = 0
    exp_count = 0
    for sk in skills:
        if sk in meta_cache:
            dlen, expl = meta_cache[sk]
            if expl:
                exp_count += 1
            else:
                imp_count += 1
                imp_chars += dlen
    return len(skills), imp_count, exp_count, round(imp_chars / 3.7)


if list_mode:
    print("=== 5 Pillars ===")
    for p in sorted(config["pillars"], key=lambda x: int(x["number"])):
        tag = " [explicit-only]" if p.get("explicitOnly") else ""
        print(f"Pillar {p['number']}: {p['name']} ({len(p['skills'])} skills){tag}")
        print(f"  Skills: {', '.join(p['skills'])}")
    print("")
    print("=== Profiles ===")
    for name, prof in profile_map.items():
        resolved = resolve_profile_spec(name)
        tot, imp, exp, tok = token_stats(resolved)
        print(f"{name:<22} | {tot:>2} skills ({imp:>2} impl, {exp:>1} expl) | ~{tok:>4} tok/turn | {prof.get('description', '')}")
    sys.exit(0)

if not target and not client:
    print("Error: specify --client <claude|antigravity|gemini|agents|codex|copilot> or --target <path> (or --list).", file=sys.stderr)
    sys.exit(1)

if target:
    resolved_target = os.path.abspath(os.path.expanduser(target))
else:
    home = os.path.expanduser("~")
    if mode == "link":
        client_dirs = {
            "claude": os.path.join(home, ".claude", "skills"),
            "antigravity": os.path.join(home, ".gemini", "config", "skills"),
            "gemini": os.path.join(home, ".gemini", "config", "skills"),
            "codex": os.path.join(home, ".codex", "skills"),
            "copilot": os.path.join(home, ".copilot", "skills"),
            "agents": os.path.join(home, ".agents", "skills"),
            "default": os.path.join(home, ".agents", "skills"),
        }
    else:
        client_dirs = {
            "claude": os.path.join(home, ".claude", "plugins"),
            "antigravity": os.path.join(home, ".gemini", "config", "plugins"),
            "gemini": os.path.join(home, ".gemini", "config", "plugins"),
            "codex": os.path.join(home, ".codex", "plugins"),
            "copilot": os.path.join(home, ".copilot", "plugins"),
            "agents": os.path.join(home, ".agents", "plugins"),
            "default": os.path.join(home, ".agents", "plugins"),
        }
    resolved_target = os.path.abspath(client_dirs[client])

try:
    selected_skills = resolve_profile_spec(profile_spec)
except ValueError as exc:
    print(f"Error: {exc}", file=sys.stderr)
    sys.exit(1)

for sk in selected_skills:
    src_check = os.path.join(skills_root, sk)
    if not os.path.isdir(src_check):
        print(f"Error: skill directory missing in repository: {src_check}", file=sys.stderr)
        sys.exit(1)

tot, imp, exp, est_tokens = token_stats(selected_skills)
print(f"Profile: {profile_spec} | Mode: {mode} | Target: {resolved_target}")
print(f"Selected: {tot} skills ({imp} implicit, {exp} explicit) | Estimated fixed cost: ~{est_tokens} tok/turn")
if dry_run:
    print("[DRY-RUN] No filesystem changes will be written.")

skills_dest = resolved_target
if mode == "plugin":
    if not re.match(r"^[a-zA-Z0-9][a-zA-Z0-9._-]*$", plugin_name):
        print(f"Error: invalid --plugin-name '{plugin_name}'.", file=sys.stderr)
        sys.exit(1)
    if not os.path.isfile(rules_core_path):
        print(f"Error: Layer 0 rules file not found: {rules_core_path}", file=sys.stderr)
        sys.exit(1)
    plugin_root = os.path.join(resolved_target, plugin_name)
    plugin_json_path = os.path.join(plugin_root, "plugin.json")
    plugin_rules_dir = os.path.join(plugin_root, "rules")
    plugin_agents_path = os.path.join(plugin_rules_dir, "AGENTS.md")
    skills_dest = os.path.join(plugin_root, "skills")

    defaults = config["pluginDefaults"]
    manifest = {
        "name": plugin_name,
        "displayName": "SK Engineering Toolbox",
        "description": f"{defaults['description']} (profile: {profile_spec})",
        "author": defaults["author"],
        "homepage": defaults["homepage"],
        "repository": defaults["repository"],
    }
    if dry_run:
        print(f"[WRITE] {plugin_json_path}")
        print(f"[COPY]  {rules_core_path} -> {plugin_agents_path}")
    else:
        os.makedirs(skills_dest, exist_ok=True)
        os.makedirs(plugin_rules_dir, exist_ok=True)
        with open(plugin_json_path, "w", encoding="utf-8", newline="\n") as f:
            f.write(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n")
        with open(rules_core_path, "r", encoding="utf-8") as rf:
            rules_text = rf.read().replace("\r\n", "\n")
        with open(plugin_agents_path, "w", encoding="utf-8", newline="\n") as wf:
            wf.write(rules_text)
        print(f"[OK]    plugin.json and rules/AGENTS.md written in {plugin_root}")
elif not dry_run:
    os.makedirs(skills_dest, exist_ok=True)

created = updated = unchanged = skipped = pruned = 0

for sk in selected_skills:
    src = os.path.abspath(os.path.join(skills_root, sk))
    dst = os.path.join(skills_dest, sk)
    if os.path.lexists(dst):
        if os.path.islink(dst):
            cur = os.path.realpath(dst)
            if cur == os.path.realpath(src):
                unchanged += 1
                print(f"[OK]     {sk}")
            else:
                updated += 1
                print(f"[UPDATE] {sk} -> {src}")
                if not dry_run:
                    os.unlink(dst)
                    os.symlink(src, dst, target_is_directory=True)
        elif force:
            updated += 1
            print(f"[REPLACE] {sk} -> {src}")
            if not dry_run:
                if os.path.isdir(dst):
                    shutil.rmtree(dst)
                else:
                    os.unlink(dst)
                os.symlink(src, dst, target_is_directory=True)
        else:
            skipped += 1
            print(f"[SKIP] {sk} already exists as a real entry (use --force to replace)", file=sys.stderr)
    else:
        created += 1
        print(f"[LINK]   {sk} -> {src}")
        if not dry_run:
            os.symlink(src, dst, target_is_directory=True)

if prune and os.path.isdir(skills_dest):
    selected_set = set(selected_skills)
    for entry in sorted(os.listdir(skills_dest)):
        if not entry.startswith("sk-"):
            continue
        if entry in selected_set:
            continue
        cand = os.path.join(skills_dest, entry)
        if os.path.islink(cand):
            pruned += 1
            print(f"[PRUNE]  {entry}")
            if not dry_run:
                os.unlink(cand)
        elif force:
            pruned += 1
            print(f"[PRUNE-FORCE] {entry}")
            if not dry_run:
                if os.path.isdir(cand):
                    shutil.rmtree(cand)
                else:
                    os.unlink(cand)
        else:
            skipped += 1
            print(f"[SKIP-PRUNE] {entry} is a real directory (use --force to remove)", file=sys.stderr)

print("")
print(f"Summary: created={created}, updated={updated}, ok={unchanged}, pruned={pruned}, skipped={skipped} | Fixed cost: ~{est_tokens} tok/turn")
PYEOF
