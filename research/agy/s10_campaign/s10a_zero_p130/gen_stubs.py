#!/usr/bin/env python3
"""S10-A: Zero-.p130 Stub Header Generator for K-module Bend builds.

Reads types.bend + m00.bend..m{K-1}.bend and generates self-contained
zero-.p130 source files (types.bend + minimal 1-line stubs for imported
upstream functions + m_i.bend + m_i.exp) so ALL K modules compile 100%
in parallel against base.p130 with ZERO x86-iface and ZERO .p130 chain!
"""
from __future__ import annotations

import argparse
import json
import re
import time
from pathlib import Path

IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_.\$]*")
TOP_DECL_RE = re.compile(r"^(?:type|law|def)\s+([A-Za-z0-9_.\$]+)")

# Fast comment/string/char-literal stripper for identifier extraction
STR_OR_CMT_RE = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|#[^\n]*')


def strip_strings_and_comments(text: str) -> str:
    return STR_OR_CMT_RE.sub(" ", text)


def parse_decls(path: Path) -> list[dict]:
    """Parse top-level type/law/def declarations from a .bend file."""
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    decls: list[dict] = []
    n = len(lines)
    i = 0
    while i < n:
        line = lines[i]
        stripped = line.lstrip()
        # Skip blank lines, comments, import lines
        if not stripped or stripped.startswith("#") or stripped.startswith("import "):
            i += 1
            continue
        start = i
        if stripped.startswith("@"):
            # Decorator line(s) before def/law/type
            j = i + 1
            while j < n and (lines[j].lstrip().startswith("@") or not lines[j].strip()):
                j += 1
            if j >= n:
                break
            m = TOP_DECL_RE.match(lines[j])
            if not m:
                i = j + 1
                continue
            kind = lines[j].split(None, 1)[0]
            name = m.group(1)
            k = j + 1
        else:
            m = TOP_DECL_RE.match(line)
            if not m:
                i += 1
                continue
            kind = line.split(None, 1)[0]
            name = m.group(1)
            k = i + 1
        # Consume indented body lines, continuation lines (e.g. `) -> Ret:`), and blank lines within the decl
        while k < n:
            lk = lines[k]
            if lk.strip() == "":
                k += 1
                continue
            if lk[0] in (" ", "\t") or lk.startswith(")"):
                k += 1
                continue
            break
        # Trim trailing blank lines
        end = k
        while end > start and lines[end - 1].strip() == "":
            end -= 1
        text = "".join(lines[start:end])
        decls.append({"kind": kind, "name": name, "text": text})
        i = k
    return decls


def split_top_level_commas(s: str) -> list[str]:
    parts: list[str] = []
    depth = 0
    buf: list[str] = []
    n = len(s)
    for i, ch in enumerate(s):
        if ch in "(<{[":
            depth += 1
            buf.append(ch)
        elif ch in ")}]":
            depth = max(0, depth - 1)
            buf.append(ch)
        elif ch == ">":
            # Do not treat `->` or `=>` as closing angle brackets!
            if i > 0 and s[i - 1] in "-=":
                buf.append(ch)
            else:
                depth = max(0, depth - 1)
                buf.append(ch)
        elif ch == "," and depth == 0:
            part = "".join(buf).strip()
            if part:
                parts.append(part)
            buf = []
        else:
            buf.append(ch)
    part = "".join(buf).strip()
    if part:
        parts.append(part)
    return parts


def extract_def_sig(text: str) -> tuple[str, bool]:
    """Return (single-line def header up to ':', is_template)."""
    lines = text.splitlines()
    start = 0
    while start < len(lines) and (
        lines[start].lstrip().startswith("@")
        or lines[start].lstrip().startswith("#")
        or not lines[start].strip()
    ):
        start += 1
    sig_lines: list[str] = []
    depth = 0
    seen_open = False
    for j in range(start, len(lines)):
        ln = lines[j].strip()
        # Strip inline comment if outside string
        if "#" in ln:
            ln = ln.split("#", 1)[0].strip()
        sig_lines.append(ln)
        for ch in ln:
            if ch == "(":
                depth += 1
                seen_open = True
            elif ch == ")":
                depth -= 1
        if seen_open and depth <= 0 and ":" in ln[ln.rfind(")") + 1 if ")" in ln else 0 :]:
            break
    sig = " ".join(sig_lines)
    # Trim any inline body after the signature's closing colon
    open_idx = sig.find("(")
    d = 0
    close_idx = -1
    for idx in range(open_idx, len(sig)):
        if sig[idx] == "(":
            d += 1
        elif sig[idx] == ")":
            d -= 1
            if d == 0:
                close_idx = idx
                break
    colon_idx = sig.find(":", close_idx)
    if colon_idx != -1:
        sig = sig[: colon_idx + 1]
    # Check template: ': Type', ': Data', or '~' in param list
    before_ret = sig.split("->", 1)[0]
    is_tmpl = bool(re.search(r":\s*(Type|Data)\b", before_ret)) or ("~" in before_ret)
    return sig, is_tmpl


