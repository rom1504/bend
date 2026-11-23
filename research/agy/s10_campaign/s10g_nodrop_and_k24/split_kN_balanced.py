#!/usr/bin/env python3
"""S10-G: Strictly Balanced Zero-Tail K-Module Acyclic Splitter (`split_kN_balanced.py`).

Splits `compiler_pruned.bend` (or `wave15_unified/compiler.bend`) into K strictly
acyclic, size-balanced `.bend` modules + frozen `types.bend` + `manifest.txt` +
`manifest.json`, ready for S10-A2 zero-`.p130` parallel compilation.

Uses Tarjan SCC + topological sort (pinning `main` to `m{K-1}`) + exact binary-search
painter's partition (minimizing max module bytes over all contiguous topological cuts)
with proportional 16-bit FID slot allocation (`0..65531`).
"""
from __future__ import annotations

import argparse
import json
import re
import time
from collections import deque
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
DEFAULT_SRC = ROOT / "selfhost/build/agy/wave15_unified/compiler.bend"

FID_MAX = 65531

TMPL_1ARG = {
    "kc", "f_choose", "nt_choose", "nt_count_go", "nt_reverse",
    "p151_choose", "nt_count", "nt_append",
}
TMPL_CUSTOM = {
    "p134v_list": "p134v_list(U32, U32.is_eq)",
}

IDENT_RE = re.compile(r"\b[A-Za-z_][A-Za-z0-9_.]*\b")
DECL_DEF_RE = re.compile(r"^(def|law)\s+([A-Za-z_][A-Za-z0-9_.]*)")
DECL_TYPE_RE = re.compile(r"^type\s+([A-Za-z_][A-Za-z0-9_.]*)")
STR_OR_CMT_RE = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'|#[^\n]*')


def strip_strings_and_comments(text: str) -> str:
    return STR_OR_CMT_RE.sub(" ", text)


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


def partition_optimal_balanced(topo_sccs: list[int], scc_bytes: list[int], k: int) -> list[list[int]]:
    """Exact binary-search painter's partition minimizing max module bytes.

    Guarantees:
    - Exactly `k` non-empty contiguous slices of `topo_sccs` (so 0 forward edges!).
    - `main_scc` (last element of `topo_sccs`) is always in module `k-1`.
    - Global minimum possible `max(sum(scc_bytes[s] for s in mod))` over all contiguous cuts.
    """
    n_sccs = len(topo_sccs)
    assert n_sccs >= k, f"Not enough SCCs ({n_sccs}) for K={k}"

    weights = [scc_bytes[s] for s in topo_sccs]
    lo = max(weights)
    hi = sum(weights)

    def can_pack(limit: int) -> bool:
        buckets = 1
        cur = 0
        for w in weights:
            if cur + w > limit:
                buckets += 1
                cur = w
                if buckets > k:
                    return False
            else:
                cur += w
        return True

    while lo < hi:
        mid = (lo + hi) // 2
        if can_pack(mid):
            hi = mid
        else:
            lo = mid + 1

    opt_limit = lo

    # Reconstruct balanced buckets with `opt_limit`, ensuring exactly `k` non-empty buckets
    # and avoiding a tiny trailing tail by balancing remaining bytes across remaining buckets.
    prefix = [0] * (n_sccs + 1)
    for i, w in enumerate(weights):
        prefix[i + 1] = prefix[i] + w

    modules: list[list[int]] = []
    idx = 0
    for m in range(k):
        mods_left = k - m
        if mods_left == 1:
            modules.append(topo_sccs[idx:])
            break
        rem_bytes = prefix[n_sccs] - prefix[idx]
        ideal = rem_bytes / mods_left
        # Must leave at least (mods_left - 1) SCCs for remaining modules
        max_end = n_sccs - (mods_left - 1)
        cur_end = idx + 1
        cur_b = weights[idx]
        best_end = -1
        best_diff = float("inf")
        while True:
            # Check if remaining suffix [cur_end..n_sccs) fits into (mods_left - 1) buckets <= opt_limit
            rem_buckets = 1
            rcur = 0
            feasible = True
            for j in range(cur_end, n_sccs):
                wj = weights[j]
                if rcur + wj > opt_limit:
                    rem_buckets += 1
                    rcur = wj
                    if rem_buckets > mods_left - 1:
                        feasible = False
                        break
                else:
                    rcur += wj
            if feasible:
                diff = abs(cur_b - ideal)
                if diff <= best_diff:
                    best_diff = diff
                    best_end = cur_end
            if cur_end >= max_end or cur_b + weights[cur_end] > opt_limit:
                break
            cur_b += weights[cur_end]
            cur_end += 1
        assert best_end > idx, f"No feasible cut for bucket {m} (opt_limit={opt_limit})"
        modules.append(topo_sccs[idx:best_end])
        idx = best_end

    assert len(modules) == k, f"Expected {k} modules, got {len(modules)}"
    assert sum(len(m) for m in modules) == n_sccs
    assert all(len(m) > 0 for m in modules)
    return modules


