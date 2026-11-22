#!/usr/bin/env python3
"""Phase 4 Evaluation:
  1. Untouched Holdout Transfer Test (bfs, merkle, kmeans): Wave 2 vs Wave 4C vs Handwritten C (CPU 2).
  2. Untouched Upstream Defaults (histogram, gameoflife, nbody): Wave 4C vs published Wave 2 & Clang-16 (CPU 2).
  3. native45 10-case zero-regression check: Wave 4C vs Wave 2 (CPU 2).
"""
import json, math, statistics, subprocess, tempfile, time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
W2_API = ROOT / "selfhost/build/agy/wave2_unified/api.mjs"
W4C_API = ROOT / "selfhost/build/agy/wave4c_unified/api.mjs"
RT = ROOT / "selfhost/build/agy/unified/runtime-agy.o"
LOCKED_NODE = str(ROOT / "research/agy/locked_node.sh")
BATCH_EMIT = str(ROOT / "research/agy/wave3_fuzz/batch_emit.mjs")
CC = "/usr/bin/x86_64-linux-gnu-gcc-10"
HOLDOUTS = ROOT / "research/agy/wave4_bench/holdouts"
UPSTREAM = ROOT / "research/agy/wave4_bench/inputs/upstream"
FULL44 = ROOT / "selfhost/build/agy/wave2_unified/full44"


def emit_batch(api: Path, jobs: list, td: Path, tag: str) -> dict:
    mf = td / f"mf_{tag}.json"
    mf.write_text(json.dumps(jobs))
    r = subprocess.run([LOCKED_NODE, "--stack-size=65536", BATCH_EMIT, str(api), str(mf)],
                       capture_output=True, text=True, check=True)
    return {row["id"]: row for row in json.loads(r.stdout)}


def run_timed(cmd: list, timeout: int = 180) -> tuple:
    t0 = time.monotonic()
    r = subprocess.run(["taskset", "-c", "2"] + cmd, capture_output=True, text=True, timeout=timeout)
    dt = time.monotonic() - t0
    return r.returncode, r.stdout.strip(), r.stderr.strip(), dt


