#!/usr/bin/env python3
"""Wave 5B Track W5B-C3: Parallel Sharded Codegen Benchmark & Correctness Gate.

Tests `research/agy/wave5b_c3/par_compile.mjs` on:
  1. All 6 diverse programs from `bench_compile.py`:
     histogram (267 KB), gameoflife, nbody, editdist, lexer, raytrace
     - Compares 1-shard vs 4-shard (pinned to CPUs 0,1,4,5)
     - Links BOTH binaries with runtime-agy.o and verifies 100% exact stdout!
     - Also compares LPT vs round-robin sharding on histogram & gameoflife.
  2. A 200-def slice of `selfhost/build/agy/wave5a_unified/compiler.bend`:
     - Compares 1-shard vs 4-shard wall-clock emit & total speedup
     - Links & executes BOTH binaries and verifies 100% exact stdout!
"""
import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
PAR_COMPILE = ROOT / "research/agy/wave5b_c3/par_compile.mjs"
W5B_API = ROOT / "selfhost/build/agy/wave5b_c3/api.mjs"
RT_OBJ = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
INPUTS_UP = ROOT / "research/agy/wave4_bench/inputs/upstream"
INPUTS_TUNED = ROOT / "research/agy/wave4_bench/inputs/tuned"
BROAD_DIR = ROOT / "selfhost/tests/consolidation/native-broad"
COMPILER_SRC = ROOT / "selfhost/build/agy/wave5a_unified/compiler.bend"

ALL_PROGS = ("histogram", "gameoflife", "nbody", "editdist", "lexer", "raytrace")
RTS_ARGS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]


def replace_once(text: str, pattern: str, repl: str) -> str:
    out, n = re.subn(pattern, repl, text, flags=re.M)
    assert n == 1, f"expected 1 match for {pattern!r}, got {n}"
    return out


def prepare_upstream_bend(family: str, up_spec: dict, size: str = "medium") -> str:
    desc = up_spec[family]
    bend_text = (INPUTS_UP / family / "main.bend").read_text()
    for bname, old, new in zip(desc["bendKnobs"], desc["upstream"], desc[size]):
        bend_text = replace_once(
            bend_text,
            rf"(^def {bname}\(\) -> Nat:\n  ){old}n$",
            rf"\g<1>{new}n",
        )
    return bend_text


def prepare_tuned_bend(family: str) -> str:
    kernel = (INPUTS_TUNED / "kernels" / f"{family}.bend").read_text()
    driver = (INPUTS_TUNED / "driver.bend").read_text()
    return kernel.rstrip() + "\n\n" + driver


