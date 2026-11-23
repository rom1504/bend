#!/usr/bin/env python3
"""Static Match-Bomb & Giant-Function Scanner across k12_wave10/m00..m11.

Scans all ~8,930 defs in research/agy/w10_mod_bend/k12_wave10/m00.bend..m11.bend for:
  (a) Deeply nested `match` patterns (max constructor nesting depth >= 4,
      overlapping arms, U32/string literals in patterns, wildcard fallback)
      — potential exponential `ff_match` / `f_hit_row` blowup cliffs.
  (b) Largest function bodies (line count, token/AST size, let/match counts)
      — potential `-O2` register-allocation / x198pw_plan cliffs.
"""
from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
K12_DIR = ROOT / "research/agy/w10_mod_bend/k12_wave10"

DEF_RE = re.compile(r"^def\s+([A-Za-z0-9_.\$]+)\s*[\(:]")
TOP_DECL_RE = re.compile(r"^(?:def|law|type|@unsafe|import)\b")
TOKEN_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_.\$]*|\d+|\"[^\"]*\"|[{}()\[\],:]")
CTOR_RE = re.compile(r"([A-Z][A-Za-z0-9_]*)\s*\{")


def max_brace_depth(pattern: str) -> int:
    """Compute max nested `{ ... }` (and `[ ... ]`) depth in a case pattern."""
    depth = 0
    max_d = 0
    in_str = False
    esc = False
    for ch in pattern:
        if in_str:
            if esc:
                esc = False
            elif ch == "\\":
                esc = True
            elif ch == '"':
                in_str = False
            continue
        if ch == '"':
            in_str = True
        elif ch in "{[":
            depth += 1
            if depth > max_d:
                max_d = depth
        elif ch in "}]":
            if depth > 0:
                depth -= 1
    return max_d


def pattern_head_ctor(pattern: str) -> str:
    p = pattern.strip()
    if p == "_" or p.startswith("_ "):
        return "_"
    m = re.match(r"^\+?([A-Z][A-Za-z0-9_]*)\s*\{", p)
    if m:
        return m.group(1)
    m2 = re.match(r"^\+?([A-Za-z0-9_\"']+)", p)
    return m2.group(1) if m2 else p[:16]


def has_literal_in_pattern(pattern: str) -> bool:
    # Check for numeric literals (e.g., 0, 1, 5) or string literals inside braces
    if '"' in pattern:
        return True
    # Strip identifiers so digits inside names like N111Call aren't counted
    stripped = re.sub(r"[A-Za-z_][A-Za-z0-9_]*", "", pattern)
    return bool(re.search(r"\b\d+\b", stripped))


def analyze_match_blocks(body_lines: list[str]) -> dict:
    """Extract match blocks and their case patterns from a def body."""
    matches = []
    i = 0
    n = len(body_lines)
    while i < n:
        line = body_lines[i]
        stripped = line.lstrip()
        if stripped.startswith("match "):
            indent = len(line) - len(stripped)
            arms: list[str] = []
            j = i + 1
            while j < n:
                l2 = body_lines[j]
                s2 = l2.lstrip()
                if not s2 or s2.startswith("#"):
                    j += 1
                    continue
                ind2 = len(l2) - len(s2)
                if ind2 <= indent:
                    break
                if s2.startswith("case "):
                    # Accumulate pattern up to ':' (may span lines if braces open)
                    pat_text = s2[5:]
                    brace_bal = pat_text.count("{") - pat_text.count("}")
                    k = j
                    while brace_bal > 0 and k + 1 < n:
                        k += 1
                        nxt = body_lines[k].strip()
                        pat_text += " " + nxt
                        brace_bal += nxt.count("{") - nxt.count("}")
                    # Split at the top-level ':' after balanced braces
                    pat_only = ""
                    d = 0
                    in_s = False
                    esc = False
                    for ch in pat_text:
                        if in_s:
                            pat_only += ch
                            if esc:
                                esc = False
                            elif ch == "\\":
                                esc = True
                            elif ch == '"':
                                in_s = False
                            continue
                        if ch == '"':
                            in_s = True
                            pat_only += ch
                        elif ch in "{[":
                            d += 1
                            pat_only += ch
                        elif ch in "}]":
                            d = max(0, d - 1)
                            pat_only += ch
                        elif ch == ":" and d == 0:
                            break
                        else:
                            pat_only += ch
                    arms.append(pat_only.strip())
                    j = k + 1
                else:
                    j += 1
            if arms:
                depths = [max_brace_depth(a) for a in arms]
                heads = [pattern_head_ctor(a) for a in arms]
                max_d = max(depths)
                deep_arms = sum(1 for d in depths if d >= 4)
                depth3_arms = sum(1 for d in depths if d >= 3)
                has_wild = any(a == "_" or re.match(r"^\+?[a-z_][A-Za-z0-9_]*$", a) for a in arms)
                # Overlapping heads: same outer constructor repeated in >=2 arms
                ctor_counts: dict[str, int] = {}
                for h in heads:
                    if h != "_" and h and h[0].isupper():
                        ctor_counts[h] = ctor_counts.get(h, 0) + 1
                max_overlap = max(ctor_counts.values(), default=0)
                lit_arms = sum(1 for a, d in zip(arms, depths) if d >= 2 and has_literal_in_pattern(a))
                # Risk score emphasizing depth >= 4 + overlapping arms + literals + wildcard
                risk = 0.0
                if max_d >= 3:
                    risk = (
                        (2 ** min(max_d, 10))
                        * (1 + 0.8 * deep_arms + 0.3 * depth3_arms)
                        * (1 + 0.5 * max(0, max_overlap - 1))
                        * (1.5 if has_wild else 1.0)
                        * (1 + 0.5 * lit_arms)
                    )
                matches.append({
                    "arms": len(arms),
                    "max_depth": max_d,
                    "deep_arms_ge4": deep_arms,
                    "depth3_arms": depth3_arms,
                    "max_head_overlap": max_overlap,
                    "lit_arms": lit_arms,
                    "has_wildcard": has_wild,
                    "risk": round(risk, 1),
                })
        i += 1
    if not matches:
        return {
            "match_count": 0,
            "total_cases": 0,
            "max_depth": 0,
            "max_deep_arms_ge4": 0,
            "max_head_overlap": 0,
            "max_lit_arms": 0,
            "has_wildcard_in_deepest": False,
            "max_risk": 0.0,
        }
    best = max(matches, key=lambda m: (m["risk"], m["max_depth"], m["arms"]))
    return {
        "match_count": len(matches),
        "total_cases": sum(m["arms"] for m in matches),
        "max_depth": max(m["max_depth"] for m in matches),
        "max_deep_arms_ge4": best["deep_arms_ge4"],
        "max_head_overlap": best["max_head_overlap"],
        "max_lit_arms": best["lit_arms"],
        "has_wildcard_in_deepest": best["has_wildcard"],
        "max_risk": best["risk"],
    }


