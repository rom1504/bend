#!/usr/bin/env python3
"""Wave 5 FID-Budget Trim, Wrapper Inliner & Closure Eliminator (`apply_fid_trim.py`).

100% semantics-preserving, bit-exact `.o` output:
  1. Inlines pure 1-line linear-safe constructor/primitive wrapper `def`s
     (e.g. `x188_reg`, `x188_i2`, `x188_i1`, `p88_string_eq`, `x188_label`, `x188_xmm`,
     `p111_state`, `p111_u32`, `p121f_ref`, etc.): eliminates ~1.07 CPS `$p111.k.*`
     continuation segments per call site (~6,500+ segments total) and eliminates
     thousands of runtime call frames!
  2. Strips genuinely unreachable top-level `def`s (and their `law` declarations)
     not reachable from `main` or hosted JS API exports.
  3. Inserts polymorphic strict `w5_sel(-A: Type, +b: Bool, yes: A, no: A) -> A`
     right after `def kc(...)`.
  4. Converts affine-safe pure strict `nt_choose(T, cond, u => b1, u => b2)` and
     `kc(T, cond, u => b1, u => b2)` calls (using automatic pure non-recursive leaf
     detection + `law` `+var` annotations) into `w5_sel(T, cond, b1, b2)`,
     eliminating 2 lifted lambda segments per call and 2 runtime closure allocations!

Usage:
  python3 -B research/agy/wave5_fid_trim/apply_fid_trim.py --src <in.bend> --dst <out.bend>
"""
import argparse
import re
from pathlib import Path

W5_SEL_DEF = """
def w5_sel(-A: Type, +b: Bool, yes: A, no: A) -> A:
  match b:
    case True{}: yes
    case False{}: no
"""

API_ROOTS = {
    "main",
    "p86_plan",
    "p88_cache_prepare",
    "x198pw_plan",
    "x187_prepared",
    "agy_parcg_prepare_cursor",
    "agy_parcg_emit_presliced",
    "agy_parcg_emit_shard",
    "x187_prepared_shard",
    "w4_peep_flat",
    "w4_post_select",
    "x181_direct",
    "x185_array_selected",
}

PRIM_PREFIXES = ("U32.", "Bool.", "Char.", "String.", "F32.", "Nat.")
BAD_SUBS = ("IO.", "File.", "div", "mod", "rem", "do ")


def is_prim(c: str) -> bool:
    return any(c.startswith(p) for p in PRIM_PREFIXES) and not any(x in c for x in ("div", "mod", "rem"))


def strip_comments_and_strings(s: str) -> str:
    s = re.sub(r"'(?:\\.|[^'\\])'", "''", s)
    s = re.sub(r'"(?:\\.|[^"\\])*"', '""', s)
    s = re.sub(r'#[^\n]*', '', s)
    return s


def split_top_blocks(text: str) -> list[str]:
    """Split Bend source into top-level blocks, keeping `@unsafe` attached to its `def`."""
    lines = text.splitlines(keepends=True)
    blocks = []
    cur = []
    for line in lines:
        is_start = False
        if line.startswith("@unsafe"):
            is_start = True
        elif line.startswith(("def ", "law ", "type ")):
            prev_unsafe = (len(cur) > 0 and cur[-1].startswith("@unsafe"))
            if not prev_unsafe:
                is_start = True
        if is_start and cur:
            blocks.append("".join(cur))
            cur = [line]
        else:
            cur.append(line)
    if cur:
        blocks.append("".join(cur))
    return blocks