def build_200def_slice(out_path: Path) -> int:
    """Extract a transitively closed ~200-def slice of compiler.bend (x187_elf + x187_encode + index_set + strhash targets)."""
    lines = COMPILER_SRC.read_text().splitlines()
    blocks = []
    cur = []
    for l in lines:
        if (l.startswith("type ") or l.startswith("def ") or l.startswith("law ") or l.startswith("@unsafe") or l.startswith("import ")) and cur and not cur[-1].startswith("@"):
            blocks.append(cur)
            cur = [l]
        else:
            cur.append(l)
    if cur:
        blocks.append(cur)

    imports = [b for b in blocks if any(x.startswith("import ") for x in b)]
    types = [b for b in blocks if any(x.startswith("type ") for x in b)]
    defs = [b for b in blocks if any(x.startswith("def ") for x in b)]
    laws = [b for b in blocks if any(x.startswith("law ") for x in b)]

    def_map = {}
    def_order = []
    for b in defs:
        for x in b:
            if x.startswith("def "):
                nm = x.split("(")[0].split()[1].rstrip(":")
                def_map[nm] = b
                def_order.append(nm)
                break

    ident_re = re.compile(r"\b[A-Za-z_][A-Za-z0-9_]*\b")
    roots = ["x187_elf", "x187_encode", "index_set", "index_find",
             "p98_tag_eq", "p98_tag_eq_read", "p88_string_eq", "p88_string_eq_go", "agy_str_eq"]
    seen = set(r for r in roots if r in def_map)
    q = list(seen)
    while q:
        u = q.pop()
        text_u = "\n".join(x.split("#", 1)[0] for x in def_map[u])
        for tok in set(ident_re.findall(text_u)):
            if tok in def_map and tok not in seen:
                seen.add(tok)
                q.append(tok)

    kept_defs = [def_map[nm] for nm in def_order if nm in seen]
    kept_laws = []
    for b in laws:
        for x in b:
            if x.startswith("law "):
                nm = x.split()[1].rstrip(":")
                if nm in seen:
                    kept_laws.append(b)
                break

    # Keep only transitively referenced types (keeps memory & plan time lean)
    type_map = {}
    type_order = []
    for b in types:
        for x in b:
            if x.startswith("type "):
                nm = x.split()[1].rstrip(":")
                type_map[nm] = b
                type_order.append(nm)
                break
    t_seen = set()
    tq = []
    for grp in (kept_laws, kept_defs):
        for b in grp:
            for tok in set(ident_re.findall("\n".join(b))):
                if tok in type_map and tok not in t_seen:
                    t_seen.add(tok)
                    tq.append(tok)
    while tq:
        u = tq.pop()
        for tok in set(ident_re.findall("\n".join(type_map[u]))):
            if tok in type_map and tok not in t_seen:
                t_seen.add(tok)
                tq.append(tok)
    kept_types = [type_map[nm] for nm in type_order if nm in t_seen]

    parts = []
    for grp in (imports, kept_types, kept_laws, kept_defs):
        for b in grp:
            parts.append("\n".join(b))
    prefix = "\n\n".join(parts)
    driver = """

@unsafe
def slice_el_ok(el: X187ObjectResult) -> U32:
  match el:
    case X187ObjectResult{bs,err}: Bool.to_u32(String.is_empty(err))

@unsafe
def slice_enc_ok(enc: X187Encoded) -> U32:
  match enc:
    case X187Encoded{bs,rs,err}: Bool.to_u32(String.is_empty(err))

@unsafe
def main() -> IO(Unit):
  +h1 = index_hash("p118borrow.read.agy_str_eq", 2166136261)
  +h2 = index_hash("x187_prepared_shard", h1)
  +eq1 = Bool.to_u32(agy_str_eq("KTerm", "KTerm"))
  +eq2 = Bool.to_u32(p88_string_eq("hello", "world"))
  +eq3 = Bool.to_u32(p88_string_eq_go("abc", "abc", True{}))
  +t1 : KTerm = KTerm{"Var", "x", 0, 0, [], [], 0, 0}
  +t2 : KTerm = KLambda{"y", 1, 1, [t1], [], 0, 0, True{}}
  +tq = Bool.to_u32(p98_tag_eq(t1, "Var"))
  +tqr = Bool.to_u32(p98_tag_eq_read(t2, "Lam"))
  +idx = index_set(missing(), KDef{"x", "Def", 1, 0, t1, t2, [], False{}, False{}}, index_hash("x", 2166136261), 32)
  +found = index_find(idx, "x", index_hash("x", 2166136261), 32)
  +ok = Bool.to_u32(agy_str_eq(dk(found), "Def"))
  +el_ok = slice_el_ok(x187_elf(X187Object{[195],[],[],[],[]}))
  +enc_ok = slice_enc_ok(x187_encode(X187Instruction{"ret",[]},0))
  IO.print(U32.show(U32.xor(h2, U32.add(eq1, U32.add(U32.mul(eq2, 2), U32.add(U32.mul(eq3, 4),
    U32.add(U32.mul(ok, 8), U32.add(U32.mul(tq, 16), U32.add(U32.mul(tqr, 32), U32.add(U32.mul(el_ok, 64), U32.mul(enc_ok, 128)))))))))))
"""
    out_path.write_text(prefix + driver)
    return len(kept_defs)