def make_stub(name: str, def_text: str, law_text: str | None, force_cps: bool) -> str:
    """Build a minimal 1-line (or 2-line CPS) self-recursive stub for a def."""
    sig, is_tmpl = extract_def_sig(def_text)
    if is_tmpl:
        # Templates must keep their full body for monomorphization!
        if law_text:
            return law_text + "\n" + def_text
        return def_text

    # Find parameter list inside def name(...)
    open_idx = sig.find("(")
    # Find matching ')'
    depth = 0
    close_idx = -1
    for idx in range(open_idx, len(sig)):
        ch = sig[idx]
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                close_idx = idx
                break
    params_str = sig[open_idx + 1 : close_idx].strip()
    rest = sig[close_idx + 1 :]  # ' -> Ret:' or ':'

    raw_params = split_top_level_commas(params_str) if params_str else []
    call_args: list[str] = []
    new_params: list[str] = []
    for idx, p in enumerate(raw_params):
        if ":" in p:
            lhs, rhs = p.split(":", 1)
            lhs_s = lhs.strip()
            prefix = ""
            if lhs_s and lhs_s[0] in "+-~":
                prefix = lhs_s[0]
                pname = lhs_s[1:].strip()
            else:
                pname = lhs_s
            if not pname or pname == "_":
                pname = f"_s{idx}"
            new_params.append(f"{prefix}{pname}: {rhs.strip()}")
            call_args.append(pname)
        else:
            lhs_s = p.strip()
            prefix = ""
            if lhs_s and lhs_s[0] in "+-~":
                prefix = lhs_s[0]
                pname = lhs_s[1:].strip()
            else:
                pname = lhs_s
            if not pname or pname == "_":
                pname = f"_s{idx}"
            new_params.append(f"{prefix}{pname}")
            call_args.append(pname)

    header = f"def {name}({', '.join(new_params)}){rest}"
    call = f"{name}({', '.join(call_args)})"
    if force_cps == "shared":
        body = f"  _f = _s10a_cps()\n  {call}"
    elif force_cps:
        body = f"  _f : U32 -> U32 = _cps => _cps\n  {call}"
    else:
        body = f"  {call}"

    if law_text and "->" not in rest:
        return f"{law_text}\n@unsafe\n{header}\n{body}"
    return f"@unsafe\n{header}\n{body}"