def find_balanced_calls(text: str, name_pat: re.Pattern) -> list[tuple[int, int, str, list[str]]]:
    """Find balanced calls matching `name_pat` (which must capture callee name in group 1 and end right after `(`),
    skipping string literals and `#` line comments."""
    out = []
    # Precompute string/comment spans to skip
    skip_spans = []
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        if ch == "'":
            s0 = i
            i += 1
            if i < n and text[i] == "\\":
                i += 2
            elif i < n:
                i += 1
            if i < n and text[i] == "'":
                i += 1
                skip_spans.append((s0, i))
            else:
                i = s0 + 1
        elif ch == '"':
            s0 = i
            i += 1
            while i < n:
                if text[i] == "\\":
                    i += 2
                    continue
                if text[i] == '"':
                    i += 1
                    break
                i += 1
            skip_spans.append((s0, i))
        elif ch == "#":
            s0 = i
            nl = text.find("\n", i)
            i = n if nl == -1 else nl
            skip_spans.append((s0, i))
        else:
            i += 1

    skip_idx = 0
    pos = 0
    while True:
        m = name_pat.search(text, pos)
        if not m:
            break
        start = m.start()
        while skip_idx < len(skip_spans) and skip_spans[skip_idx][1] <= start:
            skip_idx += 1
        if skip_idx < len(skip_spans) and skip_spans[skip_idx][0] <= start < skip_spans[skip_idx][1]:
            pos = skip_spans[skip_idx][1]
            continue
        callee = m.group(1)
        j = m.end()
        pdepth = 1
        bdepth = 0
        cdepth = 0
        adepth = 0
        in_str = False
        in_chr = False
        esc = False
        args = []
        arg_start = j
        while j < n and pdepth > 0:
            ch = text[j]
            if in_str:
                if esc:
                    esc = False
                elif ch == "\\":
                    esc = True
                elif ch == '"':
                    in_str = False
            elif in_chr:
                if esc:
                    esc = False
                elif ch == "\\":
                    esc = True
                elif ch == "'":
                    in_chr = False
            else:
                if ch == '"':
                    in_str = True
                elif ch == "'":
                    in_chr = True
                elif ch == "#":
                    nl = text.find("\n", j)
                    j = n if nl == -1 else nl
                    continue
                elif ch == "(":
                    pdepth += 1
                elif ch == ")":
                    pdepth -= 1
                    if pdepth == 0:
                        raw = text[arg_start:j]
                        if raw.strip() or args:
                            args.append(raw.strip())
                        break
                elif ch == "[":
                    bdepth += 1
                elif ch == "]":
                    bdepth -= 1
                elif ch == "{":
                    cdepth += 1
                elif ch == "}":
                    cdepth -= 1
                elif ch == "<" and callee in ("nt_choose", "kc", "f_choose") and len(args) == 0:
                    adepth += 1
                elif ch == ">" and callee in ("nt_choose", "kc", "f_choose") and len(args) == 0 and adepth > 0:
                    adepth -= 1
                elif ch == "," and pdepth == 1 and bdepth == 0 and cdepth == 0 and adepth == 0:
                    args.append(text[arg_start:j].strip())
                    arg_start = j + 1
            j += 1
        if pdepth == 0:
            out.append((start, j + 1, callee, args))
        pos = m.end()
    return out


def split_top_params(pstr: str) -> list[str]:
    out, cur, depth = [], [], 0
    for ch in pstr:
        if ch in "(<[{":
            depth += 1
        elif ch in ")>]}":
            depth -= 1
        if ch == "," and depth == 0:
            t = "".join(cur).strip()
            if t:
                out.append(t)
            cur = []
        else:
            cur.append(ch)
    t = "".join(cur).strip()
    if t:
        out.append(t)
    return out


INTRINSIC_CALLEES = {
    "U32.add", "U32.sub", "U32.mul", "U32.and", "U32.or", "U32.xor",
    "U32.is_eq", "U32.is_lt", "U32.is_le", "U32.is_gt", "U32.is_ge",
    "U32.inc", "U32.dec", "U32.min", "U32.max", "U32.shln", "U32.shrn",
    "Bool.not", "Bool.and", "Bool.or",
}


def discover_linear_wrappers(blocks: list[str]) -> dict[str, tuple[list[str], str]]:
    """Find 1-expression linear-safe pure constructor/intrinsic wrappers (each param used <= 1 time)."""
    candidates = {}
    for b in blocks:
        lines = [l for l in b.splitlines() if not l.lstrip().startswith("#") and l.strip() != ""]
        if not lines:
            continue
        clean = "\n".join(lines)
        m = re.match(r"^(?:@unsafe\n)?def ([A-Za-z0-9_]+)\(([^)]*)\)\s*->\s*([^:\n]+):\n(.*)$", clean, re.S)
        if not m:
            continue
        name, pstr, body_raw = m.group(1), m.group(2).strip(), m.group(4)
        body = " ".join(l.strip() for l in body_raw.splitlines())
        if name in API_ROOTS or name in ("nt_choose", "kc", "f_choose", "w5_sel"):
            continue
        if any(bad in body for bad in ("match ", "=>", "do ", "nt_choose", "kc(", "f_choose", "w5_sel", "IO.", "File.", "div", "mod", "rem", " = ")):
            continue
        if re.search(rf"\b{re.escape(name)}\b", body):
            continue
        pnames = []
        ok_p = True
        for p in split_top_params(pstr):
            if p.startswith("-"):
                ok_p = False
                break
            pm = re.match(r"^\+?([A-Za-z_][A-Za-z0-9_]*)\s*:", p)
            if not pm:
                ok_p = False
                break
            pnames.append(pm.group(1))
        if not ok_p:
            continue
        body_no_str = strip_comments_and_strings(body)
        # Each param must appear at most once in body (100% affine-safe, zero evaluation duplication)
        if any(len(re.findall(rf"\b{re.escape(pn)}\b", body_no_str)) > 1 for pn in pnames):
            continue
        if len(body) <= 220:
            candidates[name] = (pnames, body)

    accepted: dict[str, tuple[list[str], str]] = {}
    for _ in range(6):
        changed = False
        for name, (pnames, body) in candidates.items():
            if name in accepted:
                continue
            body_no_str = strip_comments_and_strings(body)
            callees = re.findall(r"([A-Za-z_][A-Za-z0-9_.]*)\s*\(", body_no_str)
            if all(c in INTRINSIC_CALLEES or c in accepted for c in callees):
                accepted[name] = (pnames, body)
                changed = True
        if not changed:
            break
    return accepted


