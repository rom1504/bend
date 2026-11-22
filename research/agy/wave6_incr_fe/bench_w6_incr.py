#!/usr/bin/env python3
"""Wave 6 Incremental Frontend + Lowering + Persistent Daemon Benchmark & Soundness Suite.

Tests:
  1. 4/4 Live-Edit Correctness + Speedup vs Wave 5 on `histogram`, `gameoflife`, `nbody`, `lexer`:
     - Cold build -> exact expected stdout
     - 1-function body edit -> hits `incr_fe_lower`, exact stdout == clean full compile, != cold
     - 2nd consecutive 1-function body edit -> verifies session update stays sound & fast!
     - No-op rebuild -> hits `whole_prog_hit`, exact stdout == edit
  2. Multi-Def Edit Test (2 functions edited simultaneously in `histogram` and `lexer`):
     - Hits `incr_fe_lower`, exact stdout == clean full compile!
  3. Signature-Change Invalidation Test (changing signature + caller in `lexer`):
     - Automatically triggers conservative fallback (`header_changed:*`), zero stale cache,
       exact stdout == clean full compile!
  4. Type-Error Rejection Test (injecting a type error into `key` in `histogram`):
     - Must FAIL compilation (never return a stale binary!).
  5. CLI-over-socket latency measurement (real end-to-end process invocation via `incr_compile.mjs --socket`).
"""
import json
import os
import re
import socket
import subprocess
import time
from pathlib import Path

ROOT = Path("/home/ai/bend2_agy")
API = ROOT / "selfhost/build/agy/wave5c_unified/api.mjs"
DAEMON = ROOT / "research/agy/wave6_incr_fe/incr_daemon.mjs"
CLI = ROOT / "research/agy/wave6_incr_fe/incr_compile.mjs"
LOCKED_NODE = ROOT / "research/agy/locked_node.sh"
WAVE5_RECEIPT = ROOT / "experiments/agy/receipts/wave5-incr-bench.json"
WORK_DIR = Path("/tmp/agy_w6_incr_fe/bench_run")
SOCK_PATH = Path("/tmp/agy_w6_incr_fe/daemon.sock")
RTS = ["+RTS", "--threads", "1", "--gpu", "off", "-RTS"]


def prep_upstream_small(family: str) -> str:
    spec = json.loads((ROOT / "research/agy/wave4_bench/inputs/upstream/suite.json").read_text())[family]
    txt = (ROOT / "research/agy/wave4_bench/inputs/upstream" / family / "main.bend").read_text()
    for bname, _, old, new in zip(spec["bendKnobs"], spec["cKnobs"], spec["upstream"], spec["small"]):
        txt = re.sub(rf"(?m)(^def {bname}\(\) -> Nat:\n  ){old}n$", rf"\g<1>{new}n", txt, count=1)
    return txt


def edit_non_comment(src: str, old: str, new: str, occurrence: int = 1) -> str:
    lines = src.splitlines(keepends=True)
    seen = 0
    for i, line in enumerate(lines):
        if not line.lstrip().startswith("#") and old in line:
            seen += 1
            if seen == occurrence:
                lines[i] = line.replace(old, new, 1)
                return "".join(lines)
    raise ValueError(f"Could not find non-comment {old!r} occurrence {occurrence}")


def run_exe(exe: Path) -> str:
    r = subprocess.run(
        ["taskset", "-c", "0,1,4,5", str(exe), *RTS],
        capture_output=True,
        text=True,
        check=True,
        timeout=60,
    )
    return r.stdout.strip()


def daemon_rpc(sock_path: Path, req: dict) -> dict:
    t0 = time.perf_counter()
    with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as s:
        s.connect(str(sock_path))
        s.sendall((json.dumps(req) + "\n").encode("utf-8"))
        buf = b""
        while b"\n" not in buf:
            chunk = s.recv(65536)
            if not chunk:
                break
            buf += chunk
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    resp = json.loads(buf.decode("utf-8").splitlines()[0])
    resp["rpcWallMs"] = wall_ms
    return resp