def generate_all(
    k_dir: Path,
    out_dir: Path,
    abi_mode: str = "cps",
    direct_set: set[str] | None = None,
    only_mods: set[str] | None = None,
) -> dict:
    t0 = time.perf_counter()
    manifest = json.loads((k_dir / "manifest.json").read_text(encoding="utf-8"))
    mod_names = [m["name"] for m in manifest["modules"]]
    types_text = (k_dir / "types.bend").read_text(encoding="utf-8")

    # Parse all modules
    mod_texts: dict[str, str] = {}
    mod_decls: dict[str, list[dict]] = {}
    def_owner: dict[str, str] = {}
    def_text_map: dict[str, str] = {}
    law_text_map: dict[str, str] = {}
    tmpl_names: set[str] = set()
    decl_order: list[str] = []

    for m in mod_names:
        p = k_dir / f"{m}.bend"
        mod_texts[m] = p.read_text(encoding="utf-8")
        decls = parse_decls(p)
        mod_decls[m] = decls
        for d in decls:
            name = d["name"]
            if d["kind"] == "law":
                law_text_map[name] = d["text"]
            elif d["kind"] == "def":
                def_owner[name] = m
                def_text_map[name] = d["text"]
                decl_order.append(name)
                _, is_tmpl = extract_def_sig(d["text"])
                if is_tmpl:
                    tmpl_names.add(name)

    # Precompute template transitive dependencies
    tmpl_deps: dict[str, set[str]] = {}
    for t in tmpl_names:
        idents = set(IDENT_RE.findall(strip_strings_and_comments(def_text_map[t])))
        tmpl_deps[t] = {x for x in idents if x in def_owner and x != t}

    out_dir.mkdir(parents=True, exist_ok=True)
    stats: dict[str, dict] = {}

    for i, m in enumerate(mod_names):
        if only_mods and m not in only_mods:
            continue
        earlier = set(mod_names[:i])
        mod_src = mod_texts[m]
        exp_path = k_dir / f"{m}.exp"
        exp_text = exp_path.read_text(encoding="utf-8") if exp_path.exists() else ""

        # Collect all identifiers referenced in m.bend + m.exp
        raw_idents = set(IDENT_RE.findall(strip_strings_and_comments(mod_src + "\n" + exp_text)))
        needed = {x for x in raw_idents if def_owner.get(x) in earlier}

        # Close over template dependencies
        changed = True
        while changed:
            changed = False
            for x in list(needed):
                if x in tmpl_deps:
                    for dep in tmpl_deps[x]:
                        if dep not in needed and def_owner.get(dep) in earlier:
                            needed.add(dep)
                            changed = True

        # Emit stubs in original topological declaration order
        ordered_needed = [n for n in decl_order if n in needed]
        stub_chunks: list[str] = []
        if abi_mode == "cps-shared" and ordered_needed:
            stub_chunks.append(
                "@unsafe\ndef _s10a_cps() -> U32:\n  _f : U32 -> U32 = _cps => _cps\n  _s10a_cps()"
            )
        n_direct = 0
        n_cps = 0
        n_tmpl = 0
        for name in ordered_needed:
            if name in tmpl_names:
                n_tmpl += 1
                stub_chunks.append(make_stub(name, def_text_map[name], law_text_map.get(name), False))
            else:
                if abi_mode == "auto":
                    sig_n, _ = extract_def_sig(def_text_map[name])
                    op_i = sig_n.find("(")
                    cl_i = sig_n.find(")", op_i + 1) if op_i != -1 else -1
                    is_zero_arity = (op_i != -1 and cl_i != -1 and sig_n[op_i + 1 : cl_i].strip() == "")
                    body_clean = strip_strings_and_comments(def_text_map[name])
                    force_cps: bool | str = bool(
                        is_zero_arity
                        or "IO(" in sig_n
                        or "IO " in sig_n
                        or re.search(r"\bdo\s+", body_clean)
                    )
                elif abi_mode == "cps-shared":
                    force_cps = "shared"
                elif abi_mode == "cps":
                    force_cps = True
                elif abi_mode == "direct":
                    force_cps = False
                elif abi_mode == "oracle" and direct_set is not None:
                    force_cps = True if (name not in direct_set) else False
                else:
                    force_cps = False
                if force_cps:
                    n_cps += 1
                else:
                    n_direct += 1
                stub_chunks.append(make_stub(name, def_text_map[name], law_text_map.get(name), force_cps))

        stubs_text = "\n\n".join(stub_chunks)
        full_text = (
            types_text
            + "\n\n# === S10-A ZERO-P130 IMPORTS ("
            + f"{len(ordered_needed)} stubs: {n_direct} direct, {n_cps} cps, {n_tmpl} tmpl"
            + ") ===\n"
            + stubs_text
            + "\n\n# === MODULE BODY: "
            + m
            + " ===\n"
            + mod_src
            + ("\n" + exp_text if exp_text.strip() else "\n")
        )
        out_path = out_dir / f"{m}_zero.bend"
        out_path.write_text(full_text, encoding="utf-8")
        stats[m] = {
            "path": str(out_path),
            "bytes": len(full_text.encode("utf-8")),
            "stubs_bytes": len(stubs_text.encode("utf-8")),
            "stubs_total": len(ordered_needed),
            "stubs_direct": n_direct,
            "stubs_cps": n_cps,
            "stubs_tmpl": n_tmpl,
        }

    elapsed_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    return {"elapsed_ms": elapsed_ms, "abi_mode": abi_mode, "modules": stats}


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--k-dir", type=Path, default=Path("/home/ai/bend2_agy/selfhost/build/agy/k10_wave15"))
    ap.add_argument("--out-dir", type=Path, default=Path("/tmp/agy_s10a/src"))
    ap.add_argument("--abi", choices=["auto", "cps", "cps-shared", "direct", "oracle"], default="auto")
    ap.add_argument("--only", type=str, default="", help="Comma-separated module names, e.g. m09")
    args = ap.parse_args()

    only_mods = {x.strip() for x in args.only.split(",") if x.strip()} if args.only else None
    res = generate_all(args.k_dir, args.out_dir, abi_mode=args.abi, only_mods=only_mods)
    print(f"Generated stubs in {res['elapsed_ms']} ms (abi={res['abi_mode']}):")
    for m, s in res["modules"].items():
        print(
            f"  {m}: total={s['bytes']//1024}KB (stubs={s['stubs_bytes']//1024}KB, "
            f"n={s['stubs_total']}: direct={s['stubs_direct']}, cps={s['stubs_cps']}, tmpl={s['stubs_tmpl']})"
        )


if __name__ == "__main__":
    main()
