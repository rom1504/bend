#!/usr/bin/env python3
"""Extract real K=8 compiler modules from selfhost/build/agy/wave8_unified/compiler.bend.

Key invariant: in Bend, a `law X(...) -> T` and its implementing `def X(...):` share the
same name `X`. We pair every `law X` with its `def X` into a single declaration unit so
`law X` always stays with (and precedes) `def X`, preserving exact Tarjan SCCs and valid
Bend parsing/typechecking.
"""
from __future__ import annotations

import json
import re
import sys
from collections import deque
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
COMPILER_BEND = ROOT / "selfhost/build/agy/wave8_unified/compiler.bend"
sys.path.insert(0, str(ROOT / "research/agy/w8_mod_split"))
import analyze_sccs as scc_mod


def extract_types_and_units(path: Path):
    lines = path.read_text().splitlines(keepends=True)
    n = len(lines)
    raw_decls = []
    type_blocks = []
    import_lines = []
    i = 0
    pending_start = None
    while i < n:
        line = lines[i]
        if line.startswith("import "):
            import_lines.append(line)
            i += 1
            continue
        if line.startswith("@unsafe"):
            if pending_start is None:
                pending_start = i
            i += 1
            continue
        m_type = scc_mod.DECL_TYPE_RE.match(line)
        if m_type:
            start = pending_start if pending_start is not None else i
            pending_start = None
            j = i + 1
            while j < n:
                lj = lines[j]
                if lj.strip() == "" or lj[0].isspace() or lj.startswith("#"):
                    j += 1
                else:
                    break
            type_blocks.append("".join(lines[start:j]))
            i = j
            continue
        m_def = scc_mod.DECL_DEF_RE.match(line)
        if m_def:
            kind, name = m_def.group(1), m_def.group(2)
            start = pending_start if pending_start is not None else i
            pending_start = None
            j = i + 1
            while j < n:
                lj = lines[j]
                if (
                    lj.startswith("def ")
                    or lj.startswith("law ")
                    or lj.startswith("type ")
                    or lj.startswith("@unsafe")
                    or lj.startswith("import ")
                ):
                    break
                j += 1
            block = "".join(lines[start:j])
            raw_decls.append({
                "kind": kind,
                "name": name,
                "start_line": start + 1,
                "end_line": j,
                "bytes": len(block),
                "text": block,
            })
            i = j
            continue
        i += 1

    # Merge matching `law X` + `def X` into a single unit (law_text + def_text)
    laws_by_name: dict[str, dict] = {}
    units: list[dict] = []
    used_laws: set[str] = set()
    for d in raw_decls:
        if d["kind"] == "law":
            laws_by_name[d["name"]] = d
    for d in raw_decls:
        if d["kind"] == "law":
            continue
        law_d = laws_by_name.get(d["name"])
        if law_d is not None:
            used_laws.add(d["name"])
            units.append({
                "name": d["name"],
                "has_law": True,
                "law_text": law_d["text"],
                "def_text": d["text"],
                "text": law_d["text"] + "\n" + d["text"],
                "bytes": law_d["bytes"] + d["bytes"],
            })
        else:
            units.append({
                "name": d["name"],
                "has_law": False,
                "law_text": "",
                "def_text": d["text"],
                "text": d["text"],
                "bytes": d["bytes"],
            })
    # Include any standalone laws (not paired with a def) in type_blocks
    orphan_laws = [d["text"] for d in raw_decls if d["kind"] == "law" and d["name"] not in used_laws]
    return import_lines, type_blocks + orphan_laws, units


def partition_k8(units):
    n = len(units)
    name_to_id = {u["name"]: idx for idx, u in enumerate(units)}
    adj = [[] for _ in range(n)]
    for u, d in enumerate(units):
        clean = scc_mod.strip_strings_and_comments(d["text"])
        seen = set()
        for tok in scc_mod.IDENT_RE.findall(clean):
            v = name_to_id.get(tok)
            if v is not None and v != u and v not in seen:
                seen.add(v)
        adj[u] = sorted(seen)

    sccs = scc_mod.tarjan_scc(n, adj)
    num_sccs = len(sccs)
    node_to_scc = [0] * n
    scc_bytes = [0] * num_sccs
    for si, comp in enumerate(sccs):
        b = 0
        for u in comp:
            node_to_scc[u] = si
            b += units[u]["bytes"]
        scc_bytes[si] = b

    dag_deps = [set() for _ in range(num_sccs)]
    dag_rdeps = [set() for _ in range(num_sccs)]
    for u in range(n):
        su = node_to_scc[u]
        for v in adj[u]:
            sv = node_to_scc[v]
            if su != sv:
                dag_deps[su].add(sv)
                dag_rdeps[sv].add(su)

    indeg = [len(dag_deps[si]) for si in range(num_sccs)]
    q = deque(si for si in range(num_sccs) if indeg[si] == 0)
    topo = []
    while q:
        u = q.popleft()
        topo.append(u)
        for nxt in dag_rdeps[u]:
            indeg[nxt] -= 1
            if indeg[nxt] == 0:
                q.append(nxt)
    assert len(topo) == num_sccs

    k = 8
    total_bytes = sum(scc_bytes)
    target = total_bytes / k
    modules = []
    cur = []
    cur_b = 0
    rem_b = total_bytes
    for s in topo:
        sb = scc_bytes[s]
        mods_left = k - len(modules)
        if mods_left > 1 and cur and (cur_b + sb > target * 1.05 and cur_b >= target * 0.55):
            modules.append(cur)
            cur = [s]
            cur_b = sb
            rem_b -= sb
            target = (rem_b + sb) / (k - len(modules))
        else:
            cur.append(s)
            cur_b += sb
            rem_b -= sb
    if cur:
        modules.append(cur)

    mod_nodes = []
    for comps in modules:
        nodes = sorted(u for s in comps for u in sccs[s])
        mod_nodes.append(nodes)

    return adj, sccs, node_to_scc, mod_nodes