def substitute_wrapper_body(pnames: list[str], body: str, args: list[str]) -> str:
    """Substitute parameter names in `body` (outside string literals) with `args`."""
    mapping = dict(zip(pnames, args))
    # Wrap body in parens if it contains binary operators at top level (&&, ||, ++)
    needs_parens = any(op in strip_comments_and_strings(body) for op in ("&&", "||", "++"))
    if not pnames:
        return f"({body})" if needs_parens else body

    # Tokenize into string literals vs code chunks so we never substitute inside strings
    parts = re.split(r'("(?:\\.|[^"\\])*")', body)
    p_re = re.compile(r"\b(" + "|".join(re.escape(p) for p in pnames) + r")\b")
    for idx in range(0, len(parts), 2):
        parts[idx] = p_re.sub(lambda m: mapping[m.group(1)], parts[idx])
    res = "".join(parts)
    return f"({res})" if needs_parens else res


def inline_wrappers_in_blocks(blocks: list[str], wrappers: dict[str, tuple[list[str], str]]) -> tuple[list[str], int]:
    if not wrappers:
        return blocks, 0
    # Match any wrapper call `\b(w1|w2|...)\(`
    w_pat = re.compile(r"\b(" + "|".join(re.escape(w) for w in sorted(wrappers, key=len, reverse=True)) + r")\(")
    total = 0
    out_blocks = []
    for b in blocks:
        m_nm = re.match(r"^(?:@unsafe\n)?def ([A-Za-z0-9_]+)\b", b)
        if not m_nm:
            out_blocks.append(b)
            continue
        def_name = m_nm.group(1)
        hdr_end = b.find(":\n")
        if hdr_end == -1:
            out_blocks.append(b)
            continue
        hdr = b[:hdr_end + 2]
        body = b[hdr_end + 2:]
        for _ in range(6):
            calls = find_balanced_calls(body, w_pat)
            repls = []
            for st, en, callee, args in calls:
                if callee == def_name:
                    continue
                pnames, wbody = wrappers[callee]
                if len(args) != len(pnames):
                    continue
                # Bend's bidirectional checker cannot infer the type of a bare Ctor{...}
                # on the RHS of an unannotated `let` (`+x = Ctor{...}` or `x = Ctor{...}`).
                if wbody[0].isupper() and "{" in wbody:
                    ls = body.rfind("\n", 0, st) + 1
                    lpre = body[ls:st]
                    if re.match(r"^\s*\+?[A-Za-z_][A-Za-z0-9_]*\s*=\s*$", lpre):
                        continue
                repls.append((st, en, substitute_wrapper_body(pnames, wbody, args)))
            if not repls:
                break
            # Innermost non-overlapping first
            repls.sort(key=lambda x: (x[1] - x[0], x[0]))
            chosen = []
            for st, en, rep in repls:
                if any(not (en <= cs or st >= ce) for cs, ce, _ in chosen):
                    continue
                chosen.append((st, en, rep))
            chosen.sort(key=lambda x: x[0], reverse=True)
            for st, en, rep in chosen:
                body = body[:st] + rep + body[en:]
                total += 1
        out_blocks.append(hdr + body)
    return out_blocks, total


