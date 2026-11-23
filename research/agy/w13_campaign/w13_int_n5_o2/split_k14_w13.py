#!/usr/bin/env python3
"""Split selfhost/build/agy/wave13_unified/compiler.bend into K=14 strictly acyclic,
balanced .bend modules (m00a, m00b, m01..m04, m05a, m05b, m06..m11) + frozen types.bend
+ manifest.txt + manifest.json.

All outputs are written inside research/agy/w10_mod_bend/k14_wave13/.
"""
from __future__ import annotations

import json
import re
import time
from collections import deque
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
COMPILER_BEND = ROOT / "selfhost/build/agy/wave13_unified/compiler.bend"
OUT_DIR = ROOT / "research/agy/w10_mod_bend/k14_wave13"
OBJ_DIR = OUT_DIR / "obj"

BASE_K = 12
FID_MAX = 65531

IDENT_RE = re.compile(r"\b[A-Za-z_][A-Za-z0-9_.]*\b")
DECL_DEF_RE = re.compile(r"^(def|law)\s+([A-Za-z_][A-Za-z0-9_.]*)")
DECL_TYPE_RE = re.compile(r"^type\s+([A-Za-z_][A-Za-z0-9_.]*)")


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
    lines = path.read_text().splitlines(keepends=True)
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


def tarjan_scc(num_nodes: int, adj: list[list[int]]) -> list[list[int]]:
    index_counter = 0
    index = [-1] * num_nodes
    lowlink = [0] * num_nodes
    on_stack = [False] * num_nodes
    stack: list[int] = []
    sccs: list[list[int]] = []

    for start in range(num_nodes):
        if index[start] != -1:
            continue
        call_stack: list[tuple[int, int]] = [(start, 0)]
        index[start] = lowlink[start] = index_counter
        index_counter += 1
        stack.append(start)
        on_stack[start] = True

        while call_stack:
            v, ei = call_stack[-1]
            nbrs = adj[v]
            if ei < len(nbrs):
                call_stack[-1] = (v, ei + 1)
                w = nbrs[ei]
                if index[w] == -1:
                    index[w] = lowlink[w] = index_counter
                    index_counter += 1
                    stack.append(w)
                    on_stack[w] = True
                    call_stack.append((w, 0))
                elif on_stack[w]:
                    if index[w] < lowlink[v]:
                        lowlink[v] = index[w]
            else:
                call_stack.pop()
                if call_stack:
                    parent = call_stack[-1][0]
                    if lowlink[v] < lowlink[parent]:
                        lowlink[parent] = lowlink[v]
                if lowlink[v] == index[v]:
                    comp = []
                    while True:
                        w = stack.pop()
                        on_stack[w] = False
                        comp.append(w)
                        if w == v:
                            break
                    sccs.append(comp)
    return sccs


def partition_topological(topo_sccs: list[int], scc_bytes: list[int], k: int) -> list[list[int]]:
    total_bytes = sum(scc_bytes)
    target = total_bytes / k
    modules: list[list[int]] = []
    cur: list[int] = []
    cur_b = 0
    rem_b = total_bytes

    for s in topo_sccs:
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

    assert len(modules) == k, f"Expected {k} modules, got {len(modules)}"
    return modules


def split_in_half(sccs_list: list[int], scc_bytes: list[int], label: str) -> tuple[list[int], list[int]]:
    total = sum(scc_bytes[s] for s in sccs_list)
    half_target = total / 2.0
    a, b = [], []
    acc_b = 0
    for s in sccs_list:
        if acc_b < half_target or not a:
            a.append(s)
            acc_b += scc_bytes[s]
        else:
            b.append(s)
    assert a and b, f"Failed to split {label}: len(a)={len(a)} len(b)={len(b)}"
    return a, b


