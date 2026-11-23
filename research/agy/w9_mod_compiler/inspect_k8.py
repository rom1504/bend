#!/usr/bin/env python3
"""Extract real K=8 modules from wave8_unified/compiler.bend and analyze their
deps, signatures, and live-root construction."""
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


def extract_types_and_decls(path: Path):
    lines = path.read_text().splitlines(keepends=True)
    n = len(lines)
    decls = []
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
        i += 1
    return import_lines, type_blocks, decls


def partition_k8(decls, type_header_bytes):
    n = len(decls)
    name_to_id = {d["name"]: idx for idx, d in enumerate(decls)}
    adj = [[] for _ in range(n)]
    for u, d in enumerate(decls):
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
    scc_defs = [0] * num_sccs
    for si, comp in enumerate(sccs):
        scc_defs[si] = len(comp)
        b = 0
        for u in comp:
            node_to_scc[u] = si
            b += decls[u]["bytes"]
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

    # Same greedy K=8 partition as analyze_sccs.py
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

    # Collect node ids per module (preserving original decl order)
    mod_nodes = []
    for comps in modules:
        nodes = sorted(u for s in comps for u in sccs[s])
        mod_nodes.append(nodes)

    return adj, mod_nodes


def main():
    import_lines, type_blocks, decls = extract_types_and_decls(COMPILER_BEND)
    type_header = "".join(import_lines) + "\n" + "".join(type_blocks)
    adj, mod_nodes = partition_k8(decls, len(type_header))
    print(f"wave8_unified/compiler.bend: {COMPILER_BEND.stat().st_size} bytes, "
          f"{len(type_blocks)} types ({len(type_header)} B header), {len(decls)} decls")
    for mi, nodes in enumerate(mod_nodes):
        node_set = set(nodes)
        ext_deps = sorted({v for u in nodes for v in adj[u] if v not in node_set})
        # Find roots within this module (nodes not called by any other node in this module)
        internal_called = {v for u in nodes for v in adj[u] if v in node_set}
        roots = [u for u in nodes if u not in internal_called]
        body_bytes = sum(decls[u]["bytes"] for u in nodes)
        defs = sum(1 for u in nodes if decls[u]["kind"] == "def")
        laws = sum(1 for u in nodes if decls[u]["kind"] == "law")
        print(f"  mod {mi}: {len(nodes):4d} decls ({defs} defs, {laws} laws), "
              f"body={body_bytes/1024:.1f} KB, ext_deps={len(ext_deps):4d}, "
              f"internal_roots={len(roots):4d}")


if __name__ == "__main__":
    main()
