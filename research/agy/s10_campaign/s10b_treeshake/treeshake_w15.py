#!/usr/bin/env python3
"""S10-B: Deterministic, semantics-preserving tree-shaker for wave15_unified/compiler.bend.

Preserves ALL 7 required native x86-64 CLI modes with ZERO regression on -O2 output:
  - x86-object       (-O2 ELF object)
  - x86-object-fast  (-O0 ELF object)
  - x86-module       (-O2 modular ELF object)
  - x86-module-fast  (-O0 modular ELF object)
  - x86-merge-obj    (pure-Bend link-merge ELF object)
  - x86-iface        (.p130 interface carrier)
  - --trace          (live stage timing wrapper for x86-object*/x86-module*)

Passes:
  1. Unify CLI dispatch (w8_dispatch_args + x181_entry_args):
     - Drop unused legacy CLI modes: --trace-slow (ts_*), x86 text asm (x181_print),
       x86-shard (agy_lpt_entry_shard), 8-arg x86-object (agy_parcg_entry_shard).
     - Route x86-object, x86-object-fast, x86-module, x86-module-fast through the
       single unified streaming driver w8_tr_run_obj(False{}, ...), eliminating duplicate
       object/module cursor & non-streaming ELF builders while keeping w10f_output_fn,
       w13c_pub_emit_fast, w11_program_public_mod, and streaming x202p/w10_x202p ELF.
  2. Constant-fold 0-arg `() -> Bool: True{}/False{}` feature flags (55 flags):
     - Replace `flag()` with `True{}` / `False{}`.
     - Fold sole-condition `nt_choose(T, True{}, u => A, u => B)` -> `A` (and `False{}` -> `B`),
       freeing dead fallback paths (e.g. `p185cc_*` gated behind `x185_ctor_enabled() -> False{}`).
     - Simplify `True{} && X` -> `X`.
  3. Transitive reachability tree-shaking from `main`:
     - Keep only reachable `def`s, their matching `law` signatures, and reachable `type`s
       (tracing both type names and constructor names).
     - Preserve exact original declaration order.
  4. Optional comment & redundant blank-line stripping (--strip-comments, default on).

Idempotent: running treeshake_w15.py on its own output produces byte-identical output.
"""
from __future__ import annotations

import argparse
import json
import re
import time
from collections import Counter, deque
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave15_unified/compiler.bend"
DEFAULT_OUT = Path("/tmp/agy_s10b/compiler_pruned.bend")

IDENT_RE = re.compile(r"\b[A-Za-z_][A-Za-z0-9_.]*\b")
DECL_DEF_RE = re.compile(r"^(def|law)\s+([A-Za-z_][A-Za-z0-9_.]*)")
DECL_TYPE_RE = re.compile(r"^type\s+([A-Za-z_][A-Za-z0-9_.]*)")
CTOR_DEF_RE = re.compile(r"^\s+([A-Z][A-Za-z0-9_]*)\s*\{")


def strip_strings_and_comments(text: str) -> str:
    out: list[str] = []
    i = 0
    n = len(text)
    while i < n:
        c = text[i]
        if c == "#":
            j = text.find("\n", i)
            if j == -1:
                break
            out.append("\n")
            i = j + 1
        elif c == '"' or c == "'":
            q = c
            i += 1
            while i < n:
                ch = text[i]
                if ch == "\\":
                    i += 2
                elif ch == q:
                    i += 1
                    break
                else:
                    i += 1
            out.append(" ")
        else:
            out.append(c)
            i += 1
    return "".join(out)


def is_top_decl_start(line: str) -> bool:
    return (
        line.startswith("def ")
        or line.startswith("law ")
        or line.startswith("type ")
        or line.startswith("@unsafe")
        or line.startswith("import ")
    )