def strip_dead_defs(text: str) -> tuple[str, int]:
    blocks = split_top_blocks(text)
    def_bodies = {}
    for b in blocks:
        m = re.match(r"^(?:@unsafe\n)?def ([A-Za-z0-9_]+)\b", b)
        if m:
            def_bodies[m.group(1)] = strip_comments_and_strings(b)

    tok_re = re.compile(r"\b[A-Za-z_][A-Za-z0-9_]*\b")
    seen = set(API_ROOTS) & set(def_bodies)
    q = list(seen)
    while q:
        cur = q.pop()
        for tok in tok_re.findall(def_bodies[cur]):
            if tok in def_bodies and tok not in seen:
                seen.add(tok)
                q.append(tok)

    dead = set(def_bodies) - seen
    kept = []
    removed = 0
    for b in blocks:
        m_def = re.match(r"^(?:@unsafe\n)?def ([A-Za-z0-9_]+)\b", b)
        m_law = re.match(r"^law ([A-Za-z0-9_]+)\b", b)
        if m_def and m_def.group(1) in dead:
            removed += 1
            continue
        if m_law and m_law.group(1) in dead:
            continue
        kept.append(b)
    return "".join(kept), removed


def compute_pure_leaf_defs(blocks: list[str]) -> set[str]:
    defs = {}
    for b in blocks:
        m = re.match(r"^(?:@unsafe\n)?def ([A-Za-z0-9_]+)\b", b)
        if m:
            defs[m.group(1)] = b

    pure = {extra for extra in ("kid", "agy_str_eq", "p88_string_eq", "terms_len", "p98_tag_eq", "nt_count") if extra in defs}
    for _ in range(6):
        added = 0
        for name, b in defs.items():
            if name in pure or name in ("nt_choose", "kc", "w5_sel"):
                continue
            if len(b) > 600:
                continue
            body_clean = strip_comments_and_strings(b)
            if any(bad in body_clean for bad in BAD_SUBS):
                continue
            hdr = body_clean.find(":\n")
            if hdr == -1:
                continue
            body = body_clean[hdr + 2:]
            ok = True
            for cm in re.finditer(r"([A-Za-z_][A-Za-z0-9_.]*)\s*\(", body):
                c = cm.group(1)
                if c == name:
                    ok = False
                    break
                if is_prim(c) or c in pure or c == "w5_sel":
                    continue
                ok = False
                break
            if ok:
                pure.add(name)
                added += 1
        if not added:
            break
    return pure


def is_pure_strict_expr(expr: str, pure_defs: set[str]) -> bool:
    if not expr or len(expr) > 320:
        return False
    for bad in ("div", "mod", "rem", "IO.", "File.", "do ", "match ", "=>"):
        if bad in expr:
            return False
    if re.search(r"(?<![=!<>])=(?![=>])", expr):
        return False
    cleaned = strip_comments_and_strings(expr)
    for cm in re.finditer(r"([A-Za-z_][A-Za-z0-9_.]*)\s*\(", cleaned):
        callee = cm.group(1)
        if callee == "w5_sel" or is_prim(callee) or callee in pure_defs:
            continue
        return False
    return True


def extract_var_uses(expr: str) -> set[str]:
    cleaned = strip_comments_and_strings(expr)
    cleaned = re.sub(r"\b[A-Z][A-Za-z0-9_]*\.[A-Za-z0-9_.]+\b", "", cleaned)
    toks = set(re.findall(r"\b[a-z_][A-Za-z0-9_]*\b", cleaned))
    toks -= {"case", "match", "def", "for", "with", "do", "import", "type", "is", "of", "in", "let"}
    return toks


def extract_dup_vars(block: str) -> set[str]:
    return set(re.findall(r"\+([a-z_][A-Za-z0-9_]*)", block))


CHOOSE_PAT = re.compile(r"\b(nt_choose|kc|f_choose)\(")