def main():
    out = {"holdouts": {}, "upstream_defaults": {}, "native45": {}}
    with tempfile.TemporaryDirectory(prefix="w4_phase4_") as td_s:
        td = Path(td_s)

        # ------------------------------------------------------------------
        # 1. UNTOUCHED HOLDOUT TRANSFER TEST (bfs, merkle, kmeans)
        # ------------------------------------------------------------------
        print("=== 1. UNTOUCHED HOLDOUT TRANSFER TEST (bfs, merkle, kmeans) ===", flush=True)
        h_names = ["bfs", "merkle", "kmeans"]
        h_jobs_w2 = [{"id": w, "src": str(HOLDOUTS / w / "main.bend"), "out": str(td / f"h_{w}_w2.o")} for w in h_names]
        h_jobs_w4 = [{"id": w, "src": str(HOLDOUTS / w / "main.bend"), "out": str(td / f"h_{w}_w4.o")} for w in h_names]
        em_w2 = emit_batch(W2_API, h_jobs_w2, td, "hw2")
        em_w4 = emit_batch(W4C_API, h_jobs_w4, td, "hw4")
        h_speedups = []
        for w in h_names:
            c_src = HOLDOUTS / w / "main.c"
            c_txt = c_src.read_text().replace("__attribute__((musttail))", "")
            c_tmp = td / f"h_{w}.c"; c_tmp.write_text(c_txt)
            c_exe = td / f"h_{w}_c"
            subprocess.run([CC, "-O3", "-ffp-contract=off", str(c_tmp), "-lm", "-pthread", "-o", str(c_exe)], check=True)
            rc_c, out_c, err_c, dt_c = run_timed([str(c_exe)], timeout=120)
            assert rc_c == 0, (w, "C failed", rc_c, err_c)

            row = {"c_s": round(dt_c, 4), "c_out": out_c}
            for tag, em, opath in [("w2", em_w2, td / f"h_{w}_w2.o"), ("w4c", em_w4, td / f"h_{w}_w4.o")]:
                if not em[w].get("ok"):
                    row[tag] = {"ok": False, "error": em[w].get("error")}
                    continue
                exe = td / f"h_{w}_{tag}"
                subprocess.run([CC, "-no-pie", str(opath), str(RT), "-pthread", "-lm", "-o", str(exe)], check=True)
                rc, stdout, stderr, dt = run_timed([str(exe)], timeout=180)
                match = (rc == 0 and stdout == out_c)
                row[tag] = {"ok": match, "s": round(dt, 4), "out": stdout, "vs_c": round(dt / dt_c, 3)}
            sp = (row["w2"]["s"] / row["w4c"]["s"]) if (row.get("w2", {}).get("ok") and row.get("w4c", {}).get("ok")) else None
            if sp:
                h_speedups.append(sp)
            row["w4c_speedup_vs_w2"] = round(sp, 3) if sp else None
            out["holdouts"][w] = row
            print(f"  {w:8s}: C={dt_c:.3f}s | W2={row['w2'].get('s')}s ({row['w2'].get('vs_c')}x C) | "
                  f"W4C={row['w4c'].get('s')}s ({row['w4c'].get('vs_c')}x C) | speedup={row['w4c_speedup_vs_w2']}x | "
                  f"ok={row['w2'].get('ok')}/{row['w4c'].get('ok')} out={out_c}", flush=True)
        if h_speedups:
            gm_h = math.exp(sum(math.log(x) for x in h_speedups) / len(h_speedups))
            out["holdouts_geomean_speedup_vs_w2"] = round(gm_h, 3)
            print(f"  Holdout geomean speedup (Wave 4C vs Wave 2): {gm_h:.3f}x", flush=True)

        # ------------------------------------------------------------------
        # 2. UNTOUCHED UPSTREAM DEFAULTS (histogram, gameoflife, nbody)
        # ------------------------------------------------------------------
        print("\n=== 2. UNTOUCHED UPSTREAM DEFAULTS (histogram, gameoflife, nbody) ===", flush=True)
        suite = json.loads((UPSTREAM / "suite.json").read_text())
        pub_c16 = {"histogram": 7.5097, "gameoflife": 17.4611, "nbody": 10.7390}
        pub_w2 = {"histogram": 130.2121, "gameoflife": 227.6527, "nbody": 54.5373}
        u_names = ["histogram", "gameoflife", "nbody"]
        u_jobs = [{"id": w, "src": str(UPSTREAM / w / "main.bend"), "out": str(td / f"u_{w}.o")} for w in u_names]
        em_u = emit_batch(W4C_API, u_jobs, td, "updef")
        u_ratios_c16 = []
        u_speedups_w2 = []
        for w in u_names:
            assert em_u[w]["ok"], (w, em_u[w])
            exe = td / f"u_{w}"
            subprocess.run([CC, "-no-pie", str(td / f"u_{w}.o"), str(RT), "-pthread", "-lm", "-o", str(exe)], check=True)
            rc, stdout, stderr, dt = run_timed([str(exe)], timeout=180)
            exp = str(suite[w]["expected"]["upstream"])
            ok = (rc == 0 and stdout == exp)
            vs_c16 = dt / pub_c16[w]
            sp_w2 = pub_w2[w] / dt
            u_ratios_c16.append(vs_c16)
            u_speedups_w2.append(sp_w2)
            out["upstream_defaults"][w] = {
                "ok": ok, "w4c_s": round(dt, 4), "w2_s": pub_w2[w], "c16_s": pub_c16[w],
                "vs_c16": round(vs_c16, 3), "speedup_vs_w2": round(sp_w2, 3), "out": stdout, "exp": exp
            }
            print(f"  {w:11s}: C16={pub_c16[w]:6.2f}s | W2={pub_w2[w]:7.2f}s ({pub_w2[w]/pub_c16[w]:5.2f}x) | "
                  f"W4C={dt:6.2f}s ({vs_c16:5.2f}x C16) | {sp_w2:.2f}x faster | ok={ok}", flush=True)
        gm_c16 = math.exp(sum(math.log(x) for x in u_ratios_c16) / len(u_ratios_c16))
        gm_sp = math.exp(sum(math.log(x) for x in u_speedups_w2) / len(u_speedups_w2))
        out["upstream_defaults_geomean_vs_c16"] = round(gm_c16, 3)
        out["upstream_defaults_geomean_speedup_vs_w2"] = round(gm_sp, 3)
        print(f"  Upstream defaults geomean: {gm_c16:.3f}x C16 ({gm_sp:.2f}x faster than Wave 2!)", flush=True)

        # ------------------------------------------------------------------
        # 3. NATIVE45 10-CASE ZERO-REGRESSION CHECK (Wave 4C vs Wave 2)
        # ------------------------------------------------------------------
        print("\n=== 3. NATIVE45 10-CASE ZERO-REGRESSION (Wave 4C vs Wave 2, CPU 2) ===", flush=True)
        cat45 = json.loads((ROOT / "selfhost/tools/bench/catalogs/native45/catalog.json").read_text())
        by_id = {c["id"]: c for c in cat45["cases"]}
        n45_targets = [
            "raytrace", "mandelbrot", "lexer", "coverage-bst-64", "coverage-map-churn-32",
            "coverage-record-aggregation-256", "editdist", "symreg", "coverage-list-pipeline-512", "tree-bitonic"
        ]
        n_jobs = [{"id": n, "src": str(ROOT / "selfhost/tools/bench" / by_id[n]["source"]["file"]), "out": str(td / f"n_{n}.o")} for n in n45_targets]
        em_n = emit_batch(W4C_API, n_jobs, td, "n45")
        n_ratios = []
        for n in n45_targets:
            assert em_n[n]["ok"], (n, em_n[n])
            w2_exe = td / f"n_{n}_w2"; w4_exe = td / f"n_{n}_w4"
            subprocess.run([CC, "-no-pie", str(FULL44 / f"{n}.cand.o"), str(RT), "-pthread", "-lm", "-o", str(w2_exe)], check=True)
            subprocess.run([CC, "-no-pie", str(td / f"n_{n}.o"), str(RT), "-pthread", "-lm", "-o", str(w4_exe)], check=True)
            t2, t4 = [], []
            for _ in range(3):
                rc2, o2, _, d2 = run_timed([str(w2_exe)], timeout=30); t2.append(d2)
                rc4, o4, _, d4 = run_timed([str(w4_exe)], timeout=30); t4.append(d4)
                assert rc2 == 0 and rc4 == 0 and o2.splitlines()[:3] == o4.splitlines()[:3], (n, o2, o4)
            m2, m4 = statistics.median(t2), statistics.median(t4)
            rat = m4 / m2
            n_ratios.append(rat)
            out["native45"][n] = {"w2_ms": round(m2 * 1000, 2), "w4c_ms": round(m4 * 1000, 2), "ratio": round(rat, 4)}
            print(f"  {n:32s}: w2={m2*1000:6.1f}ms  w4c={m4*1000:6.1f}ms  ratio={rat:.4f}x  MATCH", flush=True)
        gm_n = math.exp(sum(math.log(x) for x in n_ratios) / len(n_ratios))
        out["native45_geomean_w4c_vs_w2"] = round(gm_n, 4)
        print(f"  native45 10-case geomean (Wave 4C / Wave 2): {gm_n:.4f}x", flush=True)

    out_path = ROOT / "selfhost/build/agy/wave4_bench/phase4_eval.json"
    out_path.write_text(json.dumps(out, indent=2))
    print(f"\nSaved {out_path}", flush=True)


if __name__ == "__main__":
    main()