def allocate_fid_slots(mod_bytes: list[int], total_fids: int = FID_MAX + 1) -> list[int]:
    """Allocate non-overlapping 16-bit FID slots proportional to module bytes."""
    total_b = sum(mod_bytes)
    k = len(mod_bytes)
    min_slot = 512
    assert min_slot * k <= total_fids
    distributable = total_fids - min_slot * k
    raw = [min_slot + int(distributable * (b / total_b)) for b in mod_bytes]
    rem = total_fids - sum(raw)
    # Distribute remainder to largest modules first
    order = sorted(range(k), key=lambda i: mod_bytes[i], reverse=True)
    for idx in range(rem):
        raw[order[idx % k]] += 1
    assert sum(raw) == total_fids
    return raw


def main() -> None:
    ap = argparse.ArgumentParser(description="Strictly balanced acyclic K-module splitter for Bend compiler")
    ap.add_argument("--k", type=int, default=24, help="Number of modules (e.g. 16, 24)")
    ap.add_argument("--src", type=Path, default=DEFAULT_SRC, help="Input monolithic compiler .bend")
    ap.add_argument("--out-dir", type=Path, required=True, help="Output directory")
    args = ap.parse_args()

    out_dir: Path = args.out_dir
    obj_dir = out_dir / "obj"

    t0 = time.perf_counter()
    imports, types, decls = parse_compiler_bend(args.src)
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

    max_scc_b = max(scc_bytes)
    max_scc_idx = scc_bytes.index(max_scc_b)

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

    K = args.k
    modules_sccs = partition_optimal_balanced(topo, scc_bytes, K)
    mod_names = [f"m{i:02d}" for i in range(K)]
    raw_mod_bytes = [sum(scc_bytes[s] for s in comps) for comps in modules_sccs]
    fid_slots = allocate_fid_slots(raw_mod_bytes, FID_MAX + 1)

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

    fid_bases: list[int] = []
    cur_fid = 0
    for sl in fid_slots:
        fid_bases.append(cur_fid)
        cur_fid += sl
    assert cur_fid == FID_MAX + 1

    out_dir.mkdir(parents=True, exist_ok=True)

    types_parts = [
        f"# Frozen shared type header for K={K} balanced split of {args.src.name}\n",
        f"# Canonical cid order preserved verbatim ({len(types)} type declarations).\n",
    ]
    types_parts.extend(imports)
    types_parts.append("\n")
    for t in types:
        txt = t["text"]
        types_parts.append(txt if txt.endswith("\n") else txt + "\n")
    types_path = out_dir / "types.bend"
    types_path.write_text("".join(types_parts), encoding="utf-8")
    types_bytes = types_path.stat().st_size

    mod_records = []
    manifest_lines = [
        f"# S10-G K={K} strictly acyclic balanced manifest for {args.src.name}",
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
            f"# Module {mod_name} (K={K} balanced acyclic split of {args.src.name})\n"
            f"# defs={def_cnt} laws={law_cnt} sccs={len(modules_sccs[mi])} "
            f"deps=[{deps_str}] cross_imports={len(mod_import_syms[mi])} "
            f"fid_base={fid_base}..{fid_limit}\n\n"
        )
        body_parts = [header]
        for u in mod_decl_ids:
            txt = decls[u]["text"]
            body_parts.append(txt if txt.endswith("\n") else txt + "\n")
        mod_path = out_dir / f"{mod_name}.bend"
        mod_path.write_text("".join(body_parts), encoding="utf-8")
        mod_bytes = mod_path.stat().st_size
        out_o_path = obj_dir / f"{mod_name}.o"

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

    (out_dir / "manifest.txt").write_text("\n".join(manifest_lines) + "\n", encoding="utf-8")

    # Emit canonical m{i}.exp export anchor files for S10-A2 zero-.p130 & x86-module compilation
    reach_ids: set[int] = set(main_ids)
    rq = deque(main_ids)
    while rq:
        u = rq.popleft()
        for v in adj[u]:
            if v not in reach_ids:
                reach_ids.add(v)
                rq.append(v)
    reach_names = {decls[u]["name"] for u in reach_ids}
    mod_texts_all = [Path(r["src_path"]).read_text(encoding="utf-8") for r in mod_records]
    for mi, rec in enumerate(mod_records):
        mod_name = rec["name"]
        exp_path = out_dir / f"{mod_name}.exp"
        if mi == K - 1:
            exp_path.write_text("", encoding="utf-8")
            rec["export_count"] = 0
        else:
            defs_in_mod = re.findall(r"^def\s+([A-Za-z0-9_.\$]+)\s*[\(:]", mod_texts_all[mi], re.M)
            later_idents = set(IDENT_RE.findall(strip_strings_and_comments("\n".join(mod_texts_all[mi + 1 :]))))
            exps = [d for d in defs_in_mod if d in later_idents and d in reach_names]
            rec["export_count"] = len(exps)
            el = ["\n@unsafe\ndef main() -> U32:"]
            for d in exps:
                if d in TMPL_CUSTOM:
                    el.append(f"  _ = {TMPL_CUSTOM[d]}")
                elif d in TMPL_1ARG:
                    el.append(f"  _ = {d}(U32)")
                else:
                    el.append(f"  _ = {d}")
            el.append("  0\n")
            exp_path.write_text("\n".join(el), encoding="utf-8")

    emitted_types = 0
    emitted_defs = 0
    emitted_laws = 0
    for line in types_path.read_text(encoding="utf-8").splitlines():
        if DECL_TYPE_RE.match(line):
            emitted_types += 1
        elif DECL_DEF_RE.match(line):
            raise AssertionError(f"Unexpected def/law in types.bend: {line}")
    for rec in mod_records:
        for line in Path(rec["src_path"]).read_text(encoding="utf-8").splitlines():
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

    sizes_b = [r["bytes"] for r in mod_records]
    avg_b = sum(sizes_b) / K
    min_b = min(sizes_b)
    max_b = max(sizes_b)
    max_over_avg = round(max_b / avg_b, 4)

    elapsed_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    manifest_json = {
        "source": str(args.src),
        "source_bytes": args.src.stat().st_size,
        "source_kb": round(args.src.stat().st_size / 1024.0, 1),
        "k": K,
        "balance": {
            "avg_kb": round(avg_b / 1024.0, 1),
            "min_kb": round(min_b / 1024.0, 1),
            "max_kb": round(max_b / 1024.0, 1),
            "max_over_avg": max_over_avg,
            "largest_scc_kb": round(max_scc_b / 1024.0, 1),
            "largest_scc_decls": len(sccs[max_scc_idx]),
        },
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
        "modules": mod_records,
        "split_ms": elapsed_ms,
    }
    (out_dir / "manifest.json").write_text(json.dumps(manifest_json, indent=2) + "\n", encoding="utf-8")

    print(f"=== K={K} Balanced Acyclic Split Complete ({elapsed_ms} ms) -> {out_dir} ===")
    print(
        f"Totals: types={emitted_types} defs={emitted_defs} laws={emitted_laws} "
        f"(0 lost, 0 dup, 0 cycles)"
    )
    print(
        f"Balance: avg={avg_b/1024:.1f} KB | min={min_b/1024:.1f} KB | max={max_b/1024:.1f} KB | "
        f"max/avg={max_over_avg:.3f}x | largest_scc={max_scc_b/1024:.1f} KB ({len(sccs[max_scc_idx])} decls)"
    )
    for r in mod_records:
        print(
            f"  {r['name']:<4} {r['kb']:6.1f} KB | defs={r['def_count']:4d} laws={r['law_count']:3d} "
            f"sccs={r['scc_count']:4d} | ximp={r['cross_mod_import_symbols']:4d} | fid={r['fid_base']}..{r['fid_limit']}"
        )


if __name__ == "__main__":
    main()