def split_top_level(s: str, sep: str = ",") -> list[str]:
    parts = []
    depth = 0
    cur = []
    for i, ch in enumerate(s):
        if ch in "([{<":
            depth += 1
            cur.append(ch)
        elif ch in ")]}" or (ch == ">" and (i == 0 or s[i - 1] != "-")):
            depth -= 1
            cur.append(ch)
        elif ch == sep and depth == 0:
            parts.append("".join(cur).strip())
            cur = []
        else:
            cur.append(ch)
    tail = "".join(cur).strip()
    if tail:
        parts.append(tail)
    return parts


def parse_header_sig(block: str, kw: str = "def") -> dict | None:
    lines = block.splitlines()
    start_idx = 0
    while start_idx < len(lines) and not lines[start_idx].startswith(kw + " "):
        start_idx += 1
    if start_idx >= len(lines):
        return None

    hdr_lines = []
    depth = 0
    for idx in range(start_idx, len(lines)):
        ln = lines[idx]
        code = ln.split("#", 1)[0]
        hdr_lines.append(code)
        for ci, ch in enumerate(code):
            if ch in "([{<":
                depth += 1
            elif ch in ")]}" or (ch == ">" and (ci == 0 or code[ci - 1] != "-")):
                depth -= 1
        if kw == "law":
            if depth == 0 and "->" in code:
                break
        else:
            if depth == 0 and code.rstrip().endswith(":"):
                break
    hdr = " ".join(x.strip() for x in hdr_lines).strip()
    if kw == "def":
        if not hdr.endswith(":"):
            return None
        hdr_no_colon = hdr[:-1].strip()
    else:
        hdr_no_colon = hdr.rstrip(":").strip()

    m = re.match(rf"^{kw}\s+([A-Za-z_][A-Za-z0-9_.]*)\s*(.*)$", hdr_no_colon)
    if not m:
        return None
    name = m.group(1)
    rest = m.group(2).strip()

    templates = []
    if rest.startswith("<"):
        depth = 0
        end = -1
        for i, ch in enumerate(rest):
            if ch == "<":
                depth += 1
            elif ch == ">":
                depth -= 1
                if depth == 0:
                    end = i
                    break
        if end == -1:
            return None
        templates = split_top_level(rest[1:end], ",")
        rest = rest[end + 1:].strip()

    params = []
    if rest.startswith("("):
        depth = 0
        end = -1
        for i, ch in enumerate(rest):
            if ch == "(":
                depth += 1
            elif ch == ")":
                depth -= 1
                if depth == 0:
                    end = i
                    break
        if end == -1:
            return None
        param_str = rest[1:end].strip()
        if param_str:
            for p in split_top_level(param_str, ","):
                colon_pos = -1
                d = 0
                for i, ch in enumerate(p):
                    if ch in "([{<":
                        d += 1
                    elif ch in ")]}" or (ch == ">" and (i == 0 or p[i - 1] != "-")):
                        d -= 1
                    elif ch == ":" and d == 0:
                        colon_pos = i
                        break
                if colon_pos == -1:
                    pname = p.strip()
                    q = ""
                    while pname and pname[0] in "+-&~":
                        q += pname[0]
                        pname = pname[1:].strip()
                    params.append({"quant": q, "name": pname, "type": None, "raw": p})
                else:
                    lhs = p[:colon_pos].strip()
                    typ = p[colon_pos + 1:].strip()
                    q = ""
                    pname = lhs
                    while pname and pname[0] in "+-&~":
                        q += pname[0]
                        pname = pname[1:].strip()
                    params.append({"quant": q, "name": pname, "type": typ, "raw": p})
        rest = rest[end + 1:].strip()
        if rest.startswith("->"):
            ret_type = rest[2:].strip()
            untyped = False
        elif rest == "":
            ret_type = None
            untyped = True
        else:
            return None
        is_val = False
    elif rest.startswith(":"):
        ret_type = rest[1:].strip()
        is_val = True
        untyped = False
    elif rest == "":
        ret_type = None
        is_val = True
        untyped = True
    else:
        return None

    return {
        "name": name,
        "templates": templates,
        "params": params,
        "ret_type": ret_type,
        "is_val": is_val,
        "untyped": untyped,
        "hdr": hdr,
    }