def main() -> None:
    t0 = time.perf_counter()
    imports, types, decls = parse_compiler_bend(COMPILER_BEND)
    n = len(decls)

    name_to_ids: dict[str, list[int]] = {}
    for idx, d in enumerate(decls):
        name_to_ids.setdefault(d["name"], []).append(idx)

    adj: list[list[int]] = [[] for _ in range(n)]
    total_edges = 0
    for u, d in enumerate(decls):
        seen: set[int] = set()
        for mate in name_to_ids[d["name"]]:
            if mate != u:
                seen.add(mate)
        clean = strip_strings_and_comments(d["text"])
        for tok in IDENT_RE.findall(clean):
            if tok == "main":
                continue
            targets = name_to_ids.get(tok)
            if targets is not None:
                for v in targets:
                    if v != u:
                        seen.add(v)
        adj[u] = sorted(seen)
        total_edges += len(seen)

    sccs = tarjan_scc(n, adj)
    num_sccs = len(sccs)
    node_to_scc = [0] * n
    scc_bytes = [0] * num_sccs
    for si, comp in enumerate(sccs):
        b = 0
        for u in comp:
            node_to_scc[u] = si
            b += decls[u]["bytes"]
        scc_bytes[si] = b

    dag_deps: list[set[int]] = [set() for _ in range(num_sccs)]
    dag_rdeps: list[set[int]] = [set() for _ in range(num_sccs)]
    for u in range(n):
        su = node_to_scc[u]
        for v in adj[u]:
            sv = node_to_scc[v]
            if su != sv:
                dag_deps[su].add(sv)
                dag_rdeps[sv].add(su)

    main_ids = name_to_ids.get("main", [])
    assert len(main_ids) == 1, f"Expected exactly 1 main decl, got {main_ids}"
    main_scc = node_to_scc[main_ids[0]]
    assert len(dag_rdeps[main_scc]) == 0, f"Unexpected callers of main SCC: {dag_rdeps[main_scc]}"

    indeg = [len(dag_deps[si]) for si in range(num_sccs)]
    q = deque(si for si in range(num_sccs) if indeg[si] == 0 and si != main_scc)
    topo: list[int] = []
    main_ready = (indeg[main_scc] == 0)
    while q:
        u = q.popleft()
        topo.append(u)
        for nxt in dag_rdeps[u]:
            indeg[nxt] -= 1
            if indeg[nxt] == 0:
                if nxt == main_scc:
                    main_ready = True
                else:
                    q.append(nxt)
    assert main_ready, "main_scc never became ready (cycle in SCC DAG!)"
    topo.append(main_scc)
    assert len(topo) == num_sccs, f"SCC DAG cycle! {len(topo)} != {num_sccs}"

    base_mods = partition_topological(topo, scc_bytes, BASE_K)
    m00a, m00b = split_in_half(base_mods[0], scc_bytes, "m00")
    m05a, m05b = split_in_half(base_mods[5], scc_bytes, "m05")

    modules_sccs = [m00a, m00b] + base_mods[1:5] + [m05a, m05b] + base_mods[6:]
    mod_names = (
        ["m00a", "m00b"]
        + [f"m{i:02d}" for i in range(1, 5)]
        + ["m05a", "m05b"]
        + [f"m{i:02d}" for i in range(6, BASE_K)]
    )
    K = len(modules_sccs)
    assert K == 14

    decl_to_mod = [-1] * n
    for mi, comps in enumerate(modules_sccs):
        for s in comps:
            for u in sccs[s]:
                assert decl_to_mod[u] == -1, f"Duplicate decl assignment for {decls[u]['name']}"
                decl_to_mod[u] = mi
    assert all(m != -1 for m in decl_to_mod), "Unassigned decl!"
    assert decl_to_mod[main_ids[0]] == K - 1, f"main not in {mod_names[-1]}!"

    mod_deps: list[set[int]] = [set() for _ in range(K)]
    mod_import_syms: list[set[str]] = [set() for _ in range(K)]
    forward_violations = 0
    for u in range(n):
        mu = decl_to_mod[u]
        for v in adj[u]:
            mv = decl_to_mod[v]
            if mv > mu:
                forward_violations += 1
            elif mv < mu:
                mod_deps[mu].add(mv)
                mod_import_syms[mu].add(decls[v]["name"])
    assert forward_violations == 0, f"Found {forward_violations} forward cross-module references!"

    fid_slots = [3400, 3400] + [5000] * 4 + [3200, 3200] + [5000] * 5 + [FID_MAX + 1 - (3400 * 2 + 5000 * 9 + 3200 * 2)]
    fid_bases: list[int] = []
    cur_fid = 0
    for sl in fid_slots:
        fid_bases.append(cur_fid)
        cur_fid += sl
    assert cur_fid == FID_MAX + 1

    OUT_DIR.mkdir(parents=True, exist_ok=True)

    types_parts = [
        "# Frozen shared type header for K=14 modular split of wave13_unified/compiler.bend\n",
        f"# Canonical cid order preserved verbatim ({len(types)} type declarations).\n",
    ]
    types_parts.extend(imports)
    types_parts.append("\n")
    for t in types:
        txt = t["text"]
        types_parts.append(txt if txt.endswith("\n") else txt + "\n")
    types_path = OUT_DIR / "types.bend"
    types_path.write_text("".join(types_parts))
    types_bytes = types_path.stat().st_size

    mod_records = []
    manifest_lines = [
        "# Wave 13 K=14 strictly acyclic modular manifest for wave13_unified/compiler.bend",
        "#   <name> <src_path> <fid_base> <out_o_path>",
        f"# Shared types header: {types_path}",
        "",
    ]

    for mi in range(K):
        mod_name = mod_names[mi]
        mod_decl_ids = [u for s in modules_sccs[mi] for u in sccs[s]]
        mod_decl_ids.sort(key=lambda u: decls[u]["start_line"])

        def_cnt = sum(1 for u in mod_decl_ids if decls[u]["kind"] == "def")
        law_cnt = sum(1 for u in mod_decl_ids if decls[u]["kind"] == "law")
        has_main = main_ids[0] in mod_decl_ids
        fid_base = fid_bases[mi]
        fid_limit = fid_base + fid_slots[mi] - 1
        assert fid_base <= fid_limit <= FID_MAX

        deps_list = [mod_names[d] for d in sorted(mod_deps[mi])]
        deps_str = ",".join(deps_list) or "none"
        header = (
            f"# Module {mod_name} (K={K} acyclic topological split of wave13_unified/compiler.bend)\n"
            f"# defs={def_cnt} laws={law_cnt} sccs={len(modules_sccs[mi])} "
            f"deps=[{deps_str}] cross_imports={len(mod_import_syms[mi])} "
            f"fid_base={fid_base}..{fid_limit}\n\n"
        )
        body_parts = [header]
        for u in mod_decl_ids:
            txt = decls[u]["text"]
            body_parts.append(txt if txt.endswith("\n") else txt + "\n")
        mod_path = OUT_DIR / f"{mod_name}.bend"
        mod_path.write_text("".join(body_parts))
        mod_bytes = mod_path.stat().st_size
        out_o_path = OBJ_DIR / f"{mod_name}.o"

        manifest_lines.append(f"{mod_name} {mod_path} {fid_base} {out_o_path}")
        mod_records.append({
            "name": mod_name,
            "index": mi,
            "src_path": str(mod_path),
            "out_o_path": str(out_o_path),
            "bytes": mod_bytes,
            "kb": round(mod_bytes / 1024.0, 1),
            "with_types_kb": round((mod_bytes + types_bytes) / 1024.0, 1),
            "scc_count": len(modules_sccs[mi]),
            "def_count": def_cnt,
            "law_count": law_cnt,
            "total_decls": len(mod_decl_ids),
            "deps": deps_list,
            "cross_mod_import_symbols": len(mod_import_syms[mi]),
            "fid_base": fid_base,
            "fid_limit": fid_limit,
            "fid_slots": fid_slots[mi],
            "has_main": has_main,
        })

    (OUT_DIR / "manifest.txt").write_text("\n".join(manifest_lines) + "\n")

    emitted_types = 0
    emitted_defs = 0
    emitted_laws = 0
    for line in types_path.read_text().splitlines():
        if DECL_TYPE_RE.match(line):
            emitted_types += 1
        elif DECL_DEF_RE.match(line):
            raise AssertionError(f"Unexpected def/law in types.bend: {line}")
    for rec in mod_records:
        for line in Path(rec["src_path"]).read_text().splitlines():
            if DECL_TYPE_RE.match(line):
                raise AssertionError(f"Unexpected type in {rec['name']}.bend: {line}")
            m = DECL_DEF_RE.match(line)
            if m:
                if m.group(1) == "def":
                    emitted_defs += 1
                else:
                    emitted_laws += 1

    orig_defs = sum(1 for d in decls if d["kind"] == "def")
    orig_laws = sum(1 for d in decls if d["kind"] == "law")
    assert emitted_types == len(types)
    assert emitted_defs == orig_defs
    assert emitted_laws == orig_laws

    elapsed_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    manifest_json = {
        "source": str(COMPILER_BEND),
        "source_bytes": COMPILER_BEND.stat().st_size,
        "source_kb": round(COMPILER_BEND.stat().st_size / 1024.0, 1),
        "k": K,
        "types_bend": {
            "path": str(types_path),
            "type_count": len(types),
            "bytes": types_bytes,
            "kb": round(types_bytes / 1024.0, 1),
        },
        "totals": {
            "type_count": emitted_types,
            "def_count": emitted_defs,
            "law_count": emitted_laws,
            "total_def_law": emitted_defs + emitted_laws,
            "scc_count": num_sccs,
            "call_graph_edges": total_edges,
            "forward_cross_mod_edges": forward_violations,
            "lost_decls": 0,
            "duplicated_decls": 0,
        },
        "fid_budget": {
            "m00a_m00b_slots": 3400,
            "m05a_m05b_slots": 3200,
            "other_slots": 5000,
            "max_fid": FID_MAX,
        },
        "modules": mod_records,
        "split_ms": elapsed_ms,
    }
    (OUT_DIR / "manifest.json").write_text(json.dumps(manifest_json, indent=2) + "\n")

    print(f"=== K={K} Acyclic Split Complete ({elapsed_ms} ms) ===")
    print(f"Totals: types={emitted_types} defs={emitted_defs} laws={emitted_laws} (0 lost, 0 dup, 0 cycles)")
    for r in mod_records:
        print(
            f"  {r['name']:<4} {r['kb']:6.1f} KB | defs={r['def_count']:4d} laws={r['law_count']:3d} "
            f"sccs={r['scc_count']:4d} | ximp={r['cross_mod_import_symbols']:4d} | fid={r['fid_base']}..{r['fid_limit']}"
        )


if __name__ == "__main__":
    main()
