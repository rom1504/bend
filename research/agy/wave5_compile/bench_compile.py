#!/usr/bin/env python3
"""Fast diverse compile-speed benchmark & V8 CPU profiler for Bend selfhost compiler.

Times compilation of 6 diverse Bend programs:
  - histogram (upstream medium)
  - gameoflife (upstream medium)
  - nbody (upstream medium)
  - editdist (tuned)
  - lexer (native-broad)
  - raytrace (native-broad)

Reports per-program plan_ms, emit_ms, total_ms, .o size & SHA-256, and optionally
runs Node --cpu-prof to dump the top 20 JS/Bend functions by self and total time.
"""

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import time

REPO = Path("/home/ai/bend2_agy")
LOCKED_NODE = REPO / "research/agy/locked_node.sh"
BATCH_EMIT_TIMED = REPO / "research/agy/wave5_compile/batch_emit_timed.mjs"
INPUTS_UP = REPO / "research/agy/wave4_bench/inputs/upstream"
INPUTS_TUNED = REPO / "research/agy/wave4_bench/inputs/tuned"
BROAD_DIR = REPO / "selfhost/tests/consolidation/native-broad"

ALL_PROGS = ("histogram", "gameoflife", "nbody", "editdist", "lexer", "raytrace")


def sha256_file(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def replace_once(text: str, pattern: str, repl: str) -> str:
    out, n = re.subn(pattern, repl, text, flags=re.M)
    if n != 1:
        raise ValueError(f"expected 1 match for {pattern!r}, found {n}")
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


def prepare_sources(selected, work_dir: Path):
    up_spec = json.loads((INPUTS_UP / "suite.json").read_text())
    jobs = []
    for prog in selected:
        out_o = work_dir / f"{prog}.o"
        if prog in ("histogram", "gameoflife", "nbody"):
            src_path = work_dir / f"{prog}.bend"
            src_path.write_text(prepare_upstream_bend(prog, up_spec, "medium"))
        elif prog == "editdist":
            src_path = work_dir / f"{prog}.bend"
            src_path.write_text(prepare_tuned_bend("editdist"))
        elif prog in ("lexer", "raytrace"):
            src_path = BROAD_DIR / f"{prog}.bend"
        else:
            raise ValueError(f"Unknown program: {prog}")
        jobs.append({"id": prog, "src": str(src_path), "out": str(out_o)})
    return jobs


def analyze_cpuprofile(prof_path: Path, top_n: int = 25):
    data = json.loads(prof_path.read_text())
    nodes = {n["id"]: n for n in data["nodes"]}
    samples = data.get("samples", [])
    time_deltas = data.get("timeDeltas", [])

    # Build parent map
    parent = {}
    for n in data["nodes"]:
        for ch in n.get("children", []):
            parent[ch] = n["id"]

    # Aggregate self_us by node id first (O(samples)), then walk tree once per unique hit node (1000x faster!)
    node_self_us = {}
    grand_us = 0
    for sid, dt in zip(samples, time_deltas):
        if dt <= 0:
            continue
        grand_us += dt
        node_self_us[sid] = node_self_us.get(sid, 0) + dt

    def node_key(nid):
        cf = nodes[nid]["callFrame"]
        return f"{cf['functionName'] or '(anon)'} @ {Path(cf['url']).name}:{cf['lineNumber']+1}"

    key_cache = {}
    def get_key(nid):
        k = key_cache.get(nid)
        if k is None:
            k = node_key(nid)
            key_cache[nid] = k
        return k

    self_us = {}
    total_us = {}
    for sid, us in node_self_us.items():
        if sid not in nodes:
            continue
        k0 = get_key(sid)
        self_us[k0] = self_us.get(k0, 0) + us
        seen = set()
        cur = sid
        while cur is not None and cur in nodes:
            k = get_key(cur)
            if k not in seen:
                total_us[k] = total_us.get(k, 0) + us
                seen.add(k)
            cur = parent.get(cur)

    grand_ms = grand_us / 1000.0
    print(f"\n=== V8 CPU Profile ({prof_path.name}, total sampled: {grand_ms:.1f} ms) ===")
    print(f"\nTop {top_n} by SELF time:")
    print(f"{'Self ms':>9} {'Self %':>7} {'Total ms':>9} {'Tot %':>7}  Function")
    print("-" * 80)
    for k, us in sorted(self_us.items(), key=lambda kv: kv[1], reverse=True)[:top_n]:
        tot = total_us.get(k, us)
        print(f"{us/1000:9.1f} {100*us/max(grand_us,1):6.2f}% {tot/1000:9.1f} {100*tot/max(grand_us,1):6.2f}%  {k}")

    print(f"\nTop {top_n} by TOTAL (inclusive) time:")
    print(f"{'Total ms':>9} {'Tot %':>7} {'Self ms':>9} {'Self %':>7}  Function")
    print("-" * 80)
    for k, us in sorted(total_us.items(), key=lambda kv: kv[1], reverse=True)[:top_n]:
        slf = self_us.get(k, 0)
        print(f"{us/1000:9.1f} {100*us/max(grand_us,1):6.2f}% {slf/1000:9.1f} {100*slf/max(grand_us,1):6.2f}%  {k}")

    return {
        "grand_ms": round(grand_ms, 2),
        "top_self": [
            {"fn": k, "self_ms": round(us / 1000, 2), "self_pct": round(100 * us / max(grand_us, 1), 2),
             "total_ms": round(total_us.get(k, us) / 1000, 2)}
            for k, us in sorted(self_us.items(), key=lambda kv: kv[1], reverse=True)[:top_n]
        ],
        "top_total": [
            {"fn": k, "total_ms": round(us / 1000, 2), "total_pct": round(100 * us / max(grand_us, 1), 2),
             "self_ms": round(self_us.get(k, 0) / 1000, 2)}
            for k, us in sorted(total_us.items(), key=lambda kv: kv[1], reverse=True)[:top_n]
        ],
    }


def main():
    ap = argparse.ArgumentParser(description="Wave 5 compile-speed benchmark & V8 CPU profiler")
    ap.add_argument("--api", required=True, type=Path, help="Path to compiler api.mjs")
    ap.add_argument("--only", default="", help="Comma-separated subset of programs")
    ap.add_argument("--cpu-prof", action="store_true", help="Enable Node --cpu-prof and print top functions")
    ap.add_argument("--prof-dir", type=Path, default=None, help="Directory to save .cpuprofile")
    ap.add_argument("--json", type=Path, default=None, help="Write JSON report")
    ap.add_argument("--compare", type=Path, default=None, help="Compare against baseline JSON report")
    args = ap.parse_args()

    api_path = args.api.resolve()
    if not api_path.is_file():
        sys.exit(f"ERROR: api.mjs not found: {api_path}")

    selected = [s.strip() for s in args.only.split(",") if s.strip()] if args.only else list(ALL_PROGS)

    with tempfile.TemporaryDirectory(prefix="w5_compile_") as td:
        work_dir = Path(td)
        jobs = prepare_sources(selected, work_dir)
        manifest_path = work_dir / "manifest.json"
        manifest_path.write_text(json.dumps(jobs, indent=2))

        cmd = [str(LOCKED_NODE), "--stack-size=65536"]
        prof_dir = None
        if args.cpu_prof:
            prof_dir = args.prof_dir.resolve() if args.prof_dir else (work_dir / "prof")
            prof_dir.mkdir(parents=True, exist_ok=True)
            cmd.extend(["--cpu-prof", f"--cpu-prof-dir={prof_dir}", "--cpu-prof-interval=2000"])
        cmd.extend([str(BATCH_EMIT_TIMED), str(api_path), str(manifest_path)])

        t0 = time.monotonic()
        res = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
        wall_ms = (time.monotonic() - t0) * 1000.0
        if res.returncode != 0:
            sys.stderr.write(res.stderr or res.stdout)
            sys.exit(f"ERROR: batch_emit_timed.mjs failed (rc={res.returncode})")

        payload = json.loads(res.stdout)
        rows = []
        tot_plan = 0.0
        tot_emit = 0.0
        tot_all = 0.0
        all_ok = True
        for r in payload["results"]:
            out_o = work_dir / f"{r['id']}.o"
            sha = sha256_file(out_o) if (r.get("ok") and out_o.is_file()) else None
            row = dict(r)
            row["sha256"] = sha
            rows.append(row)
            if r.get("ok"):
                tot_plan += r["plan_ms"]
                tot_emit += r["emit_ms"]
                tot_all += r["total_ms"]
            else:
                all_ok = False

        base_by_id = {}
        if args.compare and args.compare.is_file():
            base_data = json.loads(args.compare.read_text())
            base_by_id = {r["id"]: r for r in base_data.get("rows", [])}

        print(f"API: {api_path}")
        print(f"import={payload['import_ms']:.1f}ms  prep={payload['prep_ms']:.1f}ms  jobs={payload['jobs_ms']:.1f}ms  wall={wall_ms:.1f}ms\n")
        if base_by_id:
            print(f"{'Program':<12} {'Plan ms':>9} {'Emit ms':>9} {'BaseEm':>9} {'Speedup':>8} {'Bytes':>8} {'SHA-match':>10}  Status")
            print("-" * 82)
        else:
            print(f"{'Program':<12} {'Plan ms':>9} {'Emit ms':>9} {'Total ms':>9} {'Bytes':>8} {'SHA256[:12]':>13}  Status")
            print("-" * 74)

        for r in rows:
            st = "OK" if r["ok"] else f"FAIL({r.get('stage')}): {r.get('error', '')[:40]}"
            if base_by_id:
                b = base_by_id.get(r["id"])
                bem = b["emit_ms"] if b else 0.0
                spd = f"{bem / r['emit_ms']:.2f}x" if (b and r["emit_ms"] > 0) else "-"
                sm = "EXACT" if (b and b.get("sha256") == r.get("sha256")) else "DIFF"
                print(f"{r['id']:<12} {r['plan_ms']:9.1f} {r['emit_ms']:9.1f} {bem:9.1f} {spd:>8} {r.get('bytes', 0):8d} {sm:>10}  {st}")
            else:
                sha12 = (r["sha256"] or "-")[:12]
                print(f"{r['id']:<12} {r['plan_ms']:9.1f} {r['emit_ms']:9.1f} {r['total_ms']:9.1f} {r.get('bytes', 0):8d} {sha12:>13}  {st}")

        if base_by_id:
            base_tot_emit = sum(b["emit_ms"] for b in base_by_id.values() if b.get("ok"))
            spd_tot = f"{base_tot_emit / tot_emit:.2f}x" if tot_emit > 0 else "-"
            exact_cnt = sum(1 for r in rows if base_by_id.get(r["id"], {}).get("sha256") == r.get("sha256"))
            print("-" * 82)
            print(f"{'TOTAL':<12} {tot_plan:9.1f} {tot_emit:9.1f} {base_tot_emit:9.1f} {spd_tot:>8} {'':>8} {f'{exact_cnt}/{len(rows)}':>10}")
        else:
            print("-" * 74)
            print(f"{'TOTAL':<12} {tot_plan:9.1f} {tot_emit:9.1f} {tot_all:9.1f}")

        prof_summary = None
        if args.cpu_prof and prof_dir:
            profs = sorted(prof_dir.glob("*.cpuprofile"))
            if profs:
                prof_summary = analyze_cpuprofile(profs[-1], top_n=25)

        report = {
            "api": str(api_path),
            "import_ms": round(payload["import_ms"], 2),
            "prep_ms": round(payload["prep_ms"], 2),
            "jobs_ms": round(payload["jobs_ms"], 2),
            "wall_ms": round(wall_ms, 2),
            "total_plan_ms": round(tot_plan, 2),
            "total_emit_ms": round(tot_emit, 2),
            "all_ok": all_ok,
            "rows": rows,
            "profile": prof_summary,
        }
        if args.json:
            args.json.parent.mkdir(parents=True, exist_ok=True)
            args.json.write_text(json.dumps(report, indent=2) + "\n")

        sys.exit(0 if all_ok else 1)


if __name__ == "__main__":
    main()