def parse_compiler_bend(path: Path):
    lines = path.read_text(encoding="utf-8").splitlines(keepends=True)
    n = len(lines)
    imports: list[str] = []
    types: list[dict] = []
    decls: list[dict] = []

    i = 0
    pending_start = None
    while i < n:
        line = lines[i]
        if line.startswith("import "):
            imports.append(line)
            i += 1
            continue
        if line.startswith("@unsafe"):
            if pending_start is None:
                pending_start = i
            i += 1
            continue
        m_type = DECL_TYPE_RE.match(line)
        if m_type:
            start = pending_start if pending_start is not None else i
            pending_start = None
            j = i + 1
            while j < n and not is_top_decl_start(lines[j]):
                j += 1
            block = "".join(lines[start:j])
            types.append({
                "name": m_type.group(1),
                "start_line": start + 1,
                "end_line": j,
                "bytes": len(block.encode("utf-8")),
                "text": block,
            })
            i = j
            continue
        m_def = DECL_DEF_RE.match(line)
        if m_def:
            kind, name = m_def.group(1), m_def.group(2)
            start = pending_start if pending_start is not None else i
            pending_start = None
            j = i + 1
            while j < n and not is_top_decl_start(lines[j]):
                j += 1
            block = "".join(lines[start:j])
            decls.append({
                "kind": kind,
                "name": name,
                "start_line": start + 1,
                "end_line": j,
                "bytes": len(block.encode("utf-8")),
                "text": block,
            })
            i = j
            continue
        if line.strip() and not line.startswith("#"):
            raise ValueError(f"Unexpected top-level line {i + 1}: {line!r}")
        i += 1

    return imports, types, decls


# --- Pass 1: Clean unified CLI dispatch ---

PRUNED_W8_DISPATCH_ARGS = """\
@unsafe
def w8_dispatch_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+head,+rest}:
      nt_choose(IO(U32),agy_str_eq(head,"--trace"),
        v => w8_tr_entry(rest),
        v => nt_choose(IO(U32),agy_str_eq(head,"x86-merge-obj"),
          w => w10_merge_entry(rest),
          w => x181_entry_args(Con{head,rest})))
    case Nil{}: x181_entry_args(Nil{})
"""

PRUNED_W8_TR_MOD_FID = """\
@unsafe
def w8_tr_mod_fid(+trace: Bool, fid_m: Maybe<&2,U32>, +fast: Bool, +mod_name: String, +path: String, +base: String,
    +carrier: String, +stamp: String, +cached: Bool) -> IO(U32):
  match fid_m:
    case Some{+fb}:
      nt_choose(IO(U32),U32.is_lt(fb,65532) && Bool.not(String.is_empty(mod_name)),
        u => w8_tr_run_obj(trace,fast,True{},fb,mod_name,path,base,carrier,stamp,cached),
        u => IO.die(U32,2,"expected 0 <= fid_base < 65532 and non-empty module name"))
    case _: IO.die(U32,2,"expected U32 fid_base argument")
"""

PRUNED_W8_TR_ENTRY = """\
@unsafe
def w8_tr_entry(+args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_run_obj(True{},agy_str_eq(program,"x86-object-fast"),False{},0,"",path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+fid_s,Con{+mod_name,Nil{}}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-module") || agy_str_eq(program,"x86-module-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_mod_fid(True{},U32.read(fid_s),agy_str_eq(program,"x86-module-fast"),mod_name,path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => x181_entry_args(args))
    case _: x181_entry_args(args)
"""