def make_stub(unit: dict) -> str:
    prefix = (unit["law_text"] + "\n") if unit["has_law"] else ""
    sig = parse_header_sig(unit["def_text"], "def")
    if sig is None:
        return unit["text"]
    if sig["is_val"] or not sig["params"]:
        if sig["is_val"]:
            return f"{prefix}@unsafe\n{sig['hdr']}\n  {sig['name']}\n\n"
        return f"{prefix}@unsafe\n{sig['hdr']}\n  {sig['name']}()\n\n"
    new_params = []
    call_args = []
    for idx, p in enumerate(sig["params"]):
        pname = p["name"]
        if not pname or pname == "_":
            pname = f"_w9p{idx}"
            if p["type"] is None:
                new_params.append(f"{p['quant']}{pname}")
            else:
                new_params.append(f"{p['quant']}{pname}: {p['type']}")
        else:
            new_params.append(p["raw"])
        call_args.append(pname)
    tmpl = f"<{', '.join(sig['templates'])}>" if sig["templates"] else ""
    if sig["untyped"]:
        hdr = f"def {sig['name']}{tmpl}({', '.join(new_params)}):"
    else:
        hdr = f"def {sig['name']}{tmpl}({', '.join(new_params)}) -> {sig['ret_type']}:"
    return f"{prefix}@unsafe\n{hdr}\n  {sig['name']}({', '.join(call_args)})\n\n"


def make_touch_expr(unit: dict) -> str | None:
    sig = parse_header_sig(unit["law_text"], "law") if unit["has_law"] else parse_header_sig(unit["def_text"], "def")
    if sig is None or sig["templates"] or sig["untyped"]:
        return None
    if any(p["type"] is None or "~" in p["quant"] for p in sig["params"]):
        return None
    # Skip `for ...` dependent law signatures that aren't simple `(args) -> ret`
    if sig["ret_type"] and (sig["ret_type"].startswith("for ") or " for " in sig["ret_type"]):
        return None
    subst: dict[str, str] = {}
    args_code = []
    val_param_names = set()
    for p in sig["params"]:
        t = p["type"]
        if t.startswith("for ") or " for " in t:
            return None
        for k, v in subst.items():
            t = re.sub(rf"\b{re.escape(k)}\b", v, t)
        if t in ("Type", "Data", "Set"):
            subst[p["name"]] = "U32"
            args_code.append("U32")
        else:
            if any(kw in re.findall(r"\b[A-Za-z_][A-Za-z0-9_]*\b", t) for kw in ("Type", "Data", "Set")):
                return None
            if any(re.search(rf"\b{re.escape(vn)}\b", t) for vn in val_param_names):
                return None
            if p["name"]:
                val_param_names.add(p["name"])
            args_code.append(f"w9_bot({t})")
    ret = sig["ret_type"]
    for k, v in subst.items():
        ret = re.sub(rf"\b{re.escape(k)}\b", v, ret)
    if any(kw in re.findall(r"\b[A-Za-z_][A-Za-z0-9_]*\b", ret) for kw in ("Type", "Data", "Set")):
        return None
    if any(re.search(rf"\b{re.escape(vn)}\b", ret) for vn in val_param_names):
        return None
    if sig["is_val"]:
        call = sig["name"]
    else:
        call = f"{sig['name']}({', '.join(args_code)})"
    return f"w9_touch({ret}, {call})"