def run_par_compile(api: Path, shards: int, manifest_path: Path, strategy: str = "lpt") -> dict:
    cmd = [
        "bash", "-c",
        f'ulimit -s 65536 && exec taskset -c 0,1,4,5 bash "{LOCKED_NODE}" "{PAR_COMPILE}" --api "{api}" --shards "{shards}" --strategy "{strategy}" --manifest "{manifest_path}"',
    ]
    r = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
    if r.returncode != 0:
        raise RuntimeError(f"par_compile (shards={shards}, rc={r.returncode}) failed:\n{r.stderr}\n{r.stdout[:500]}")
    return json.loads(r.stdout)


def run_exe(exe: Path) -> str:
    r = subprocess.run(["taskset", "-c", "0", str(exe), *RTS_ARGS], capture_output=True, text=True, timeout=60)
    if r.returncode != 0:
        raise RuntimeError(f"exe {exe.name} failed rc={r.returncode}: {r.stderr[:200]}")
    return r.stdout


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--api", type=Path, default=W5B_API)
    ap.add_argument("--json", type=Path, default=None)
    args = ap.parse_args()

    with tempfile.TemporaryDirectory(prefix="w5b_parcg_bench_") as td_s:
        td = Path(td_s)
        up_spec = json.loads((INPUTS_UP / "suite.json").read_text())

        # Prepare all 6 diverse programs + 200-def compiler slice
        sources = {}
        for prog in ALL_PROGS:
            if prog in ("histogram", "gameoflife", "nbody"):
                sp = td / f"{prog}.bend"
                sp.write_text(prepare_upstream_bend(prog, up_spec, "medium"))
                sources[prog] = sp
            elif prog == "editdist":
                sp = td / f"{prog}.bend"
                sp.write_text(prepare_tuned_bend("editdist"))
                sources[prog] = sp
            else:
                sources[prog] = BROAD_DIR / f"{prog}.bend"

        slice_path = td / "compiler_200defs.bend"
        n_slice_defs = build_200def_slice(slice_path)
        sources["compiler_200defs"] = slice_path
        print(f"Prepared 6 diverse programs + compiler_200defs ({n_slice_defs} defs, {slice_path.stat().st_size} bytes)", flush=True)

        jobs_1 = [{"id": k, "src": str(v), "out": str(td / f"{k}_s1.bin")} for k, v in sources.items()]
        jobs_4 = [{"id": k, "src": str(v), "out": str(td / f"{k}_s4.bin")} for k, v in sources.items()]
        m1 = td / "m1.json"
        m4 = td / "m4.json"
        m1.write_text(json.dumps(jobs_1))
        m4.write_text(json.dumps(jobs_4))

        print("\nRunning 1-shard baseline (taskset -c 0,1,4,5)...", flush=True)
        res1 = run_par_compile(args.api, 1, m1)
        print("Running 4-shard LPT parallel (taskset -c 0,1,4,5)...", flush=True)
        res4 = run_par_compile(args.api, 4, m4, strategy="lpt")

        # Also compare RR vs LPT on histogram, gameoflife, compiler_200defs
        jobs_rr = [
            {"id": k, "src": str(sources[k]), "out": str(td / f"{k}_rr.bin")}
            for k in ("histogram", "gameoflife", "compiler_200defs")
        ]
        mrr = td / "mrr.json"
        mrr.write_text(json.dumps(jobs_rr))
        print("Running 4-shard RR comparison on histogram/gameoflife/compiler_200defs...", flush=True)
        res_rr = run_par_compile(args.api, 4, mrr, strategy="rr")

        by1 = {r["id"]: r for r in res1["results"]}
        by4 = {r["id"]: r for r in res4["results"]}
        by_rr = {r["id"]: r for r in res_rr["results"]}

        print("\n=== 1-Shard vs 4-Shard (LPT) Compile Speedup & Exact Runtime Verification ===")
        print(f"{'Program':<18} {'Plan+PW':>8} {'Emit1':>8} {'Emit4':>8} {'EmSpd':>7} {'Tot1':>8} {'Tot4':>8} {'TotSpd':>7} {'Workers(ms)':<28} {'Run':>6}")
        print("-" * 116)
        tot_emit1 = tot_emit4 = tot_all1 = tot_all4 = 0.0
        rows = []
        for k in (*ALL_PROGS, "compiler_200defs"):
            r1 = by1[k]
            r4 = by4[k]
            o1 = run_exe(Path(r1["out"]))
            o4 = run_exe(Path(r4["out"]))
            assert o1 == o4, f"RUNTIME MISMATCH on {k}: 1-shard={o1!r} vs 4-shard={o4!r}"
            em_spd = r1["emitWallMs"] / max(r4["emitWallMs"], 0.1)
            tot_spd = r1["totalMs"] / max(r4["totalMs"], 0.1)
            pw = r4["planMs"] + r4["pwMs"]
            w_str = ",".join(str(int(round(x))) for x in r4["workerEmitMs"])
            print(f"{k:<18} {pw:8.1f} {r1['emitWallMs']:8.1f} {r4['emitWallMs']:8.1f} {em_spd:6.2f}x {r1['totalMs']:8.1f} {r4['totalMs']:8.1f} {tot_spd:6.2f}x [{w_str:<26}]  EXACT")
            if k in ALL_PROGS:
                tot_emit1 += r1["emitWallMs"]
                tot_emit4 += r4["emitWallMs"]
                tot_all1 += r1["totalMs"]
                tot_all4 += r4["totalMs"]
            rows.append({
                "id": k,
                "plan_pw_ms": round(pw, 1),
                "emit1_ms": r1["emitWallMs"],
                "emit4_ms": r4["emitWallMs"],
                "emit_speedup": round(em_spd, 2),
                "total1_ms": r1["totalMs"],
                "total4_ms": r4["totalMs"],
                "total_speedup": round(tot_spd, 2),
                "worker_emit_ms": r4["workerEmitMs"],
                "link4_ms": r4["linkMs"],
                "obj1_bytes": r1["totalObjBytes"],
                "obj4_bytes": r4["totalObjBytes"],
                "stdout": o4.strip()[:60],
                "exact_match": True,
            })

        print("-" * 116)
        print(f"{'6-PROG TOTAL':<18} {'':>8} {tot_emit1:8.1f} {tot_emit4:8.1f} {tot_emit1/tot_emit4:6.2f}x {tot_all1:8.1f} {tot_all4:8.1f} {tot_all1/tot_all4:6.2f}x")

        print("\n=== LPT vs Round-Robin (4 shards) ===")
        for k in ("histogram", "gameoflife", "compiler_200defs"):
            rl = by4[k]
            rr = by_rr[k]
            o_rr = run_exe(Path(rr["out"]))
            assert o_rr == run_exe(Path(by1[k]["out"])), f"RR mismatch on {k}"
            print(f"  {k:<18} LPT={rl['emitWallMs']:7.1f}ms {rl['workerEmitMs']}  |  RR={rr['emitWallMs']:7.1f}ms {rr['workerEmitMs']}")

        if args.json:
            args.json.parent.mkdir(parents=True, exist_ok=True)
            args.json.write_text(json.dumps({
                "rows": rows,
                "six_prog_emit_speedup": round(tot_emit1 / tot_emit4, 2),
                "six_prog_total_speedup": round(tot_all1 / tot_all4, 2),
                "rr_compare": {k: {"lpt": by4[k]["emitWallMs"], "lpt_w": by4[k]["workerEmitMs"], "rr": by_rr[k]["emitWallMs"], "rr_w": by_rr[k]["workerEmitMs"]} for k in ("histogram", "gameoflife", "compiler_200defs")},
            }, indent=2) + "\n")


if __name__ == "__main__":
    main()