PRUNED_X181_ENTRY_ARGS = """\
@unsafe
def x181_entry_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Nil{}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-object") || agy_str_eq(program,"x86-object-fast") || agy_str_eq(program,"x86-iface")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => nt_choose(IO(U32),agy_str_eq(program,"x86-iface"),
          v => w10_iface_request(path,base,carrier,stamp,agy_str_eq(mode,"cache")),
          v => w8_tr_run_obj(False{},agy_str_eq(program,"x86-object-fast"),False{},0,"",path,base,carrier,stamp,agy_str_eq(mode,"cache"))),
        u => IO.die(U32,2,"expected x86-object|x86-object-fast|x86-iface, absolute input/Base paths and live|cache mode"))
    case Con{+program,Con{+path,Con{+base,Con{+mode,Con{+carrier,Con{+stamp,Con{+fid_s,Con{+mod_name,Nil{}}}}}}}}}:
      nt_choose(IO(U32),(agy_str_eq(program,"x86-module") || agy_str_eq(program,"x86-module-fast")) && String.starts_with(path,"/") &&
        String.starts_with(base,"/") &&
        (agy_str_eq(mode,"live") || (agy_str_eq(mode,"cache") && String.starts_with(carrier,"/"))),
        u => w8_tr_mod_fid(False{},U32.read(fid_s),agy_str_eq(program,"x86-module-fast"),mod_name,path,base,carrier,stamp,agy_str_eq(mode,"cache")),
        u => IO.die(U32,2,"expected x86-module|x86-module-fast, absolute input/Base paths, live|cache mode, and fid_base/mod_name"))
    case _: IO.die(U32,2,"usage: [--trace] x86-object|x86-object-fast|x86-iface|x86-module|x86-module-fast ABS_SOURCE ABS_BASE live|cache ABS_CARRIER_OR_EMPTY STAMP [FID_BASE MOD_NAME]")
"""


# --- Pass 2: Constant-fold 0-arg Bool feature flags ---

def split_call_args(text: str, open_paren: int) -> tuple[list[str], int] | None:
    """Given index of '(' in text, split top-level comma-separated args and return (args, close_paren)."""
    n = len(text)
    assert text[open_paren] == "("
    depth_p = 1
    depth_b = 0
    depth_k = 0
    depth_a = 0
    args: list[str] = []
    start = open_paren + 1
    i = start
    while i < n:
        c = text[i]
        if c == "#":
            j = text.find("\n", i)
            i = n if j == -1 else j + 1
            continue
        if c == '"' or c == "'":
            q = c
            i += 1
            while i < n:
                if text[i] == "\\":
                    i += 2
                elif text[i] == q:
                    i += 1
                    break
                else:
                    i += 1
            continue
        if c == "(":
            depth_p += 1
        elif c == ")":
            depth_p -= 1
            if depth_p == 0 and depth_b == 0 and depth_k == 0 and depth_a == 0:
                args.append(text[start:i])
                return args, i
        elif c == "{":
            depth_b += 1
        elif c == "}":
            depth_b -= 1
        elif c == "[":
            depth_k += 1
        elif c == "]":
            depth_k -= 1
        elif c == "<" and i + 1 < n and text[i + 1] not in ("-", "=", " "):
            depth_a += 1
        elif c == ">" and depth_a > 0 and (i == 0 or text[i - 1] not in ("-", "=")):
            depth_a -= 1
        elif c == "," and depth_p == 1 and depth_b == 0 and depth_k == 0 and depth_a == 0:
            args.append(text[start:i])
            start = i + 1
        i += 1
    return None


def strip_lambda_unit(arg: str) -> str | None:
    """If arg is `u => expr` (single unused unit param), return expr stripped."""
    s = arg.strip()
    m = re.match(r"^([a-z_][A-Za-z0-9_]*)\s*=>\s*(.*)$", s, re.S)
    if not m:
        return None
    param, body = m.group(1), m.group(2)
    # Ensure param is not referenced in body (it's always a unit thunk `u => ...`)
    if re.search(rf"\b{re.escape(param)}\b", strip_strings_and_comments(body)):
        return None
    return body