def build_module(
    mod_idx: int,
    type_header: str,
    units: list[dict],
    adj: list[list[int]],
    sccs: list[list[int]],
    node_to_scc: list[int],
    mod_nodes: list[list[int]],
    out_path: Path,
) -> dict:
    nodes = mod_nodes[mod_idx]
    node_set = set(nodes)
    ext_deps = sorted({v for u in nodes for v in adj[u] if v not in node_set})

    stub_blocks = []
    stub_fallbacks = 0
    for v in ext_deps:
        u = units[v]
        st = make_stub(u)
        if st == u["text"]:
            stub_fallbacks += 1
        stub_blocks.append(st)

    # Root SCCs within this module
    mod_sccs = sorted({node_to_scc[u] for u in nodes})
    called_sccs = set()
    for u in nodes:
        su = node_to_scc[u]
        for v in adj[u]:
            if v in node_set:
                sv = node_to_scc[v]
                if sv != su:
                    called_sccs.add(sv)
    root_sccs = [s for s in mod_sccs if s not in called_sccs]

    touch_exprs = []
    touched_roots = 0
    skipped_roots = 0
    for s in root_sccs:
        expr = None
        for u in sccs[s]:
            if units[u]["name"] == "main":
                continue
            expr = make_touch_expr(units[u])
            if expr is not None:
                break
        if expr is not None:
            touch_exprs.append(expr)
            touched_roots += 1
        else:
            skipped_roots += 1

    body_blocks = []
    for u in nodes:
        txt = units[u]["text"]
        if units[u]["name"] == "main":
            txt = txt.replace("def main(", "def w9_orig_main(", 1)
        body_blocks.append(txt)

    helpers = [
        "\n@unsafe\ndef w9_bot(-A: Type) -> A:\n  w9_bot(A)\n",
        "\n@unsafe\ndef w9_touch(-A: Type, x: A) -> U32:\n  w9_touch(A, x)\n",
    ]
    chunk_names = []
    chunk_size = 16
    for ci in range(0, len(touch_exprs), chunk_size):
        chunk = touch_exprs[ci:ci + chunk_size]
        cname = f"w9_chunk_{ci // chunk_size}"
        chunk_names.append(cname)
        body_lines = []
        prev = "acc"
        for ei, e in enumerate(chunk):
            var = f"v{ei}"
            body_lines.append(f"  +{var} = U32.add({prev}, {e})")
            prev = var
        body_lines.append(f"  {prev}")
        helpers.append(f"\n@unsafe\ndef {cname}(+acc: U32) -> U32:\n" + "\n".join(body_lines) + "\n")

    if chunk_names:
        dead_lines = []
        prev = "0"
        for ci, cn in enumerate(chunk_names):
            var = f"c{ci}"
            dead_lines.append(f"      +{var} = {cn}({prev})")
            prev = var
        dead_lines.append(f"      {prev}")
        dead_body = "\n" + "\n".join(dead_lines)
    else:
        dead_body = " 0"

    helpers.append(
        "\n@unsafe\n"
        "def w9_flag_go(+done: Bool, +n: U32) -> Bool:\n"
        "  match done:\n"
        "    case True{}: False{}\n"
        "    case False{}: w9_flag(U32.sub(n, 1))\n"
        "\n@unsafe\n"
        "def w9_flag(+n: U32) -> Bool:\n"
        "  w9_flag_go(U32.is_eq(n, 0), n)\n"
        "\n@unsafe\n"
        "def w9_dead(+b: Bool) -> U32:\n"
        "  match b:\n"
        f"    case True{{}}:{dead_body}\n"
        "    case False{}: 0\n"
        "\n"
        "def main() -> U32:\n"
        "  w9_dead(w9_flag(0))\n"
    )

    full_src = (
        type_header
        + "\n# === W9 EXTERNAL STUBS ===\n"
        + "".join(stub_blocks)
        + "\n# === W9 REAL MODULE BODY ===\n"
        + "".join(body_blocks)
        + "\n# === W9 SYNTHETIC LIVE ROOT ===\n"
        + "".join(helpers)
    )
    out_path.write_text(full_src)

    return {
        "mod": mod_idx,
        "path": str(out_path),
        "total_src_bytes": len(full_src),
        "body_bytes": sum(units[u]["bytes"] for u in nodes),
        "type_header_bytes": len(type_header),
        "stub_bytes": sum(len(s) for s in stub_blocks),
        "real_defs": len(nodes),
        "real_laws": sum(1 for u in nodes if units[u]["has_law"]),
        "ext_stub_defs": len(ext_deps),
        "ext_stub_fallbacks": stub_fallbacks,
        "root_sccs": len(root_sccs),
        "touched_root_sccs": touched_roots,
        "skipped_root_sccs": skipped_roots,
    }


def main():
    out_dir = Path("/tmp/agy_w9_mod_compiler")
    out_dir.mkdir(parents=True, exist_ok=True)
    import_lines, type_blocks, units = extract_types_and_units(COMPILER_BEND)
    type_header = "".join(import_lines) + "\n" + "".join(type_blocks)
    adj, sccs, node_to_scc, mod_nodes = partition_k8(units)

    metas = []
    for mi in (0, 1, 2):
        meta = build_module(
            mi, type_header, units, adj, sccs, node_to_scc, mod_nodes,
            out_dir / f"mod{mi}.bend",
        )
        metas.append(meta)
        print(json.dumps(meta))
    (out_dir / "extract_meta.json").write_text(json.dumps(metas, indent=2) + "\n")


if __name__ == "__main__":
    main()
