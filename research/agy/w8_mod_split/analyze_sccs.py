#!/usr/bin/env python3
"""Exact Tarjan SCC DAG analysis and acyclic module partitioning for compiler.bend.

Reads selfhost/build/agy/wave7c_unified/compiler.bend, extracts all top-level
`type`, `def`, and `law` declarations, builds the exact reference graph over
`def`/`law`, computes Tarjan SCCs, verifies DAG acyclicity, and evaluates
balanced acyclic module partitions for K = 8, 12, 16.
"""
from __future__ import annotations

import json
import re
import sys
import time
from collections import defaultdict, deque
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
COMPILER_BEND = ROOT / "selfhost/build/agy/wave7c_unified/compiler.bend"
OUT_JSON = ROOT / "research/agy/w8_mod_split/scc_analysis.json"

IDENT_RE = re.compile(r"\b[A-Za-z_][A-Za-z0-9_.]*\b")
DECL_DEF_RE = re.compile(r"^(def|law)\s+([A-Za-z_][A-Za-z0-9_.]*)")
DECL_TYPE_RE = re.compile(r"^type\s+([A-Za-z_][A-Za-z0-9_.]*)")


def strip_strings_and_comments(text: str) -> str:
    """Fast character scanner removing string/char literals and # comments."""
    out = []
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


def parse_compiler_bend(path: Path):
    lines = path.read_text().splitlines(keepends=True)
    n = len(lines)
    decls = []  # list of dicts: kind, name, start_line, end_line, bytes, text
    type_bytes = 0
    type_count = 0
    import_bytes = 0

    # Group top-level blocks: a new block starts at col 0 when line starts with
    # `def `, `law `, `type `, `import `, or `@unsafe` (attached to next def/law).
    i = 0
    pending_start = None
    while i < n:
        line = lines[i]
        if line.startswith("import "):
            import_bytes += len(line)
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
            while j < n:
                lj = lines[j]
                if lj.strip() == "" or lj[0].isspace() or lj.startswith("#"):
                    j += 1
                else:
                    break
            block = "".join(lines[start:j])
            type_count += 1
            type_bytes += len(block)
            i = j
            continue
        m_def = DECL_DEF_RE.match(line)
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
            decls.append({
                "kind": kind,
                "name": name,
                "start_line": start + 1,
                "end_line": j,
                "bytes": len(block),
                "text": block,
            })
            i = j
            continue
        # Blank or comment line outside blocks
        i += 1

    return decls, type_count, type_bytes, import_bytes


def tarjan_scc(num_nodes: int, adj: list[list[int]]) -> list[list[int]]:
    """Iterative Tarjan's SCC algorithm (returns SCCs in reverse topological order)."""
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


def partition_topological(
    topo_sccs: list[int],
    scc_bytes: list[int],
    scc_defs: list[int],
    dag_deps: list[set[int]],
    k: int,
    type_header_bytes: int,
    ms_per_kb: float = 28.0,
) -> dict:
    """Greedy topological-order balanced partition into K acyclic modules.

    topo_sccs is ordered leaves-first (if A depends on B, B appears before A).
    Partitioning a contiguous prefix/slice of topo_sccs into K buckets guarantees
    module i only depends on modules j < i (strictly acyclic!).
    """
    total_bytes = sum(scc_bytes)
    target = total_bytes / k
    modules: list[list[int]] = []
    cur: list[int] = []
    cur_b = 0
    rem_b = total_bytes

    for idx, s in enumerate(topo_sccs):
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

    scc_to_mod = {}
    for mi, comps in enumerate(modules):
        for s in comps:
            scc_to_mod[s] = mi

    m_count = len(modules)
    mod_deps: list[set[int]] = [set() for _ in range(m_count)]
    for mi, comps in enumerate(modules):
        for s in comps:
            for dep in dag_deps[s]:
                dm = scc_to_mod[dep]
                if dm != mi:
                    assert dm < mi, f"Cycle! mod {mi} depends on {dm}"
                    mod_deps[mi].add(dm)

    # Compute module DAG levels (wave scheduling if modules need interface from deps)
    mod_level = [0] * m_count
    mod_bytes = [sum(scc_bytes[s] for s in comps) for comps in modules]
    mod_defs = [sum(scc_defs[s] for s in comps) for comps in modules]
    mod_crit_bytes = [0] * m_count
    for mi in range(m_count):
        if mod_deps[mi]:
            mod_level[mi] = 1 + max(mod_level[d] for d in mod_deps[mi])
            mod_crit_bytes[mi] = mod_bytes[mi] + max(mod_crit_bytes[d] for d in mod_deps[mi])
        else:
            mod_level[mi] = 0
            mod_crit_bytes[mi] = mod_bytes[mi]

    # Notice: with ABI-known interfaces (or .p130 headers), ALL K modules can
    # compile 100% in parallel (embarrassingly parallel across P cores)!
    # Without pre-known interfaces (strict sequential wave-by-wave), critical path
    # is max(mod_crit_bytes).
    # List-schedule K independent modules on P cores (LPT greedy):
    def lpt_time_ms(cores: int) -> float:
        loads = [0.0] * cores
        # Include type header overhead per module (~type_header_bytes)
        jobs = sorted(
            [(mb + type_header_bytes) / 1024.0 * ms_per_kb for mb in mod_bytes],
            reverse=True,
        )
        for j in jobs:
            i = min(range(cores), key=lambda c: loads[c])
            loads[i] += j
        return round(max(loads), 1)

    mod_summaries = []
    for mi in range(m_count):
        mod_summaries.append({
            "mod": mi,
            "sccs": len(modules[mi]),
            "defs": mod_defs[mi],
            "body_kb": round(mod_bytes[mi] / 1024.0, 1),
            "with_types_kb": round((mod_bytes[mi] + type_header_bytes) / 1024.0, 1),
            "deps": sorted(mod_deps[mi]),
            "wave_level": mod_level[mi],
        })

    return {
        "k_requested": k,
        "k_actual": m_count,
        "min_body_kb": round(min(mod_bytes) / 1024.0, 1),
        "max_body_kb": round(max(mod_bytes) / 1024.0, 1),
        "avg_body_kb": round((sum(mod_bytes) / m_count) / 1024.0, 1),
        "mod_dag_edges": sum(len(d) for d in mod_deps),
        "mod_dag_depth_waves": max(mod_level) + 1,
        "mod_crit_path_kb": round(max(mod_crit_bytes) / 1024.0, 1),
        "pred_parallel_cold_ms_4c": lpt_time_ms(4),
        "pred_parallel_cold_ms_8c": lpt_time_ms(8),
        "pred_parallel_cold_ms_16c": lpt_time_ms(16),
        "modules": mod_summaries,
    }