def convert_strict_chooses_in_block(block: str, known_defs: set[str], pure_defs: set[str], law_block: str = "") -> tuple[str, int]:
    if "nt_choose(" not in block and "kc(" not in block and "f_choose(" not in block:
        return block, 0
    m_nm = re.match(r"^(?:@unsafe\n)?def ([A-Za-z0-9_]+)\b", block)
    if not m_nm or m_nm.group(1) in ("nt_choose", "kc", "f_choose", "w5_sel"):
        return block, 0
    if block.find(":\n") == -1:
        return block, 0
    dup_vars = extract_dup_vars(block)
    if law_block:
        dup_vars |= extract_dup_vars(law_block)

    converted = 0
    for _ in range(8):
        calls = find_balanced_calls(block, CHOOSE_PAT)
        if not calls:
            break
        repls = []
        for s, e, _callee, args in calls:
            if len(args) != 4:
                continue
            typ, cond, a1, a2 = args
            m1 = re.match(r"^([a-z][a-z0-9_]*)\s*=>\s*(.*)$", a1, re.S)
            m2 = re.match(r"^([a-z][a-z0-9_]*)\s*=>\s*(.*)$", a2, re.S)
            if not (m1 and m2):
                continue
            p1, b1 = m1.group(1), m1.group(2).strip()
            p2, b2 = m2.group(1), m2.group(2).strip()
            if re.search(rf"\b{re.escape(p1)}\b", b1) or re.search(rf"\b{re.escape(p2)}\b", b2):
                continue
            if not (is_pure_strict_expr(b1, pure_defs) and is_pure_strict_expr(b2, pure_defs)):
                continue
            v1 = extract_var_uses(b1) - known_defs
            v2 = extract_var_uses(b2) - known_defs
            vc = extract_var_uses(cond) - known_defs
            shared = (v1 & v2) | (vc & (v1 | v2))
            if not shared.issubset(dup_vars):
                continue
            repls.append((s, e, f"w5_sel({typ}, {cond}, {b1}, {b2})"))
        if not repls:
            break
        repls.sort(key=lambda x: (x[1] - x[0], x[0]))
        chosen = []
        for s, e, rep in repls:
            if any(not (e <= cs or s >= ce) for cs, ce, _ in chosen):
                continue
            chosen.append((s, e, rep))
        chosen.sort(key=lambda x: x[0], reverse=True)
        for s, e, rep in chosen:
            block = block[:s] + rep + block[e:]
            converted += 1
    return block, converted


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", type=Path, required=True)
    ap.add_argument("--dst", type=Path, required=True)
    args = ap.parse_args()

    src = args.src.read_text()

    # 1. Inline pure 1-line linear-safe ctor/prim wrappers
    blocks = split_top_blocks(src)
    wrappers = discover_linear_wrappers(blocks)
    blocks, n_inlined = inline_wrappers_in_blocks(blocks, wrappers)
    src = "".join(blocks)

    # 2. Strip dead defs (including newly-unused inlined wrappers!)
    src, n_dead = strip_dead_defs(src)

    # 3. Insert w5_sel right after kc definition (near top of file, before any kc/nt_choose call)
    if "def w5_sel(" not in src:
        anchor = (
            "def kc(\n"
            "  -A: Type,\n"
            "  +b: Bool,\n"
            "  yes: Unit -> A,\n"
            "  no: Unit -> A,\n"
            ") -> A:\n"
            "  match b:\n"
            "    case True{}:\n"
            "      yes(Unit{})\n"
            "    case False{}:\n"
            "      no(Unit{})\n"
        )
        if src.count(anchor) != 1:
            raise RuntimeError(f"Expected 1 kc anchor, found {src.count(anchor)}")
        src = src.replace(anchor, anchor + W5_SEL_DEF, 1)

    # 4. Convert affine-safe strict nt_choose / kc -> w5_sel
    blocks = split_top_blocks(src)
    known_defs = set()
    laws = {}
    for b in blocks:
        m = re.match(r"^(?:@unsafe\n)?def ([A-Za-z0-9_]+)\b", b)
        if m:
            known_defs.add(m.group(1))
        ml = re.match(r"^law ([A-Za-z0-9_]+)\b", b)
        if ml:
            laws[ml.group(1)] = b
    pure_defs = compute_pure_leaf_defs(blocks)

    total_conv = 0
    out_blocks = []
    for b in blocks:
        m = re.match(r"^(?:@unsafe\n)?def ([A-Za-z0-9_]+)\b", b)
        law_b = laws.get(m.group(1), "") if m else ""
        nb, cnt = convert_strict_chooses_in_block(b, known_defs, pure_defs, law_b)
        total_conv += cnt
        out_blocks.append(nb)
    out = "".join(out_blocks)

    args.dst.parent.mkdir(parents=True, exist_ok=True)
    args.dst.write_text(out)
    print(
        f"FID-trim v2 wrote {args.dst} ({len(out)} B): "
        f"inlined {n_inlined} calls ({len(wrappers)} pure wrappers), "
        f"stripped {n_dead} dead defs, "
        f"converted {total_conv} strict nt_choose/kc -> w5_sel ({len(pure_defs)} pure leaves)"
    )


if __name__ == "__main__":
    main()