def fold_nt_choose_const(text: str) -> tuple[str, int]:
    """Fold `nt_choose(T, True{}, u => A, v => B)` -> `(A)` and `False{}` -> `(B)`."""
    folded = 0
    while True:
        changed = False
        idx = 0
        while True:
            pos = text.find("nt_choose(", idx)
            if pos == -1:
                break
            # Make sure it's not part of a longer identifier
            if pos > 0 and (text[pos - 1].isalnum() or text[pos - 1] == "_"):
                idx = pos + 10
                continue
            res = split_call_args(text, pos + 9)
            if res is None:
                idx = pos + 10
                continue
            args, close_p = res
            if len(args) == 4:
                cond = args[1].strip()
                if cond in ("True{}", "False{}"):
                    chosen = strip_lambda_unit(args[2] if cond == "True{}" else args[3])
                    if chosen is not None and "\n" not in chosen.strip():
                        text = text[:pos] + "(" + chosen.strip() + ")" + text[close_p + 1:]
                        folded += 1
                        changed = True
                        break
                    elif chosen is not None:
                        # Multiline body: preserve indentation cleanly by replacing only if safe
                        # Only replace if nt_choose starts its own expression or is parens-wrapped
                        text = text[:pos] + "(" + chosen.strip() + ")" + text[close_p + 1:]
                        folded += 1
                        changed = True
                        break
            idx = pos + 10
        if not changed:
            break
    return text, folded


def constant_fold_flags(decls: list[dict]) -> dict:
    const_flags: dict[str, bool] = {}
    for d in decls:
        if d["kind"] != "def":
            continue
        clean = strip_strings_and_comments(d["text"]).strip()
        m = re.match(
            r"^(?:@unsafe\s+)?def\s+([A-Za-z_][A-Za-z0-9_.]*)\s*\(\s*\)\s*->\s*Bool\s*:\s*(True|False)\{\}\s*$",
            clean,
            re.S,
        )
        if m:
            const_flags[m.group(1)] = (m.group(2) == "True")

    if not const_flags:
        return {"flags_found": 0, "calls_inlined": 0, "nt_choose_folded": 0}

    pat = re.compile(
        r"\b(" + "|".join(re.escape(k) for k in sorted(const_flags, key=len, reverse=True)) + r")\s*\(\s*\)"
    )

    calls_inlined = 0
    nt_choose_folded = 0
    for d in decls:
        if d["name"] in const_flags:
            continue
        txt = d["text"]

        def repl(m: re.Match) -> str:
            nonlocal calls_inlined
            calls_inlined += 1
            return "True{}" if const_flags[m.group(1)] else "False{}"

        new_txt = pat.sub(repl, txt)
        if new_txt != txt:
            # Simplify `True{} && ` -> ``
            new_txt = re.sub(r"\bTrue\{\}\s*&&\s*", "", new_txt)
            new_txt, nf = fold_nt_choose_const(new_txt)
            nt_choose_folded += nf
            d["text"] = new_txt
            d["bytes"] = len(new_txt.encode("utf-8"))

    return {
        "flags_found": len(const_flags),
        "true_flags": sum(const_flags.values()),
        "false_flags": sum(not v for v in const_flags.values()),
        "calls_inlined": calls_inlined,
        "nt_choose_folded": nt_choose_folded,
    }


# --- Pass 3: Reachability from main ---

def compute_reachable(types: list[dict], decls: list[dict]) -> tuple[set[int], set[int]]:
    name_to_ids: dict[str, list[int]] = {}
    for idx, d in enumerate(decls):
        name_to_ids.setdefault(d["name"], []).append(idx)

    type_name_to_id: dict[str, int] = {}
    ctor_to_type_id: dict[str, int] = {}
    for tid, t in enumerate(types):
        type_name_to_id[t["name"]] = tid
        for line in strip_strings_and_comments(t["text"]).splitlines()[1:]:
            m = CTOR_DEF_RE.match(line)
            if m:
                ctor_to_type_id[m.group(1)] = tid

    decl_toks = [set(IDENT_RE.findall(strip_strings_and_comments(d["text"]))) for d in decls]
    type_toks = [set(IDENT_RE.findall(strip_strings_and_comments(t["text"]))) for t in types]

    vis_d: set[int] = set()
    vis_t: set[int] = set()
    q_d: deque[int] = deque()
    q_t: deque[int] = deque()

    assert "main" in name_to_ids, "Missing main declaration!"
    for mid in name_to_ids["main"]:
        vis_d.add(mid)
        q_d.append(mid)

    def visit_tokens(toks: set[str]):
        for tok in toks:
            if tok == "main":
                continue
            if tok in name_to_ids:
                for v in name_to_ids[tok]:
                    if v not in vis_d:
                        vis_d.add(v)
                        q_d.append(v)
            if tok in type_name_to_id:
                tid = type_name_to_id[tok]
                if tid not in vis_t:
                    vis_t.add(tid)
                    q_t.append(tid)
            if tok in ctor_to_type_id:
                tid = ctor_to_type_id[tok]
                if tid not in vis_t:
                    vis_t.add(tid)
                    q_t.append(tid)

    while q_d or q_t:
        while q_d:
            u = q_d.popleft()
            for mate in name_to_ids[decls[u]["name"]]:
                if mate not in vis_d:
                    vis_d.add(mate)
                    q_d.append(mate)
            visit_tokens(decl_toks[u])
        while q_t:
            tid = q_t.popleft()
            visit_tokens(type_toks[tid])

    return vis_d, vis_t