def scan_module(mod_name: str, path: Path) -> list[dict]:
    lines = path.read_text(encoding="utf-8").splitlines()
    n = len(lines)
    defs: list[dict] = []
    i = 0
    while i < n:
        m = DEF_RE.match(lines[i])
        if not m:
            i += 1
            continue
        fn_name = m.group(1)
        start_line = i + 1
        j = i + 1
        while j < n:
            if lines[j] and not lines[j][0].isspace() and not lines[j].startswith("#"):
                break
            j += 1
        # Trim trailing blank/comment lines
        end_idx = j
        while end_idx > i + 1 and (not lines[end_idx - 1].strip() or lines[end_idx - 1].lstrip().startswith("#")):
            end_idx -= 1
        body = lines[i:end_idx]
        text = "\n".join(body)
        non_blank = sum(1 for l in body if l.strip() and not l.lstrip().startswith("#"))
        tokens = len(TOKEN_RE.findall(text))
        lets = sum(1 for l in body if re.match(r"^\s*\+?[a-zA-Z_][A-Za-z0-9_]*\s*(?::[^=]+)?=\s", l))
        match_info = analyze_match_blocks(body)
        defs.append({
            "module": mod_name,
            "fn": fn_name,
            "line": start_line,
            "lines": len(body),
            "non_blank_lines": non_blank,
            "chars": len(text),
            "tokens": tokens,
            "lets": lets,
            **match_info,
        })
        i = j
    return defs


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--top", type=int, default=25)
    ap.add_argument("--json", type=Path, default=None)
    args = ap.parse_args()

    all_defs: list[dict] = []
    for idx in range(12):
        m = f"m{idx:02d}"
        all_defs.extend(scan_module(m, K12_DIR / f"{m}.bend"))

    print(f"Scanned {len(all_defs)} defs across m00..m11.")
    print()

    # (a) Match-bomb suspects (depth >= 4 or top risk)
    by_risk = sorted(
        [d for d in all_defs if d["max_depth"] >= 4],
        key=lambda d: (-d["max_risk"], -d["max_depth"], -d["tokens"]),
    )
    print(f"=== TOP {args.top} MATCH-BOMB SUSPECTS (max_depth >= 4, total={len(by_risk)}) ===")
    print(f"{'Rank':>4} {'Mod':<4} {'Function':<36} {'Line':>5} {'Depth':>5} {'Deep4':>5} {'Ovlp':>4} {'Lit':>3} {'Wild':>4} {'Risk':>10} {'Toks':>5}")
    for rk, d in enumerate(by_risk[: args.top], 1):
        print(
            f"{rk:>4} {d['module']:<4} {d['fn']:<36} {d['line']:>5} "
            f"{d['max_depth']:>5} {d['max_deep_arms_ge4']:>5} {d['max_head_overlap']:>4} "
            f"{d['max_lit_arms']:>3} {'Y' if d['has_wildcard_in_deepest'] else 'N':>4} "
            f"{d['max_risk']:>10.1f} {d['tokens']:>5}"
        )

    print()
    # (b) Largest function bodies by token count / lines
    by_size = sorted(all_defs, key=lambda d: (-d["tokens"], -d["non_blank_lines"]))
    print(f"=== TOP {args.top} LARGEST FUNCTION BODIES (by token count) ===")
    print(f"{'Rank':>4} {'Mod':<4} {'Function':<36} {'Line':>5} {'Lines':>5} {'Toks':>5} {'Chars':>6} {'Lets':>4} {'Cases':>5} {'Depth':>5}")
    for rk, d in enumerate(by_size[: args.top], 1):
        print(
            f"{rk:>4} {d['module']:<4} {d['fn']:<36} {d['line']:>5} "
            f"{d['non_blank_lines']:>5} {d['tokens']:>5} {d['chars']:>6} "
            f"{d['lets']:>4} {d['total_cases']:>5} {d['max_depth']:>5}"
        )

    if args.json:
        out = {
            "total_defs": len(all_defs),
            "match_bomb_count_ge4": len(by_risk),
            "top_match_bombs": by_risk[: args.top],
            "top_largest_fns": by_size[: args.top],
        }
        args.json.write_text(json.dumps(out, indent=2) + "\n", encoding="utf-8")
        print(f"\nWrote JSON to {args.json}")


if __name__ == "__main__":
    main()