def main() -> None:
    t0 = time.perf_counter()
    decls, type_count, type_bytes, import_bytes = parse_compiler_bend(COMPILER_BEND)
    n = len(decls)
    name_to_id = {}
    for idx, d in enumerate(decls):
        name_to_id[d["name"]] = idx

    # Build reference graph: u -> v means u references v
    adj: list[list[int]] = [[] for _ in range(n)]
    self_rec = 0
    total_edges = 0
    for u, d in enumerate(decls):
        clean = strip_strings_and_comments(d["text"])
        # Skip header line's own name occurrence (first match)
        seen = set()
        for tok in IDENT_RE.findall(clean):
            v = name_to_id.get(tok)
            if v is not None:
                if v == u:
                    # Only count self-rec if appears > 1 time (header + body)
                    pass
                elif v not in seen:
                    seen.add(v)
        # Check self-recursion properly (appears in body after first newline)
        nl = clean.find("\n")
        if nl != -1 and d["name"] in set(IDENT_RE.findall(clean[nl + 1:])):
            self_rec += 1
        adj[u] = sorted(seen)
        total_edges += len(seen)

    sccs = tarjan_scc(n, adj)
    num_sccs = len(sccs)
    node_to_scc = [0] * n
    scc_bytes = [0] * num_sccs
    scc_defs = [0] * num_sccs
    for si, comp in enumerate(sccs):
        scc_defs[si] = len(comp)
        b = 0
        for u in comp:
            node_to_scc[u] = si
            b += decls[u]["bytes"]
        scc_bytes[si] = b

    # Build condensed SCC DAG: dag_deps[si] = set of SCCs that si depends on
    dag_deps: list[set[int]] = [set() for _ in range(num_sccs)]
    dag_rdeps: list[set[int]] = [set() for _ in range(num_sccs)]
    for u in range(n):
        su = node_to_scc[u]
        for v in adj[u]:
            sv = node_to_scc[v]
            if su != sv:
                dag_deps[su].add(sv)
                dag_rdeps[sv].add(su)

    # Kahn's topological sort (leaves first: SCCs with 0 deps first)
    indeg = [len(dag_deps[si]) for si in range(num_sccs)]
    q = deque(si for si in range(num_sccs) if indeg[si] == 0)
    topo: list[int] = []
    while q:
        u = q.popleft()
        topo.append(u)
        for nxt in dag_rdeps[u]:
            indeg[nxt] -= 1
            if indeg[nxt] == 0:
                q.append(nxt)
    assert len(topo) == num_sccs, f"SCC DAG cycle! {len(topo)} != {num_sccs}"

    # Critical path (depth in SCCs and weighted by bytes)
    depth_scc = [0] * num_sccs
    depth_bytes = [0] * num_sccs
    for s in topo:
        if dag_deps[s]:
            depth_scc[s] = 1 + max(depth_scc[d] for d in dag_deps[s])
            depth_bytes[s] = scc_bytes[s] + max(depth_bytes[d] for d in dag_deps[s])
        else:
            depth_scc[s] = 1
            depth_bytes[s] = scc_bytes[s]

    # SCC size histogram
    singleton_sccs = sum(1 for c in sccs if len(c) == 1)
    nontrivial_sccs = [si for si in range(num_sccs) if len(sccs[si]) > 1]
    top_sccs = sorted(range(num_sccs), key=lambda si: (-len(sccs[si]), -scc_bytes[si]))[:15]
    top_scc_info = [
        {
            "scc_id": si,
            "defs": len(sccs[si]),
            "kb": round(scc_bytes[si] / 1024.0, 2),
            "sample_defs": [decls[u]["name"] for u in sccs[si][:6]],
        }
        for si in top_sccs
    ]

    largest_by_defs = max(range(num_sccs), key=lambda si: len(sccs[si]))
    largest_by_bytes = max(range(num_sccs), key=lambda si: scc_bytes[si])

    partitions = {}
    for k in (8, 12, 16):
        partitions[f"k{k}"] = partition_topological(
            topo, scc_bytes, scc_defs, dag_deps, k, type_bytes + import_bytes
        )

    elapsed_ms = round((time.perf_counter() - t0) * 1000, 1)
    result = {
        "source": str(COMPILER_BEND),
        "file_bytes": COMPILER_BEND.stat().st_size,
        "file_kb": round(COMPILER_BEND.stat().st_size / 1024.0, 1),
        "type_count": type_count,
        "type_header_bytes": type_bytes + import_bytes,
        "type_header_kb": round((type_bytes + import_bytes) / 1024.0, 1),
        "def_law_count": n,
        "def_count": sum(1 for d in decls if d["kind"] == "def"),
        "law_count": sum(1 for d in decls if d["kind"] == "law"),
        "self_recursive_defs": self_rec,
        "call_graph_edges": total_edges,
        "scc_count": num_sccs,
        "singleton_sccs": singleton_sccs,
        "nontrivial_sccs": len(nontrivial_sccs),
        "nontrivial_defs_total": sum(len(sccs[si]) for si in nontrivial_sccs),
        "scc_dag_edges": sum(len(d) for d in dag_deps),
        "scc_dag_acyclic": True,
        "scc_dag_max_depth_nodes": max(depth_scc),
        "scc_dag_crit_path_kb": round(max(depth_bytes) / 1024.0, 1),
        "largest_scc_by_defs": {
            "defs": len(sccs[largest_by_defs]),
            "kb": round(scc_bytes[largest_by_defs] / 1024.0, 2),
            "sample_defs": [decls[u]["name"] for u in sccs[largest_by_defs][:10]],
        },
        "largest_scc_by_bytes": {
            "defs": len(sccs[largest_by_bytes]),
            "kb": round(scc_bytes[largest_by_bytes] / 1024.0, 2),
            "sample_defs": [decls[u]["name"] for u in sccs[largest_by_bytes][:10]],
        },
        "top_15_sccs": top_scc_info,
        "partitions": partitions,
        "analysis_ms": elapsed_ms,
    }

    OUT_JSON.parent.mkdir(parents=True, exist_ok=True)
    OUT_JSON.write_text(json.dumps(result, indent=2) + "\n")

    print(f"=== Tarjan SCC DAG Analysis of compiler.bend ({result['file_kb']} KB) ===")
    print(f"Types: {type_count} ({result['type_header_kb']} KB header) | Defs: {result['def_count']} | Laws: {result['law_count']} | Total: {n}")
    print(f"Call edges: {total_edges} | Self-recursive defs: {self_rec}")
    print(f"SCCs: {num_sccs} ({singleton_sccs} singletons, {len(nontrivial_sccs)} mutual-rec SCCs covering {result['nontrivial_defs_total']} defs)")
    print(f"Largest SCC (defs): {result['largest_scc_by_defs']['defs']} defs, {result['largest_scc_by_defs']['kb']} KB -> {result['largest_scc_by_defs']['sample_defs'][:5]}")
    print(f"Largest SCC (KB):   {result['largest_scc_by_bytes']['defs']} defs, {result['largest_scc_by_bytes']['kb']} KB -> {result['largest_scc_by_bytes']['sample_defs'][:5]}")
    print(f"SCC DAG: {result['scc_dag_edges']} edges, acyclic=True, max depth={result['scc_dag_max_depth_nodes']} SCCs, crit-path={result['scc_dag_crit_path_kb']} KB")
    print("\nTop 10 Mutual-Recursion SCCs:")
    for t in top_scc_info[:10]:
        print(f"  {t['defs']:4d} defs | {t['kb']:6.1f} KB | {', '.join(t['sample_defs'][:4])}")
    print("\nGreedy Topological Acyclic Module Partitions:")
    for k_key, p in partitions.items():
        print(f"  K={p['k_actual']:2d}: body {p['min_body_kb']}-{p['max_body_kb']} KB (avg {p['avg_body_kb']} KB), "
              f"mod-DAG edges={p['mod_dag_edges']}, waves={p['mod_dag_depth_waves']}, "
              f"pred 4c={p['pred_parallel_cold_ms_4c']/1000:.2f}s 8c={p['pred_parallel_cold_ms_8c']/1000:.2f}s 16c={p['pred_parallel_cold_ms_16c']/1000:.2f}s")
    print(f"\nAnalysis completed in {elapsed_ms} ms -> {OUT_JSON}")


if __name__ == "__main__":
    main()