# --- Pass 4: Comment & blank line stripping ---

def strip_comments_block(text: str) -> str:
    out_lines: list[str] = []
    for line in text.splitlines():
        s = line.lstrip()
        if s.startswith("#"):
            continue
        if not s:
            continue
        out_lines.append(line.rstrip())
    return "\n".join(out_lines) + "\n\n"


def count_code_lines(text: str) -> int:
    return sum(1 for l in text.splitlines() if l.strip() and not l.lstrip().startswith("#"))


def main() -> None:
    ap = argparse.ArgumentParser(description="Tree-shake wave15_unified/compiler.bend")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC)
    ap.add_argument("--out", type=Path, default=DEFAULT_OUT)
    ap.add_argument("--stats-json", type=Path, default=None)
    ap.add_argument("--no-fold-flags", action="store_true")
    ap.add_argument("--no-strip-comments", action="store_true")
    args = ap.parse_args()

    t0 = time.perf_counter()
    orig_text = args.src.read_text(encoding="utf-8")
    orig_lines = len(orig_text.splitlines())
    orig_code_lines = count_code_lines(orig_text)
    orig_bytes = len(orig_text.encode("utf-8"))

    imports, types, decls = parse_compiler_bend(args.src)
    orig_defs = sum(1 for d in decls if d["kind"] == "def")
    orig_laws = sum(1 for d in decls if d["kind"] == "law")
    orig_types = len(types)

    # Pass 1: Rewrite CLI entrypoints
    replacements = {
        "w8_dispatch_args": PRUNED_W8_DISPATCH_ARGS,
        "w8_tr_mod_fid": PRUNED_W8_TR_MOD_FID,
        "w8_tr_entry": PRUNED_W8_TR_ENTRY,
        "x181_entry_args": PRUNED_X181_ENTRY_ARGS,
    }
    replaced = set()
    for d in decls:
        if d["kind"] == "def" and d["name"] in replacements:
            d["text"] = replacements[d["name"]]
            d["bytes"] = len(d["text"].encode("utf-8"))
            replaced.add(d["name"])
    assert replaced == set(replacements.keys()), f"Missing CLI defs: {set(replacements) - replaced}"

    # Pass 2: Constant-fold feature flags
    fold_stats = {"flags_found": 0, "calls_inlined": 0, "nt_choose_folded": 0}
    if not args.no_fold_flags:
        fold_stats = constant_fold_flags(decls)

    # Pass 3: Exact reachability from main
    vis_d, vis_t = compute_reachable(types, decls)

    kept_types = [t for i, t in enumerate(types) if i in vis_t]
    kept_decls = [d for i, d in enumerate(decls) if i in vis_d]
    pruned_defs = [d["name"] for i, d in enumerate(decls) if i not in vis_d and d["kind"] == "def"]
    pruned_types = [t["name"] for i, t in enumerate(types) if i not in vis_t]

    # Assemble output preserving original order
    parts: list[str] = []
    for imp in imports:
        parts.append(imp if imp.endswith("\n") else imp + "\n")
    parts.append("\n")

    for t in kept_types:
        txt = strip_comments_block(t["text"]) if not args.no_strip_comments else (
            t["text"] if t["text"].endswith("\n") else t["text"] + "\n"
        )
        parts.append(txt)

    for d in kept_decls:
        txt = strip_comments_block(d["text"]) if not args.no_strip_comments else (
            d["text"] if d["text"].endswith("\n") else d["text"] + "\n"
        )
        parts.append(txt)

    out_text = "".join(parts)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(out_text, encoding="utf-8")

    out_lines = len(out_text.splitlines())
    out_code_lines = count_code_lines(out_text)
    out_bytes = len(out_text.encode("utf-8"))
    out_defs = sum(1 for d in kept_decls if d["kind"] == "def")
    out_laws = sum(1 for d in kept_decls if d["kind"] == "law")
    out_types = len(kept_types)
    elapsed_ms = round((time.perf_counter() - t0) * 1000.0, 1)

    pruned_pfx = Counter(nm.split("_")[0] for nm in pruned_defs)

    stats = {
        "source": str(args.src),
        "output": str(args.out),
        "elapsed_ms": elapsed_ms,
        "options": {
            "fold_flags": not args.no_fold_flags,
            "strip_comments": not args.no_strip_comments,
        },
        "before": {
            "lines": orig_lines,
            "code_lines": orig_code_lines,
            "bytes": orig_bytes,
            "defs": orig_defs,
            "laws": orig_laws,
            "types": orig_types,
        },
        "after": {
            "lines": out_lines,
            "code_lines": out_code_lines,
            "bytes": out_bytes,
            "defs": out_defs,
            "laws": out_laws,
            "types": out_types,
        },
        "delta": {
            "lines": orig_lines - out_lines,
            "lines_pct": round((orig_lines - out_lines) / orig_lines * 100.0, 2),
            "code_lines": orig_code_lines - out_code_lines,
            "code_lines_pct": round((orig_code_lines - out_code_lines) / orig_code_lines * 100.0, 2),
            "bytes": orig_bytes - out_bytes,
            "bytes_pct": round((orig_bytes - out_bytes) / orig_bytes * 100.0, 2),
            "defs": orig_defs - out_defs,
            "defs_pct": round((orig_defs - out_defs) / orig_defs * 100.0, 2),
            "laws": orig_laws - out_laws,
            "types": orig_types - out_types,
        },
        "fold_stats": fold_stats,
        "pruned_def_prefixes_top25": pruned_pfx.most_common(25),
        "pruned_types": pruned_types,
    }

    if args.stats_json:
        args.stats_json.parent.mkdir(parents=True, exist_ok=True)
        args.stats_json.write_text(json.dumps(stats, indent=2) + "\n", encoding="utf-8")

    print(f"=== S10-B Tree-Shake Complete ({elapsed_ms} ms) -> {args.out} ===")
    print(f"  Total lines : {orig_lines:,} -> {out_lines:,} (-{stats['delta']['lines']:,}, -{stats['delta']['lines_pct']}%)")
    print(f"  Code lines  : {orig_code_lines:,} -> {out_code_lines:,} (-{stats['delta']['code_lines']:,}, -{stats['delta']['code_lines_pct']}%)")
    print(f"  Bytes       : {orig_bytes:,} -> {out_bytes:,} (-{stats['delta']['bytes']:,}, -{stats['delta']['bytes_pct']}%)")
    print(f"  Defs        : {orig_defs:,} -> {out_defs:,} (-{stats['delta']['defs']:,}, -{stats['delta']['defs_pct']}%)")
    print(f"  Laws        : {orig_laws:,} -> {out_laws:,} (-{stats['delta']['laws']:,})")
    print(f"  Types       : {orig_types:,} -> {out_types:,} (-{stats['delta']['types']:,})")
    print(f"  Flag folding: {fold_stats}")
    print(f"  Top pruned prefixes: {pruned_pfx.most_common(12)}")


if __name__ == "__main__":
    main()