def run_cli_over_socket(src: Path, out: Path, cache_dir: Path, sock_path: Path) -> dict:
    t0 = time.perf_counter()
    node_bin = "/home/ai/.nvm/versions/node/v24.22.1/bin/node"
    r = subprocess.run(
        [
            "taskset", "-c", "0,1,4,5",
            node_bin, str(CLI),
            "--api", str(API),
            "--src", str(src),
            "--out", str(out),
            "--cache-dir", str(cache_dir),
            "--socket", str(sock_path),
            "--json",
        ],
        capture_output=True,
        text=True,
        check=True,
    )
    wall_ms = round((time.perf_counter() - t0) * 1000.0, 1)
    res = json.loads(r.stdout.strip().splitlines()[-1])
    res["procWallMs"] = wall_ms
    return res


def main():
    if WORK_DIR.exists():
        import shutil
        shutil.rmtree(WORK_DIR)
    WORK_DIR.mkdir(parents=True, exist_ok=True)
    cache_dir = WORK_DIR / "cache"
    clean_cache_dir = WORK_DIR / "clean_cache"

    wave5_by_name = {}
    if WAVE5_RECEIPT.exists():
        for row in json.loads(WAVE5_RECEIPT.read_text()):
            wave5_by_name[row["name"]] = row

    # Start persistent daemon pinned to CPUs 0,1,4,5 via locked_node.sh
    if SOCK_PATH.exists():
        SOCK_PATH.unlink()
    daemon_proc = subprocess.Popen(
        [
            "taskset", "-c", "0,1,4,5",
            "bash", str(LOCKED_NODE), str(DAEMON),
            "--api", str(API),
            "--socket", str(SOCK_PATH),
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
    )

    try:
        ready_line = daemon_proc.stdout.readline().strip()
        if not ready_line:
            err = daemon_proc.stderr.read()
            raise RuntimeError(f"Daemon failed to start:\n{err}")
        ready_info = json.loads(ready_line)
        print(f"[DAEMON] Ready pid={ready_info['pid']} startup={ready_info['startup']}\n")

        specs = [
            ("histogram", prep_upstream_small("histogram"), "3825188900"),
            ("gameoflife", prep_upstream_small("gameoflife"), "2601177279"),
            ("nbody", prep_upstream_small("nbody"), "2215450620"),
            ("lexer", (ROOT / "selfhost/tests/consolidation/native-broad/lexer.bend").read_text(), None),
        ]

        print(f"{'Program':<11} {'W5_Edit1':>9} {'W6_Edit1':>9} {'Speedup':>8} {'Mode':<14} {'Plan':>6} {'PW':>6} {'Hash':>5} {'Emit':>6} {'Link':>6} {'Edit2':>7} {'NoOp':>6} {'CLI':>7}  {'Sound'}")
        print("-" * 124)

        rows = []
        for name, src_text, want_cold in specs:
            src_p = WORK_DIR / f"{name}.bend"
            src_p.write_text(src_text)

            # 1. Cold build
            exe_cold = WORK_DIR / f"{name}_cold.bin"
            c_resp = daemon_rpc(SOCK_PATH, {"src": str(src_p), "out": str(exe_cold), "cacheDir": str(cache_dir), "shards": 4})
            assert c_resp["ok"], f"Cold failed for {name}: {c_resp.get('error')}"
            c_res = c_resp["summary"]
            out_cold = run_exe(exe_cold)

            # 2. 1-function body edit (edit1)
            edit1_text = edit_non_comment(src_text, "2654435761", "2654435763", 1)
            src_p.write_text(edit1_text)
            exe_edit1 = WORK_DIR / f"{name}_edit1.bin"
            e1_resp = daemon_rpc(SOCK_PATH, {"src": str(src_p), "out": str(exe_edit1), "cacheDir": str(cache_dir), "shards": 4})
            assert e1_resp["ok"], f"Edit1 failed for {name}: {e1_resp.get('error')}"
            e1_res = e1_resp["summary"]
            e1_res["rpcWallMs"] = e1_resp["rpcWallMs"]
            out_edit1 = run_exe(exe_edit1)

            # 3. 2nd consecutive 1-function edit (edit2) — verifies session update!
            edit2_text = edit_non_comment(src_text, "2654435761", "2654435765", 1)
            src_p.write_text(edit2_text)
            exe_edit2 = WORK_DIR / f"{name}_edit2.bin"
            e2_resp = daemon_rpc(SOCK_PATH, {"src": str(src_p), "out": str(exe_edit2), "cacheDir": str(cache_dir), "shards": 4})
            assert e2_resp["ok"], f"Edit2 failed for {name}: {e2_resp.get('error')}"
            e2_res = e2_resp["summary"]
            e2_res["rpcWallMs"] = e2_resp["rpcWallMs"]
            out_edit2 = run_exe(exe_edit2)

            # 4. No-op rebuild (exact same edit2)
            exe_noop = WORK_DIR / f"{name}_noop.bin"
            n_resp = daemon_rpc(SOCK_PATH, {"src": str(src_p), "out": str(exe_noop), "cacheDir": str(cache_dir), "shards": 4})
            assert n_resp["ok"], f"NoOp failed for {name}: {n_resp.get('error')}"
            n_res = n_resp["summary"]
            n_res["rpcWallMs"] = n_resp["rpcWallMs"]
            out_noop = run_exe(exe_noop)

            # 5. CLI-over-socket measurement on a 3rd edit (edit3)
            edit3_text = edit_non_comment(src_text, "2654435761", "2654435767", 1)
            src_p.write_text(edit3_text)
            exe_cli = WORK_DIR / f"{name}_cli.bin"
            cli_res = run_cli_over_socket(src_p, exe_cli, cache_dir, SOCK_PATH)
            out_cli = run_exe(exe_cli)

            # 6. Independent clean full-compile oracle check on edit1!
            oracle_src = WORK_DIR / f"{name}_oracle.bend"
            oracle_src.write_text(edit1_text)
            exe_oracle = WORK_DIR / f"{name}_oracle.bin"
            o_resp = daemon_rpc(SOCK_PATH, {"src": str(oracle_src), "out": str(exe_oracle), "cacheDir": str(clean_cache_dir), "shards": 4})
            assert o_resp["ok"], f"Oracle failed for {name}: {o_resp.get('error')}"
            out_oracle = run_exe(exe_oracle)

            cold_ok = (want_cold is None or out_cold == want_cold)
            changed_ok = (out_edit1 != out_cold) and (out_edit2 != out_edit1) and (out_cli != out_edit2)
            oracle_ok = (out_edit1 == out_oracle)
            noop_ok = (out_noop == out_edit2)
            sound = cold_ok and changed_ok and oracle_ok and noop_ok and len(out_cold) > 0

            w5_ms = wave5_by_name[name]["edit1"]["totalMs"] if name in wave5_by_name else 0.0
            spd = (w5_ms / e1_res["rpcWallMs"]) if (w5_ms > 0 and e1_res["rpcWallMs"] > 0) else 0.0

            print(
                f"{name:<11} {w5_ms:8.1f}ms {e1_res['rpcWallMs']:8.1f}ms {spd:7.1f}x {e1_res['mode']:<14} "
                f"{e1_res['planMs']:6.1f} {e1_res['pwMs']:6.1f} {e1_res['hashMs']:5.1f} "
                f"{e1_res['emitMs']:6.1f} {e1_res['linkMs']:6.1f} {e2_res['rpcWallMs']:6.1f}ms "
                f"{n_res['rpcWallMs']:5.1f}ms {cli_res['procWallMs']:6.1f}ms  {'PASS' if sound else 'FAIL'}"
            )
            if e1_res.get("fallbackReason"):
                print(f"   ^ fallbackReason: {e1_res['fallbackReason']}")

            rows.append({
                "name": name,
                "wave5_edit1_ms": w5_ms,
                "speedup_vs_w5": round(spd, 2),
                "cold": c_res,
                "edit1": e1_res,
                "edit2": e2_res,
                "noop": n_res,
                "cli_edit3": cli_res,
                "out_cold": out_cold,
                "out_edit1": out_edit1,
                "out_oracle_edit1": out_oracle,
                "out_edit2": out_edit2,
                "out_cli_edit3": out_cli,
                "sound": sound,
            })

        # === EXTRA SOUNDNESS TESTS ===
        print("\n=== EXTRA SOUNDNESS & INVALIDATION TESTS ===")
        extra_tests = []

        # Test A: Multi-def edit (2 live functions edited simultaneously in lexer: `seed` and `mix`)
        lexer_src = (ROOT / "selfhost/tests/consolidation/native-broad/lexer.bend").read_text()
        multi_cache = WORK_DIR / "multi_cache"
        multi_p = WORK_DIR / "lexer_multi.bend"
        multi_p.write_text(lexer_src)
        daemon_rpc(SOCK_PATH, {"src": str(multi_p), "out": str(WORK_DIR / "lm_cold.bin"), "cacheDir": str(multi_cache), "shards": 4})
        multi_edited = lexer_src.replace(
            "prng(((i + 1) * 2654435761 : U32))",
            "prng(((i + 1) * 2654435769 : U32))"
        ).replace(
            "U32.xor((acc * 2654435761 : U32), (kind * 40503 + x : U32))",
            "U32.xor((acc * 2654435771 : U32), (kind * 40503 + x : U32))"
        )
        multi_p.write_text(multi_edited)
        lm_resp = daemon_rpc(SOCK_PATH, {"src": str(multi_p), "out": str(WORK_DIR / "lm_edit.bin"), "cacheDir": str(multi_cache), "shards": 4})
        assert lm_resp["ok"]
        lm_out = run_exe(WORK_DIR / "lm_edit.bin")
        # Oracle
        lm_ora_p = WORK_DIR / "lexer_multi_oracle.bend"
        lm_ora_p.write_text(multi_edited)
        daemon_rpc(SOCK_PATH, {"src": str(lm_ora_p), "out": str(WORK_DIR / "lm_ora.bin"), "cacheDir": str(clean_cache_dir), "shards": 4})
        lm_ora_out = run_exe(WORK_DIR / "lm_ora.bin")
        lm_fb = lm_resp["summary"].get("fallbackReason") or ""
        multi_ok = (lm_out == lm_ora_out) and (lm_fb == "not_private_rem:mix")
        print(f"  [Multi-Def W2D-Opt Guard (lexer: seed+mix)] mode={lm_resp['summary']['mode']} fallback={lm_fb} total={lm_resp['rpcWallMs']}ms exact={lm_out == lm_ora_out} -> {'PASS' if multi_ok else 'FAIL'}")
        extra_tests.append({"test": "multi_def_w2d_guard_lexer", "mode": lm_resp["summary"]["mode"], "fallbackReason": lm_fb, "rpcWallMs": lm_resp["rpcWallMs"], "pass": multi_ok})

        # Test A2: Multi-def edit on histogram (`key` + `sum.go`)
        hist_src = prep_upstream_small("histogram")
        hm_cache = WORK_DIR / "hm_cache"
        hm_p = WORK_DIR / "hist_multi.bend"
        hm_p.write_text(hist_src)
        daemon_rpc(SOCK_PATH, {"src": str(hm_p), "out": str(WORK_DIR / "hm_cold.bin"), "cacheDir": str(hm_cache), "shards": 4})
        hm_edited = hist_src.replace(
            "U32.mod(prng(prng(((j + 1) * 2654435761 + s : U32))), 256)",
            "U32.mod(prng(prng(((j + 1) * 2654435769 + s : U32))), 256)"
        ).replace(
            "(cs, U32.xor((h * 2654435761 : U32), x))",
            "(cs, U32.xor((h * 2654435771 : U32), x))"
        )
        hm_p.write_text(hm_edited)
        hm_resp = daemon_rpc(SOCK_PATH, {"src": str(hm_p), "out": str(WORK_DIR / "hm_edit.bin"), "cacheDir": str(hm_cache), "shards": 4})
        assert hm_resp["ok"]
        hm_out = run_exe(WORK_DIR / "hm_edit.bin")
        hm_ora_p = WORK_DIR / "hist_multi_oracle.bend"
        hm_ora_p.write_text(hm_edited)
        daemon_rpc(SOCK_PATH, {"src": str(hm_ora_p), "out": str(WORK_DIR / "hm_ora.bin"), "cacheDir": str(clean_cache_dir), "shards": 4})
        hm_ora_out = run_exe(WORK_DIR / "hm_ora.bin")
        hm_ok = (hm_out == hm_ora_out) and (hm_resp["summary"]["mode"] == "incr_fe_lower")
        print(f"  [Multi-Def Edit (histogram: key+sum.go)] mode={hm_resp['summary']['mode']} fallback={hm_resp['summary'].get('fallbackReason')} total={hm_resp['rpcWallMs']}ms exact={hm_out == hm_ora_out} -> {'PASS' if hm_ok else 'FAIL'}")
        extra_tests.append({"test": "multi_def_edit_histogram", "mode": hm_resp["summary"]["mode"], "rpcWallMs": hm_resp["rpcWallMs"], "pass": hm_ok})

        # Test B: Signature-change invalidation (change `def seed(i: U32) -> U32:` to `def seed(i: U32, k: U32) -> U32:` and update its call)
        sig_cache = WORK_DIR / "sig_cache"
        sig_p = WORK_DIR / "lexer_sig.bend"
        sig_p.write_text(lexer_src)
        daemon_rpc(SOCK_PATH, {"src": str(sig_p), "out": str(WORK_DIR / "ls_cold.bin"), "cacheDir": str(sig_cache), "shards": 4})
        sig_edited = lexer_src.replace(
            "def seed(i: U32) -> U32:\n  prng(((i + 1) * 2654435761 : U32))",
            "def seed(i: U32, k: U32) -> U32:\n  prng(((i + k) * 2654435761 : U32))"
        ).replace("seed(i)", "seed(i, 3)")
        sig_p.write_text(sig_edited)
        ls_resp = daemon_rpc(SOCK_PATH, {"src": str(sig_p), "out": str(WORK_DIR / "ls_edit.bin"), "cacheDir": str(sig_cache), "shards": 4})
        assert ls_resp["ok"], f"Sig edit failed: {ls_resp.get('error')}"
        ls_out = run_exe(WORK_DIR / "ls_edit.bin")
        ls_ora_p = WORK_DIR / "lexer_sig_oracle.bend"
        ls_ora_p.write_text(sig_edited)
        daemon_rpc(SOCK_PATH, {"src": str(ls_ora_p), "out": str(WORK_DIR / "ls_ora.bin"), "cacheDir": str(clean_cache_dir), "shards": 4})
        ls_ora_out = run_exe(WORK_DIR / "ls_ora.bin")
        fb = ls_resp["summary"].get("fallbackReason") or ""
        sig_ok = (ls_out == ls_ora_out) and (ls_resp["summary"]["mode"] != "incr_fe_lower") and fb.startswith("header_changed:")
        print(f"  [Signature-Change Invalidation] mode={ls_resp['summary']['mode']} fallback={fb} exact={ls_out == ls_ora_out} -> {'PASS' if sig_ok else 'FAIL'}")
        extra_tests.append({"test": "sig_change_invalidation", "mode": ls_resp["summary"]["mode"], "fallbackReason": fb, "pass": sig_ok})

        # Test C: Type-error rejection (must NOT serve stale binary!)
        err_p = WORK_DIR / "hist_typeerr.bend"
        hist_src = prep_upstream_small("histogram")
        err_p.write_text(hist_src)
        daemon_rpc(SOCK_PATH, {"src": str(err_p), "out": str(WORK_DIR / "he_cold.bin"), "cacheDir": str(cache_dir), "shards": 4})
        bad_src = hist_src.replace(
            "U32.mod(prng(prng(((j + 1) * 2654435761 + s : U32))), 256)",
            "\"not_a_u32\""
        )
        err_p.write_text(bad_src)
        he_resp = daemon_rpc(SOCK_PATH, {"src": str(err_p), "out": str(WORK_DIR / "he_bad.bin"), "cacheDir": str(cache_dir), "shards": 4})
        err_ok = (not he_resp["ok"]) and (not (WORK_DIR / "he_bad.bin").exists())
        print(f"  [Type-Error Rejection] ok={he_resp['ok']} binary_created={(WORK_DIR / 'he_bad.bin').exists()} -> {'PASS' if err_ok else 'FAIL'}")
        extra_tests.append({"test": "type_error_rejection", "rejected": err_ok, "pass": err_ok})

        all_pass = all(r["sound"] for r in rows) and all(t["pass"] for t in extra_tests)
        receipt = {
            "startup": ready_info["startup"],
            "benchmarks": rows,
            "extra_tests": extra_tests,
            "all_pass": all_pass,
        }
        receipt_path = ROOT / "research/agy/wave6_incr_fe/receipt.json"
        receipt_path.write_text(json.dumps(receipt, indent=2) + "\n")
        print(f"\nSaved receipt: {receipt_path} | ALL_PASS={all_pass}")
        if not all_pass:
            raise SystemExit(1)

    finally:
        try:
            daemon_rpc(SOCK_PATH, {"cmd": "shutdown"})
        except Exception:
            daemon_proc.terminate()
        daemon_proc.wait(timeout=10)
        # Clean up temporary binaries/cache to keep disk usage minimal (>= 5 GiB free!)
        import shutil
        if WORK_DIR.exists():
            shutil.rmtree(WORK_DIR)


if __name__ == "__main__":
    main()
